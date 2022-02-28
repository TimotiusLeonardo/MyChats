//
//  ChatMessagecell.swift
//  MyChats
//
//  Created by Timotius Leonardo Lianoto on 20/02/22.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    lazy var textView: UITextView = {
        let tv = UITextView()
        tv.text = "Sampe Text For Now"
        tv.font = .systemFont(ofSize: 16, weight: .regular)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isUserInteractionEnabled = false
        tv.backgroundColor = .clear
        tv.textColor = .white
        return tv
    }()
    
    lazy var bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = ChatMessageCell.blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    static let blueColor: UIColor = .init(r: 0, g: 137, b: 249)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        bubbleView.addSubview(messageImageView)
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        let bubbleViewConstraints = [
            bubbleView.topAnchor.constraint(equalTo: self.topAnchor),
            bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ]
        bubbleWidthAnchor?.isActive = true
        bubbleViewRightAnchor?.isActive = true
        
        let textViewConstraints = [
            textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -8),
            textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8),
            textView.topAnchor.constraint(equalTo: self.topAnchor),
            textView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ]
        
        let profileImageViewConstraints = [
            profileImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            profileImageView.heightAnchor.constraint(equalToConstant: 32)
        ]
        
        let messageImageViewConstraints = [
            messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor),
            messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor),
            messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor)
        ]
        
        NSLayoutConstraint.activate(textViewConstraints)
        NSLayoutConstraint.activate(bubbleViewConstraints)
        NSLayoutConstraint.activate(profileImageViewConstraints)
        NSLayoutConstraint.activate(messageImageViewConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}
