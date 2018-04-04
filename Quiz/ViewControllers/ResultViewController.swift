//
//  ResultViewController.swift
//  Quiz
//
//  Created by Hemant Singh on 26/03/18.
//  Copyright © 2018 Hemant. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreBar: UIProgressView!
    var quizManager: QuizManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        let score = quizManager.score()
        scoreLabel.text = "\(score.0)/\(score.1)"
        scoreBar.transform = scoreBar.transform.scaledBy(x: 1, y: 10)
        scoreBar.progress = Float(score.0) / Float(score.1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
