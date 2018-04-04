//
//  VCExt.swift
//  Quiz
//
//  Created by Hemant Singh on 23/03/18.
//  Copyright © 2018 Hemant. All rights reserved.
//

import UIKit
import RxSwift

extension UIViewController {
    var activityIndicatorTag: Int { return 999999 }
    func showLoader(message: String = "Loading...", completion: @escaping (() -> ())){
        DispatchQueue.main.async {
            let loader: DialogLoaderViewController = DialogLoaderViewController()
            loader.providesPresentationContextTransitionStyle = true
            loader.definesPresentationContext = true
            loader.modalPresentationStyle = .overCurrentContext
            self.present(loader, animated: true, completion: {
                completion()
            })
        }
    }
    
    func showLoader(message: String = "Loading..."){
        DispatchQueue.main.async {
            let loader: DialogLoaderViewController = DialogLoaderViewController()
            loader.providesPresentationContextTransitionStyle = true
            loader.definesPresentationContext = true
            loader.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
            self.present(loader, animated: true, completion: nil)
        }
    }
    func hideLoader(){
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func hideLoader(completion: @escaping (() -> ())){
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                completion()
            })
        }
    }
    func startActivityIndicator(
        style: UIActivityIndicatorViewStyle = .whiteLarge,
        location: CGPoint? = nil) {
        
        let loc = location ?? self.view.center
        DispatchQueue.main.async {
            
            //Create the activity indicator
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: style)
            //Add the tag so we can find the view in order to remove it later
            
            activityIndicator.tag = self.activityIndicatorTag
            //Set the location
//            activityIndicator.color = ThemeManager.sharedInstance.getActiveTheme().primaryColorDark
            activityIndicator.center = loc
            activityIndicator.hidesWhenStopped = true
            //Start animating and add the view
            
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
        }
    }
    func stopActivityIndicator() {
        DispatchQueue.main.async  {
            if let activityIndicator = self.view.subviews.filter(
                { $0.tag == self.activityIndicatorTag}).first as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
