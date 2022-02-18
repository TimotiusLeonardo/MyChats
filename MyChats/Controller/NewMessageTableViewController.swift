//
//  NewMessageTableViewController.swift
//  MyChats
//
//  Created by Timotius Leonardo Lianoto on 16/02/22.
//

import UIKit
import Firebase

class NewMessageTableViewController: UITableViewController {

    let messageCellId = "messageCellId"
    var users = [User]()
    var messageController: ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: messageCellId)
        
        fetchUser()
    }
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded) { snapshot in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                guard let name = dictionary["name"] as? String, let email = dictionary["email"] as? String else {
                    return
                }
                let profileImageUrl = dictionary["profileImageUrl"] as? String
                user.name = name
                user.email = email
                user.profileImageUrl = profileImageUrl
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: messageCellId, for: indexPath) as? UserCell else {
            return UITableViewCell()
        }
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messageController?.showChatController(user: user)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

}

class UserCell: UITableViewCell {
    
    let profileImageViewSize: CGFloat = 48
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "pencil")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let cellTextLabel = textLabel, let detailTextLabel = detailTextLabel else {
            return
        }
        
        cellTextLabel.frame = CGRect(x: 72, y: cellTextLabel.frame.origin.y, width: cellTextLabel.frame.width, height: cellTextLabel.frame.height)
        detailTextLabel.frame = CGRect(x: 72, y: detailTextLabel.frame.origin.y, width: detailTextLabel.frame.width, height: detailTextLabel.frame.height)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: profileImageViewSize).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: profileImageViewSize).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
