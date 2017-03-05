//
//  LoginViewController.swift
//  DressCode
//
//  Created by Dameon D Bryant on 5/9/16.
//  Copyright © 2016 Dameon D Bryant. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import GoogleSignIn

class LoginViewController: UIViewController, LoginButtonDelegate {
    
    var currentUser: NSString!
    var currentUserEmail: NSString!
    var facebookLoginButton: LoginButton!
    
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        (UIApplication.shared.delegate as! AppDelegate).delegate = self
        
        isUserLoggedIn()
//        if (FBSDKAccessToken.current() != nil)
//        {
//            // User is already logged in, do work such as go to next view controller.
//            print("The user is already signed in")
//            
//            DispatchQueue.main.async {
//                self.performSegue(withIdentifier: "showTabView", sender: nil)
//            }
//            self.returnUserData()
//        }
//        else
//        {
//            let loginView : FBSDKLoginButton = FBSDKLoginButton()
//            self.view.addSubview(loginView)
//            loginView.center = self.view.center
//            loginView.readPermissions = ["public_profile", "email", "user_friends"]
//            loginView.delegate = self
//            
//        }
    }
    
    func isUserLoggedIn(){
        
        facebookLoginButton = LoginButton(readPermissions: [ReadPermission.publicProfile, ReadPermission.email, ReadPermission.userFriends ])
        facebookLoginButton.delegate = self
        facebookView.addSubview(facebookLoginButton)
        facebookLoginButton.center = CGPoint(x: facebookView.bounds.size.width / 2, y: facebookView.bounds.size.height / 2)
        
        //get user info via facebook graph
        let params = ["fields" : "email, name"]
        let graphRequest = GraphRequest(graphPath: "me", parameters: params)
        graphRequest.start {
            (urlResponse, requestResult) in
            
            switch requestResult {
            case .failed(let error):
                print("error in graph request:", error)
                break
            case .success(let graphResponse):
                if let responseDictionary = graphResponse.dictionaryValue {
                    print(responseDictionary)
                    let userName = (responseDictionary["email"]!)
                    
                    //Store user and user email address as UserDefaults
                    let userInfo = UserDefaults.standard
                    userInfo.setValue(userName, forKey: "UserName")
                }
            }
        }
        
        if (AccessToken.current != nil)
        {
            showMainTabView()
        }
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        
        self.performSegue(withIdentifier: "showTabView", sender: nil)
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
    }

    func showMainTabView() {
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showTabView", sender: nil)
        }
    }
    
}

// MARK: - GIDSignInUIDelegate, GIDSignInDelegate

extension LoginViewController: GIDSignInUIDelegate, GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            performSegue(withIdentifier: "showTabView", sender: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
}
