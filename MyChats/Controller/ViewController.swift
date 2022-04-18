//
//  ViewController.swift
//  MyChats
//
//  Created by Timotius Leonardo Lianoto on 05/02/22.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UITableViewController {
    
    var messages = [Message]()
    let cellId = "cellId"
    var messageDictionary = [String: Message]()
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(handleNewMessage))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        checkIfUserIsLoggedIn()
        observeUserMessages()
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    private func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            performSelector(onMainThread: #selector(handleLogout), with: nil, waitUntilDone: true)
        } else {
            fetchUserAndSetupNavbarTitle()
        }
    }
    
    private func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded) { snapshot in
            let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded) { snapshot in
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId: messageId)
            }
        }
        
        ref.observe(.childRemoved) { snapshot in
            print(snapshot.key)
            self.messageDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadTable()
        }
    }
    
    private func fetchMessageWithMessageId(messageId: String) {
        let messageReference = Database.database().reference().child("messages").child(messageId)
        
        messageReference.observeSingleEvent(of: .value) { snapshot in
            if let dictionary = snapshot.value as? [String: Any] {
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messageDictionary[chatPartnerId] = message
                }
                
                self.attemptReloadTable()
            }
        } withCancel: { error in
            print(error.localizedDescription)
        }
    }
    
    private func attemptReloadTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadTable() {
        self.messages = Array(self.messageDictionary.values)
        self.messages.sort { message1, message2 in
            return message1.timestamp ?? TimeInterval() > message2.timestamp ?? TimeInterval()
        }
        
        DispatchQueue.main.async {
            print("we reloaded the table")
            self.tableView.reloadData()
        }
    }
    
    @objc func handleNewMessage() {
        let newMessagecontroller = NewMessageTableViewController()
        newMessagecontroller.messageController = self
        let navController = UINavigationController(rootViewController: newMessagecontroller)
        present(navController, animated: true, completion: nil)
    }
    
    func fetchUserAndSetupNavbarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                guard let name = dictionary["name"] as? String, let email = dictionary["email"] as? String else {
                    return
                }
                let profileImageUrl = dictionary["profileImageUrl"] as? String
                user.name = name
                user.email = email
                user.profileImageUrl = profileImageUrl
                self.setupNavBarWithUser(user: user)
                self.observeUserMessages()
            }
        }
    }
    
    func setupNavBarWithUser(user: User) {
        let titleView = UIView()
        titleView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        titleView.isUserInteractionEnabled = true
        
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        titleView.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor, constant: -32).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        titleView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 12, weight: .black)
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        self.observeUserMessages()
    }
    
    private func refreshTableViewToEmpty() {
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
    }
    
    func redirectToChatController(user: User?) {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = .init(width: view.frame.width, height: 80)
        let chatLogController = ChatLogController(collectionViewLayout: collectionViewLayout)
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func showChatController() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = .init(width: view.frame.width, height: 80)
        let chatLogController = ChatLogController(collectionViewLayout: collectionViewLayout)
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginVC = LoginController()
        loginVC.messageController = self
        loginVC.modalPresentationStyle = .fullScreen
        refreshTableViewToEmpty()
        present(loginVC, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        72
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? UserCell else {
            return UITableViewCell()
        }
        let message = messages[indexPath.row]
        cell.configureCell(message: message)
        cell.layoutIfNeeded()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = User()
            guard let name = dictionary["name"] as? String, let email = dictionary["email"] as? String else {
                return
            }
            let profileImageUrl = dictionary["profileImageUrl"] as? String
            user.name = name
            user.email = email
            user.profileImageUrl = profileImageUrl
            user.id = chatPartnerId
            self.redirectToChatController(user: user)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let message = self.messages[indexPath.row]
        if let chatPartnerId = message.chatPartnerId() {
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue { error, reference in
                if error != nil {
                    print("Failed to delete message: ", error?.localizedDescription ?? "Error delete message")
                    return
                }
                
                self.messageDictionary.removeValue(forKey: chatPartnerId)
                self.messages.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .left)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.attemptReloadTable()
                }
            }
        }
    }
}

