//
//  LoginViewController.swift
//  Quiz
//
//  Created by Hemant Singh on 27/03/18.
//  Copyright © 2018 Hemant. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import Alamofire
import Moya
import RxSwift

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    let disposeBag = DisposeBag()
    static let tokenKey = "opentdbToken"
    var gradiant: CAGradientLayer = {
        //Gradiant for the background view
        let blue = UIColor(red: 69/255, green: 127/255, blue: 202/255, alpha: 1.0).cgColor
        let purple = UIColor(red: 166/255, green: 172/255, blue: 236/255, alpha: 1.0).cgColor
        let gradiant = CAGradientLayer()
        gradiant.colors = [purple, blue]
        gradiant.startPoint = CGPoint(x: 0.5, y: 0.18)
        return gradiant
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        gradient()
        //    let _ = UserDefaults.standard.string(forKey: LoginViewController.tokenKey)
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
        // Do any additional setup after loading the view.
        let signinButton = GIDSignInButton(frame: CGRect(x: 0, y: 0, width: view.frame.width - 64, height: 44))
        self.view.addSubview(signinButton)
        signinButton.center = view.center
        checkIfUserIsSignedIn()
    }
    private func checkIfUserIsSignedIn() {
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                // user is signed in
                self.performSegue(withIdentifier: "toHome", sender: nil)
            } else {
                // user is not signed in
            }
        }
    }
    func gradient() {
        //Add the gradiant to the view:
//        self.gradiant.frame = self.view.bounds
//        self.view.layer.addSublayer(gradiant)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let _ = error {
            // ...
            
            return
        }
        self.showLoader()
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { [weak self] (user, error) in
            self?.hideLoader()
        }
    }
    func createToken(user: User){
        TVAPIProvider.rx.request(Travolution.CREATETOKEN).subscribe ({ [weak self] (event) in
                    switch event {
                    case .success(let response):
                        if let json = try? response.mapJSON() {
                            if let dict = json as? [String: Any], let token = dict["token"] as? String {
                                UserDefaults.standard.set(token, forKey: LoginViewController.tokenKey)
                                Alamofire.request("https://us-central1-minimal-news.cloudfunctions.net/addMessage", method: .get, parameters: ["token": token, "userId": user.uid], encoding: URLEncoding.queryString, headers: nil).response(completionHandler: { [weak self] (response) in
                                    self?.hideLoader()
                                    if response.response?.statusCode == 200 {
                                        self?.performSegue(withIdentifier: "toHome", sender: nil)
                                    }
                                })
                            }
                        }
                    case .error:
                        self?.hideLoader()
                        break
                    }
        }).disposed(by: disposeBag)
    }
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

