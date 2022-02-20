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
        tv.textColor = .black
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isUserInteractionEnabled = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)
        
        let textViewConstraints = [
            textView.rightAnchor.constraint(equalTo: self.rightAnchor),
            textView.topAnchor.constraint(equalTo: self.topAnchor),
            textView.widthAnchor.constraint(equalToConstant: 200),
            textView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ]
        
        NSLayoutConstraint.activate(textViewConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}
