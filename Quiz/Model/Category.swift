//
//  Category.swift
//  Quiz
//
//  Created by Hemant Singh on 21/03/18.
//  Copyright © 2018 Hemant. All rights reserved.
//

import Foundation

struct Quiz {
    var category: Category
    var questions: [Question] = [Question]()
    var difficulty: DifficultyLevel
}

struct Question {
    
    var category : String!
    var correctAnswer : String!
    var difficulty : String!
    var incorrectAnswers : [String]!
    var question : String!
    var type : String!
    var options: [String]!
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        category = dictionary["category"] as? String
        correctAnswer = dictionary["correct_answer"] as? String
        difficulty = dictionary["difficulty"] as? String
        incorrectAnswers = dictionary["incorrect_answers"] as? [String] ?? []
        question = dictionary["question"] as? String
        type = dictionary["type"] as? String
        options = randomisedOptions()
    }
    private func randomisedOptions() -> [String] {
        var options = incorrectAnswers
        options?.append(correctAnswer)
        options?.shuffle()
        return options!
    }
}
struct Category {
    var id: Int
    var name: String
}
enum DifficultyLevel {
    case Easy
    case Medium
    case Hard
}
