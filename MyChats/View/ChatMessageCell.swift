//
//  ChatMessagecell.swift
//  MyChats
//
//  Created by Timotius Leonardo Lianoto on 20/02/22.
//

import UIKit
import AVFoundation

class ChatMessageCell: UICollectionViewCell {
    weak var chatLogController: ChatLogController?
    var videoUrl: URL?
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var message: Message?
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .white
        return view
    }()
    
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
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleMessageImageView)))
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
        bubbleView.addSubview(playButton)
        bubbleView.addSubview(activityIndicatorView)
        
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
        
        let playButtonConstraints = [
            playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        let activityIndicatorConstraints = [
            activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 50),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(textViewConstraints)
        NSLayoutConstraint.activate(bubbleViewConstraints)
        NSLayoutConstraint.activate(profileImageViewConstraints)
        NSLayoutConstraint.activate(messageImageViewConstraints)
        NSLayoutConstraint.activate(playButtonConstraints)
        NSLayoutConstraint.activate(activityIndicatorConstraints)
    }
    
    @objc func handleMessageImageView(tapGesture: UITapGestureRecognizer) {
        if message?.videoUrl != nil {
            return
        }
        
        if let imageView = tapGesture.view as? UIImageView {
            chatLogController?.performZoomInForImageView(imageView: imageView)
        }
    }
    
    @objc func handlePlay() {
        guard let videoUrl = videoUrl else {
            return
        }
        player = AVPlayer(url: videoUrl)
        guard let player = player else {
            return
        }

        // render video and add layer in top
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bubbleView.bounds
        guard let playerLayer = playerLayer else {
            return
        }

        bubbleView.layer.addSublayer(playerLayer)
        
        player.play()
        activityIndicatorView.startAnimating()
        playButton.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}
