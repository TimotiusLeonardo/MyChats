//
//  ChatLogController.swift
//  MyChats
//
//  Created by Timotius Leonardo Lianoto on 17/02/22.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

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
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    
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
        let _mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
        let picker = ImagePicker(presentationController: self, delegate: self, mediaTypes: _mediaTypes)
        return picker
    }()
    
    lazy var loadingBackgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundView
    }()
    
    lazy var loadingView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.color = .white
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
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
        view.backgroundColor = .white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = .init(top: 8, left: 0, bottom: 8, right: 0)
        collectionView.keyboardDismissMode = .interactive
        hideKeyboardWhenTappedAround()
        setupLoadingView()
    }
    
    private func setupLoadingView() {
        view.addSubview(loadingBackgroundView)
        loadingBackgroundView.addSubview(loadingView)
        
        let loadingBackgroundViewContraints = [
            loadingBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        let loadingIndicatorViewConstraints = [
            loadingView.centerXAnchor.constraint(equalTo: loadingBackgroundView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: loadingBackgroundView.centerYAnchor),
            loadingView.widthAnchor.constraint(equalToConstant: 50),
            loadingView.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(loadingBackgroundViewContraints)
        NSLayoutConstraint.activate(loadingIndicatorViewConstraints)
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
                    if !self.messages.isEmpty {
                        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
        }
    }
    
    private func uploadImageToFirebase(image: UIImage, completion: @escaping ((_ imageUrl: String) -> Void)) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("messages_images").child("\(imageName).png")
        
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            setViewToLoadingState(to: true)
            let uploadTask = ref.putData(uploadData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Failed to upload messages image: ", error.localizedDescription)
                    self.setViewToLoadingState(to: false)
                    return
                }
                
                ref.downloadURL { url, error in
                    if let error = error {
                        print("Failed to upload messages image: ", error.localizedDescription)
                        self.setViewToLoadingState(to: false)
                        return
                    }
                    
                    if let url = url?.absoluteString {
                        completion(url)
                    }
                }
            }
            
            uploadTask.observe(.success) { snapshot in
                self.setViewToLoadingState(to: false)
            }
        }
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        let values: [String: Any] = [
            "imageUrl": imageUrl,
            "imageWidth": image.size.width,
            "imageHeight": image.size.height,
        ]
        
        sendMessageWithProperties(properties: values)
    }
    
    private func sendMessageWithVideoUrl(videoUrl: String) {
        let values: [String: Any] = [
            "videoUrl": videoUrl
        ]
        
        sendMessageWithProperties(properties: values)
    }
    
    private func sendMessageWithProperties(properties: [String: Any]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        guard let toId = user?.id, let fromId = Auth.auth().currentUser?.uid else {
            print("No User ID is found to send message")
            return
        }
        let timestamp = Date().timeIntervalSince1970
        var values: [String: Any] = [
            "toId": toId,
            "fromId": fromId,
            "timestamp": timestamp
        ]
        
        properties.forEach({ values[$0] = $1})
        
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
        guard let text = inputTextField.text, !text.isEmpty else {
            print("Input text is contain NO TEXT, please add some text to send to another user.")
            return
        }

        let properties = ["text": text]
        sendMessageWithProperties(properties: properties)
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
        cell.message = message
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
        
        if let messageVideoUrl = message.videoUrl {
            if let messageImageUrl = message.imageUrl {
                cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
                cell.messageImageView.isHidden = false
                cell.bubbleView.backgroundColor = .lightGray
                cell.playButton.isHidden = false
                cell.videoUrl = URL(string: messageVideoUrl)
            }
        } else if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .lightGray
            cell.playButton.isHidden = true
        } else {
            cell.messageImageView.isHidden = true
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.playButton.isHidden = true
        }
        
        cell.chatLogController = self
    }
    
    private func setViewToLoadingState(to isLoading: Bool) {
        if isLoading {
            loadingView.startAnimating()
            inputAccessoryView?.isHidden = true
        } else {
            loadingView.stopAnimating()
            inputAccessoryView?.isHidden = false
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.loadingBackgroundView.alpha = isLoading ? 0.8 : 0
        } completion: { _ in
            //
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let messageCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ChatMessageCell
        
        var height: CGFloat = 80
        // get estimated height
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
            if let messageCell = messageCell {
                messageCell.textView.isHidden = false
            }
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            //h1 / w1 = h2 / w2
            // solve for h1
            // h1 = h2 / w2 * w1
            
            height = CGFloat(imageHeight / imageWidth * 200)
            if let messageCell = messageCell {
                messageCell.textView.isHidden = true
            }
        }
        
        let width = UIScreen.main.bounds.width
        
        return .init(width: width, height: height)
    }
    
    func performZoomInForImageView(imageView: UIImageView) {
        startingFrame = imageView.superview?.convert(imageView.frame, to: nil)
        if let startingFrame = self.startingFrame {
            let zoomingImageView = UIImageView(frame: startingFrame)
            zoomingImageView.backgroundColor = .red
            zoomingImageView.image = imageView.image
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
            
            if let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first {
                
                blackBackgroundView = UIView(frame: keyWindow.frame)
                if let blackBackgroundView = blackBackgroundView {
                    blackBackgroundView.backgroundColor = .black
                    blackBackgroundView.alpha = 0
                    keyWindow.addSubview(blackBackgroundView)
                    
                    keyWindow.addSubview(zoomingImageView)
                    UIView.animate(withDuration: 0.5,
                                   delay: 0,
                                   usingSpringWithDamping: 1,
                                   initialSpringVelocity: 1,
                                   options: .curveEaseOut) {
                        blackBackgroundView.alpha = 0.8
                        self.inputContainerView.alpha = 0
                        // h2/w1 = h1 / w1
                        // h2 = h1 / w1 * w1
                        
                        let height = startingFrame.height / startingFrame.width * keyWindow.frame.width
                        
                        zoomingImageView.frame = .init(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                        zoomingImageView.center = keyWindow.center
                    } completion: { _ in
                        // do nothing
                    }

                    UIView.animate(withDuration: 0.3,
                                   delay: 0,
                                   options: .curveEaseOut,
                                   animations: {
                        
                    }, completion: nil)
                }
            }
        }
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 1,
                           options: .curveEaseOut) {
                if let startingFrame = self.startingFrame {
                    zoomOutImageView.frame = startingFrame
                    self.blackBackgroundView?.alpha = 0
                    zoomOutImageView.layer.cornerRadius = 16
                    zoomOutImageView.clipsToBounds = true
                    self.inputContainerView.alpha = 1
                }
            } completion: { completed in
                zoomOutImageView.removeFromSuperview()
            }
        }
    }
    
    private func convertVideo(toMP4FormatForVideo inputURL: URL, outputURL: URL, handler: @escaping (AVAssetExportSession) -> Void) {
        try? FileManager.default.removeItem(at: outputURL)
        let asset = AVURLAsset(url: inputURL, options: nil)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously {
            handler(exportSession)
        }
        
    }
    
    private func getVideoDataFromUrl(url: URL) -> (fileName: String, fileData: Data?) {
        let name = "\(Int(Date().timeIntervalSince1970)).mp4"
        let path = NSTemporaryDirectory() + name
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let outputUrl = documentsURL?.appendingPathComponent(name) else {
            return ("",nil)
        }
        var uri = outputUrl
        convertVideo(toMP4FormatForVideo: url, outputURL: outputUrl) { session in
            guard let outputUrl = session.outputURL else {
                return
            }
            
            uri = outputUrl
            dispatchGroup.leave()
        }
        
        dispatchGroup.wait()
        
        let data = NSData(contentsOf: uri)
        
        do {
            try data?.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch {
            print(error)
        }
        
        return (name, data as Data?)
    }
    
    private func thumbnailImageforVideoUrl(videoUrl: URL) -> UIImage? {
        let asset = AVAsset(url: videoUrl)
        let assetGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try assetGenerator.copyCGImage(at: .init(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}

extension ChatLogController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}

extension ChatLogController: ImagePickerDelegate {
    func didSelect(image: UIImage?, videoUrl: URL?) {
        
        if let videoUrl = videoUrl {
            let fileData = getVideoDataFromUrl(url: videoUrl)
            let storageRef = Storage.storage().reference().child("message_videos").child(fileData.fileName)
            if let data = fileData.fileData {
                setViewToLoadingState(to: true)
                let uploadTask = storageRef.putData(data,
                                                    metadata: nil) { metadata, error in
                                    if let error = error {
                                        print("Failed upload video: ", error.localizedDescription)
                                        self.setViewToLoadingState(to: false)
                                        return
                                    }
                                    
                                    storageRef.downloadURL { url, error in
                                        if let url = url?.absoluteString {
                                            if let thumbnailImage = self.thumbnailImageforVideoUrl(videoUrl: videoUrl) {
                                                
                                                self.uploadImageToFirebase(image: thumbnailImage) { imageUrl in
                                                    let properties: [String: Any] = [
                                                        "imageWidth": thumbnailImage.size.width,
                                                        "imageHeight": thumbnailImage.size.height,
                                                        "videoUrl": url,
                                                        "imageUrl": imageUrl
                                                    ]
                                                    self.sendMessageWithProperties(properties: properties)
                                                }
                                            }
                                        }
                                    }
                                }
                uploadTask.observe(.progress) { snapshot in
                    if let completedUnitCount = snapshot.progress?.completedUnitCount {
                        self.navigationItem.title = String(completedUnitCount)
                    }
                }
                
                uploadTask.observe(.success) { snapshot in
                    self.navigationItem.title = self.user?.name
                    self.setViewToLoadingState(to: false)
                }
            }
            return
        }
        
        guard let image = image else {
            return
        }
        
        uploadImageToFirebase(image: image) { imageUrl in
            self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
        }
    }
}
