//
//  LoginViewController.swift
//  List Maker
//
//  Created by Shubham Jindal on 13/04/17.
//  Copyright © 2017 sjc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {

    //Outlets for the label,text fields and buttons
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginActivitySpinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginActivitySpinner.isHidden = true
        emailTextField.delegate = self
        passTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Method for return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Working of login button
    @IBAction func loginAction(_ sender: Any) {
        self.view.endEditing(true)
        showActivitySpinner(self.loginActivitySpinner, style: .gray)
        UdacityClient.sharedInstance().authenticateUser(username: emailTextField.text!, password: passTextField.text!) { (result, error) in
            if error != nil {
                self.showAlert(error!)
                self.hideActivitySpinner(self.loginActivitySpinner)
            } else {
                DispatchQueue.main.async {
                    
                    self.completeLogin()
                    self.hideActivitySpinner(self.loginActivitySpinner)
                }
            }
            
        }
    }
    
    //Working of signup button
    @IBAction func signupAction(_ sender: Any) {
         UIApplication.shared.open(URL(string: ConstantsUdacity.SignUpUrl)!, options: [:], completionHandler: nil)
    }
    
    //Method for logging in
    func completeLogin() {
        emailTextField.text = ""
        passTextField.text = ""
        if let mapAndTableTabController = storyboard?.instantiateViewController(withIdentifier: "ListViewController") {
            present(mapAndTableTabController, animated: true, completion: nil)
        }
        
    }
    
    //Show Activity Spinner
    func showActivitySpinner(_ spinner: UIActivityIndicatorView!, style: UIActivityIndicatorViewStyle) {
        DispatchQueue.main.async {
            let activitySpinner = spinner
            activitySpinner?.activityIndicatorViewStyle = style
            activitySpinner?.hidesWhenStopped = true
            activitySpinner?.isHidden = false
            activitySpinner?.startAnimating()
        }
    }
    
    //Hide Activity Spinner
    func hideActivitySpinner(_ spinner: UIActivityIndicatorView!) {
        DispatchQueue.main.async {
            let activitySpinner = spinner
            activitySpinner?.isHidden = true
            activitySpinner?.stopAnimating()
        }
    }
    
    //Method to show alerts
    func showAlert(_ error: String) {
        let alert = UIAlertController(title: "Error!", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Method to verify url
    func canVerifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
}

