//
//  UserCell.swift
//  MyChats
//
//  Created by Timotius Leonardo Lianoto on 18/02/22.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            self.setupNameAndProfileImage()
            self.detailTextLabel?.text = message?.text
            self.timeLabel.text = self.formatDate(timeInterval: message?.timestamp)
        }
    }
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
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .light)
        label.textColor = .lightGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        addSubview(timeLabel)
        
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: profileImageViewSize).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: profileImageViewSize).isActive = true
        guard let textLabel = textLabel else {
            return
        }
        let timeLabelConstraints = [
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            timeLabel.widthAnchor.constraint(equalToConstant: 100),
            timeLabel.heightAnchor.constraint(equalTo: textLabel.heightAnchor)
        ]
        
        NSLayoutConstraint.activate(timeLabelConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupNameAndProfileImage() {
        if let toId = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(toId)
            ref.observeSingleEvent(of: .value, with: { snapshot in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                }
            })
        }
    }
    
    private func formatDate(timeInterval: TimeInterval?) -> String {
        guard let timeInterval = timeInterval else {
            return ""
        }

        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormat = "hh:mm a"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
}
