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
        view.backgroundColor = .init(r: 0, g: 137, b: 249)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        return view
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        
        let bubbleViewConstraints = [
            bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
            bubbleView.topAnchor.constraint(equalTo: self.topAnchor),
            bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ]
        bubbleWidthAnchor?.isActive = true
        
        let textViewConstraints = [
            textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor, constant: -8),
            textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8),
            textView.topAnchor.constraint(equalTo: self.topAnchor),
            textView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ]
        
        NSLayoutConstraint.activate(textViewConstraints)
        NSLayoutConstraint.activate(bubbleViewConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}
