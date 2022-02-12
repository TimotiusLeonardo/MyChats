//
//  LoginController+handlers.swift
//  MyChats
//
//  Created by Timotius Leonardo Lianoto on 12/02/22.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().signIn(withEmail: email,
                           password: password) { user, error in
            if error != nil {
                print(error?.localizedDescription ?? "Error Sign in With Firebase")
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let uid = result?.user.uid else {
                return
            }
            // Succes Register User
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).png")
            if let imageData = self.profileImageView.image?.pngData() {
                storageRef.putData(imageData, metadata: nil) { metadata, error in
                    if error != nil {
                        print(error?.localizedDescription ?? "error upload image")
                        return
                    }
                    
                    storageRef.downloadURL { url, error in
                        if let unwrapUrl = url?.absoluteString {
                            let values = ["name": name, "email": email, "profileImageUrl": unwrapUrl]
                            self.registerUserIntoDatabaseWithUID(uid: uid, values: values)
                        } else {
                            print(error?.localizedDescription ?? "Error get download URL from firebase")
                        }
                    }
                }
            }
        }
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: Any]) {
        let ref = Database.database().reference(fromURL: "https://mychats-cad9d-default-rtdb.asia-southeast1.firebasedatabase.app")
        let userParentRef = ref.child("users").child(uid)
        userParentRef.updateChildValues(values) { error, ref in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Canceled Picker")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    @objc func handleSegmentValueChanged() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        // Change Heigth of container View
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        nameTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor?.isActive = false
        
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor,
                                                                          multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor,
                                                                                  multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor,
                                                                            multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        passwordTextFieldHeightAnchor?.isActive = true
        emailTextFieldHeightAnchor?.isActive = true
        
        // Animate Constraint Change
        UIView.animate(withDuration: 0.2,
                       delay: 0, options: .curveLinear) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            //
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImageFromPicker = selectedImageFromPicker {
            profileImageView.image = selectedImageFromPicker
        }
        
        dismiss(animated: true, completion: nil)
    }
}
