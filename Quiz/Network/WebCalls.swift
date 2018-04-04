//
//  WebCalls.swift
//  Quiz
//
//  Created by Hemant Singh on 29/03/18.
//  Copyright © 2018 Hemant. All rights reserved.
//

import RxSwift
import Moya

class WebCalls {
    class func getNewToken(disposeBag: DisposeBag){
        TVAPIProvider.rx.request(Travolution.CREATETOKEN).subscribe ({ (event) in
            switch event {
            case .success(let response):
                if let json = try? response.mapJSON() {
                    if let dict = json as? [String: Any], let token = dict["token"] as? String {
                        UserDefaults.standard.set(token, forKey: LoginViewController.tokenKey)
                        
                    }
                }
            case .error:
                break
            }
        }).disposed(by: disposeBag)
    }
}
