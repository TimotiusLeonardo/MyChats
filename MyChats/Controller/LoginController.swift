//
//  LoginController.swift
//  MyChats
//
//  Created by Timotius Leonardo Lianoto on 05/02/22.
//

import UIKit

class LoginController: UIViewController {
    
    let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logoIDN")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view.addSubview(inputContainerView)
        let inputContainerViewConstraints = [
            inputContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inputContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24),
            inputContainerView.heightAnchor.constraint(equalToConstant: 150)
        ]
        
        inputContainerView.addSubview(nameTextField)
        let nameTextFieldConstraints = [
            nameTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 12),
            nameTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 0),
            nameTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
            nameTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        ]
        
        inputContainerView.addSubview(nameSeperatorView)
        let nameSeperatorViewConstraints = [
            nameSeperatorView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor),
            nameSeperatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            nameSeperatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
            nameSeperatorView.heightAnchor.constraint(equalToConstant: 1)
        ]
        
        inputContainerView.addSubview(emailTextField)
        let emailTextFieldConstraints = [
            emailTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 12),
            emailTextField.topAnchor.constraint(equalTo: nameSeperatorView.bottomAnchor, constant: 0),
            emailTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
            emailTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        ]
        
        inputContainerView.addSubview(emailSeperatorView)
        let emailSeperatorViewConstraints = [
            emailSeperatorView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor),
            emailSeperatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
            emailSeperatorView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
            emailSeperatorView.heightAnchor.constraint(equalToConstant: 1)
        ]
        
        inputContainerView.addSubview(passwordTextField)
        let passwordTextFieldConstraints = [
            passwordTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 12),
            passwordTextField.topAnchor.constraint(equalTo: emailSeperatorView.bottomAnchor, constant: 0),
            passwordTextField.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor),
            passwordTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor, multiplier: 1/3)
        ]
        
        view.addSubview(loginRegisterButton)
        let loginRegisterButtonConstraints = [
            loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginRegisterButton.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 12),
            loginRegisterButton.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor, constant: 0),
            loginRegisterButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        view.addSubview(profileImageView)
        let profileImageViewConstraints = [
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -12),
            profileImageView.widthAnchor.constraint(equalToConstant: 150),
            profileImageView.heightAnchor.constraint(equalToConstant: 150)
        ]
        
        NSLayoutConstraint.activate(inputContainerViewConstraints)
        NSLayoutConstraint.activate(loginRegisterButtonConstraints)
        NSLayoutConstraint.activate(nameTextFieldConstraints)
        NSLayoutConstraint.activate(nameSeperatorViewConstraints)
        NSLayoutConstraint.activate(emailTextFieldConstraints)
        NSLayoutConstraint.activate(emailSeperatorViewConstraints)
        NSLayoutConstraint.activate(passwordTextFieldConstraints)
        NSLayoutConstraint.activate(profileImageViewConstraints)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
