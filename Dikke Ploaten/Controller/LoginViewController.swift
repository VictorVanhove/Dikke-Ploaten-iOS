//
//  LoginViewController.swift
//  Dikke Ploaten
//
//  Created by Victor Vanhove on 14/03/2019.
//  Copyright © 2019 bazookas. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var lblEmail: UILabel!
	@IBOutlet weak var txtEmail: UITextField!
	@IBOutlet weak var lblPassword: UILabel!
	@IBOutlet weak var txtPassword: UITextField!
	weak var activeField: UITextField?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		// Script for importing discogsalbums to Firebase
//		Database.shared.importDiscogsDocumentsToFirebase { documentID in
//			Database.shared.importDiscogsAlbumsFromDocumentToFirebase(documentID: documentID)
//		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Add observers
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		// Remove observers
		NotificationCenter.default.removeObserver(keyboardWillShow)
		NotificationCenter.default.removeObserver(keyboardWillHide)
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		self.activeField = nil
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		self.activeField = textField
	}
	
	// Change size of scrollView and scroll to field
	@objc func keyboardWillShow(notification: NSNotification) {
		if let activeField = self.activeField, let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
			self.scrollView.contentInset = contentInsets
			self.scrollView.scrollIndicatorInsets = contentInsets
			var aRect = self.view.frame
			aRect.size.height -= keyboardSize.size.height
			if !aRect.contains(activeField.frame.origin) {
				self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
			}
		}
	}
	
	// Undo the above
	@objc func keyboardWillHide(notification: NSNotification) {
		let contentInsets = UIEdgeInsets.zero
		self.scrollView.contentInset = contentInsets
		self.scrollView.scrollIndicatorInsets = contentInsets
	}
	
	// MARK: - Actions
	@IBAction func logUserIn(_ sender: Any) {
		if !validForm() {
			let alertMessage = "fields_not_all_filled".localized()
			showAlert(alertMessage: alertMessage)
		} else if !isValidEmail() {
			let alertMessage = "bad_email".localized()
			showAlert(alertMessage: alertMessage)
		} else {
			// Log user in
			Auth.auth().signIn(withEmail: txtEmail.text!, password: txtPassword.text!) { _, error in
				if error == nil {
					self.performSegue(withIdentifier: "loginToHome", sender: self)
				} else {
					// Error while logging in
					let err = (error! as NSError).userInfo["error_name"]! as! String
					var alertMessage = NSLocalizedString("", comment: "")
					switch err {
					case "ERROR_USER_NOT_FOUND":
						alertMessage = "no_user".localized()
					case "ERROR_WRONG_PASSWORD":
						alertMessage = "wrong_password".localized()
					default:
						alertMessage = err
					}
					self.showAlert(alertMessage: alertMessage)
				}
			}
		}
	}
	
	// MARK: - Controlling the keyboard
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == txtEmail {
			txtPassword.becomeFirstResponder()
		} else {
			textField.resignFirstResponder()
			logUserIn(textField)
		}
		return true
	}
	
	// Check if form is valid
	private func validForm() -> Bool {
		// Check email
		lblEmail.textColor = UIColor.black
		if !txtEmail.text!.isEmpty {
			// Check password
			lblPassword.textColor = UIColor.black
			if !txtPassword.text!.isEmpty {
				return true
			}
		}
		return false
	}
	
	// Check if email is valid
	private func isValidEmail() -> Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		
		let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
		return emailTest.evaluate(with: txtEmail.text!)
	}
	
	// Show alert with specific message
	private func showAlert(alertMessage: String) {
		let alertController = UIAlertController(title: "whoops".localized(), message: alertMessage, preferredStyle: .alert)
		let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
		
		alertController.addAction(defaultAction)
		self.present(alertController, animated: true, completion: nil)
	}
}
