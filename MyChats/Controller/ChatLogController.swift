//
//  ChatLogController.swift
//  MyChats
//
//  Created by Timotius Leonardo Lianoto on 17/02/22.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    var cellId = "cellId"
    var messages = [Message]()
    var bottomContainerViewBottomConstraints: NSLayoutConstraint?
    lazy var inputTextField: UITextField = {
        let inputTextField = UITextField()
        inputTextField.placeholder = "Enter message..."
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.delegate = self
        return inputTextField
    }()
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = .init(x: 0, y: 0, width: view.frame.width, height: 80)
        containerView.backgroundColor = .white
        
        let sendButton = UIButton(type: .system)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        containerView.addSubview(inputTextField)
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadImageButton)))
        containerView.addSubview(uploadImageView)
        
        let uploadImageViewConstraints = [
            uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 24),
            uploadImageView.centerYAnchor.constraint(equalTo: inputTextField.centerYAnchor),
            uploadImageView.widthAnchor.constraint(equalToConstant: 30),
            uploadImageView.heightAnchor.constraint(equalToConstant: 24)
        ]
        
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 24).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.5).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        NSLayoutConstraint.activate(uploadImageViewConstraints)
        
        return containerView
    }()
    
    lazy var imagePickerController: ImagePicker = {
        let picker = ImagePicker(presentationController: self, delegate: self)
        return picker
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.keyboardDismissMode = .interactive
        hideKeyboardWhenTappedAround()
    }
    
    /// For changing traits
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular)], context: nil)
    }
    
    private func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded) { snapshot in
            let messageId = snapshot.key
            let messageref = Database.database().reference().child("messages").child(messageId)
            messageref.observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else {
                    return
                }
                
                let message = Message(dictionary: dictionary)
                
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func uploadImageToFirebase(image: UIImage) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("messages_images").child("\(imageName).png")
        
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            ref.putData(uploadData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Failed to upload messages image: ", error.localizedDescription)
                    return
                }
                
                ref.downloadURL { url, error in
                    if let error = error {
                        print("Failed to upload messages image: ", error.localizedDescription)
                        return
                    }
                    
                    if let url = url?.absoluteString {
                        self.sendMessageWithImageUrl(imageUrl: url, image: image)
                    }
                }
            }
        }
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        guard let toId = user?.id, let fromId = Auth.auth().currentUser?.uid else {
            print("No User ID is found to send message")
            return
        }
        let timestamp = Date().timeIntervalSince1970
        let values: [String: Any] = [
            "imageUrl": imageUrl,
            "imageWidth": image.size.width,
            "imageHeight": image.size.height,
            "toId": toId,
            "fromId": fromId,
            "timestamp": timestamp
        ]
        childRef.updateChildValues(values) { error, ref in
            if error != nil {
                print(error?.localizedDescription ?? "Error updating message to send")
                return
            }
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            guard let messageId = childRef.key else {
                return
            }
            let values: [String: Any] = [
                messageId: 1
            ]
            userMessagesRef.updateChildValues(values) { error, _ in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
                recipientUserMessagesRef.updateChildValues([messageId: 1])
                
                self.inputTextField.text = nil
                self.inputTextField.resignFirstResponder()
            }
        }
    }
    
    @objc func handleUploadImageButton() {
        imagePickerController.present(from: view)
    }
    
    @objc func handleSend() {
        let ref = Database.database().reference().child("messages")
        guard let text = inputTextField.text, !text.isEmpty else {
            print("Input text is contain NO TEXT, please add some text to send to another user.")
            return
        }
        let childRef = ref.childByAutoId()
        guard let toId = user?.id, let fromId = Auth.auth().currentUser?.uid else {
            print("No User ID is found to send message")
            return
        }
        let timestamp = Date().timeIntervalSince1970
        let values: [String: Any] = [
            "text": text,
            "toId": toId,
            "fromId": fromId,
            "timestamp": timestamp
        ]
        childRef.updateChildValues(values) { error, ref in
            if error != nil {
                print(error?.localizedDescription ?? "Error updating message to send")
                return
            }
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            guard let messageId = childRef.key else {
                return
            }
            let values: [String: Any] = [
                messageId: 1
            ]
            userMessagesRef.updateChildValues(values) { error, _ in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
                recipientUserMessagesRef.updateChildValues([messageId: 1])
                
                self.inputTextField.text = nil
                self.inputTextField.resignFirstResponder()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ChatMessageCell else {
            return UICollectionViewCell()
        }
        
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
        } else if  message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
        }
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            // outcoming message
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            // incoming message
            cell.bubbleView.backgroundColor = .init(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .lightGray
        } else {
            cell.messageImageView.isHidden = true
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        // get estimated height
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            //h1 / w1 = h2 / w2
            // solve for h1
            // h1 = h2 / w2 * w1
            
            height = CGFloat(imageHeight / imageWidth * 200)
            
        }
        
        let width = UIScreen.main.bounds.width
        
        return .init(width: width, height: height)
    }
}

extension ChatLogController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}

extension ChatLogController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard let image = image else {
            return
        }
        
        uploadImageToFirebase(image: image)
    }
}
