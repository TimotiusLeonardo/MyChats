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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(handleNewMessage))
        checkIfUserIsLoggedIn()
    }
    
    private func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            performSelector(onMainThread: #selector(handleLogout), with: nil, waitUntilDone: true)
        } else {
            fetchUserAndSetupNavbarTitle()
        }
    }
    
    @objc func handleNewMessage() {
        let newMessagecontroller = NewMessageTableViewController()
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
            }
        }
    }
    
    func setupNavBarWithUser(user: User) {
        let titleView = UIView()
        titleView.frame = .init(x: 0, y: 0, width: 100, height: 40)
        
        
        
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        titleView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        titleView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
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
        present(loginVC, animated: true, completion: nil)
    }

}

