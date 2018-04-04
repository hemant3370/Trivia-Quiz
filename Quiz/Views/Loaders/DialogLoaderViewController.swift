//
//  DialogLoaderViewController.swift
//  Travolution
//
//  Created by Hemant Singh on 22/12/17.
//  Copyright © 2017 Zillious Solutions. All rights reserved.
//

import UIKit

class DialogLoaderViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loderMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.tintColor = .black
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    override func viewWillDisappear(_ animated: Bool) {
        if animated {view.backgroundColor = UIColor.clear.withAlphaComponent(0.0)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
    

}
