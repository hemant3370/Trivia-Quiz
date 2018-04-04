//
//  TimerView.swift
//  Quiz
//
//  Created by Hemant Singh on 28/03/18.
//  Copyright © 2018 Hemant. All rights reserved.
//

import UIKit

class TimerView: UIProgressView {
    
    public override var progress: Float {
        didSet {
            if progress < 0.5 {
                self.progressTintColor = .red
            }
            else{
                self.progressTintColor = .green
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
