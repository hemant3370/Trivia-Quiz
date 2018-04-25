//
//  ResultViewController.swift
//  Quiz
//
//  Created by Hemant Singh on 26/03/18.
//  Copyright © 2018 Hemant. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var otherScoreBar: UIProgressView!
    @IBOutlet weak var otherScoreLabel: UILabel!
    @IBOutlet weak var otherPlayerNameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreBar: UIProgressView!
    var quizManager: QuizManager!
    var otherScore: (Int, Int) = (0, 10)
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreBar.transform = scoreBar.transform.scaledBy(x: 1, y: 10)
        otherScoreBar.transform = otherScoreBar.transform.scaledBy(x: 1, y: 10)
        let score = quizManager.score()
        scoreLabel.text = "\(score.0)/\(score.1)"
        scoreBar.progress = Float(score.0) / Float(score.1)
        resultLabel.text = otherScore.0 > score.0 ? "You Lose :(" : "You Win :)"
        otherScoreLabel.text = "\(otherScore.0)/\(otherScore.1)"
        otherScoreBar.progress = Float(otherScore.0) / Float(otherScore.1)
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
