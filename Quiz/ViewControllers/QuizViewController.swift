//
//  QuizViewController.swift
//  Quiz
//
//  Created by Hemant Singh on 21/03/18.
//  Copyright © 2018 Hemant. All rights reserved.
//

import UIKit
import AVKit

class QuizViewController: UIViewController {
    @IBOutlet weak var timerBar: TimerView!
    @IBOutlet weak var optionsTableView: UITableView!
    var questions: [Question] = [Question]()
    var index: Int = 0
    var quizManager: QuizManager!
    var seconds = 10
    var timer = Timer()
    let speechSynth = AVSpeechSynthesizer()
    let wrong = AVSpeechUtterance(string: "Wrong!")
    let correct = AVSpeechUtterance(string: "Correct!")
    let timeUp = AVSpeechUtterance(string: "Time's Up!")
    override func viewDidLoad() {
        super.viewDidLoad()
        quizManager = QuizManager(questions: questions)
        optionsTableView.registerNibs(nibNames: ["OptionCell"])
        optionsTableView.estimatedRowHeight = 100
        optionsTableView.rowHeight = UITableViewAutomaticDimension
        timerBar.transform = timerBar.transform.scaledBy(x: 1, y: 10)
    }
    override func viewDidAppear(_ animated: Bool) {
        runTimer()
    }
    
    deinit {
        print("Quiz Deinitialized")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResult", let resultVC = segue.destination as? ResultViewController {
            resultVC.quizManager = self.quizManager
        }
    }
    func speak(speech: AVSpeechUtterance){
        if speechSynth.isSpeaking {
            speechSynth.stopSpeaking(at: .immediate)
        }
        speechSynth.speak(speech)
    }
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(QuizViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            speak(speech: timeUp)
            view.backgroundColor = .red
            nextQuestion()
        } else {
            seconds -= 1
            timerBar.progress = Float(seconds) / 10
        }
    }
    func nextQuestion(){
        self.timer.invalidate()
        if index == 9 {
            self.performSegue(withIdentifier: "toResult", sender: nil)
        }
        else{
            UIView.animate(withDuration: 0.5, delay: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.optionsTableView.alpha = 0
            }, completion: { (_) in
                self.view.backgroundColor = .white
                self.optionsTableView.alpha = 1
                self.index += 1
                self.optionsTableView.reloadData()
                self.seconds = 10
                self.timerBar.progress = Float(self.seconds) / 10
                self.runTimer()
            })
        }
    }
}
extension QuizViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Question \(index + 1):" : ""
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : questions[index].options.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as! OptionCell
            let question = questions[index]
//            let questionAudio = AVSpeechUtterance(string: question.question.convertHtml().string)
//            speak(speech: questionAudio)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.label.text = question.question.convertHtml().string
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as! OptionCell
            let question = questions[index]
            cell.selectionStyle = UITableViewCellSelectionStyle.default
            cell.label.text = question.options[indexPath.row].convertHtml().string
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let question = questions[index]
            let selectedOption = question.options[indexPath.row]
            let cell = tableView.cellForRow(at: indexPath) as! OptionCell
            if selectedOption == question.correctAnswer {
                speak(speech: correct)
                cell.cardView.backgroundColor = .green
            }
            else{
                speak(speech: wrong)
                quizManager.incorrectQuestion.append((question, question.options[indexPath.row]))
                cell.cardView.backgroundColor = .red
            }
            nextQuestion()
        }
    }
}
class QuizManager {
    var incorrectQuestion: [(Question, String)]!
    var questions: [Question] = [Question]()
    
    init(questions: [Question]) {
        self.questions = questions
        incorrectQuestion = [(Question, String)]()
    }
    func score() -> (Int, Int){ // score / Out of
        return (questions.count - incorrectQuestion.count, questions.count)
    }
    
}
