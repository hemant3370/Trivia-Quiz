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
class Question: Codable {
    let category, type, difficulty, question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    var options: [String]!
    
    enum CodingKeys: String, CodingKey {
        case category, type, difficulty, question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
        case options = "options"
    }
    init(fromDictionary dictionary: [String:Any]){
        category = dictionary["category"] as? String ?? ""
        correctAnswer = dictionary["correct_answer"] as? String ?? ""
        difficulty = dictionary["difficulty"] as? String ?? ""
        incorrectAnswers = dictionary["incorrect_answers"] as? [String] ?? []
        question = dictionary["question"] as? String ?? ""
        type = dictionary["type"] as? String ?? ""
        options = randomisedOptions()
    }
    private func randomisedOptions() -> [String] {
        var options = incorrectAnswers
        options.append(correctAnswer)
        options.shuffle()
        return options
    }
    init(category: String, type: String, difficulty: String, question: String, correctAnswer: String, incorrectAnswers: [String], options: [String]) {
        self.category = category
        self.type = type
        self.difficulty = difficulty
        self.question = question
        self.correctAnswer = correctAnswer
        self.incorrectAnswers = incorrectAnswers
        self.options = options
    }
    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.category = try values.decode(String.self, forKey: .category)
        self.type = try values.decode(String.self, forKey: .type)
        self.difficulty = try values.decode(String.self, forKey: .difficulty)
        self.question = try values.decode(String.self, forKey: .question)
        self.correctAnswer = try values.decode(String.self, forKey: .correctAnswer)
        self.incorrectAnswers = try values.decode([String].self, forKey: .incorrectAnswers)
        self.options = try values.decode([String].self, forKey: .options)
    }
}
// MARK: Convenience initializers

extension Question {
    convenience init(data: Data) throws {
        let me = try JSONDecoder().decode(Question.self, from: data)
        self.init(category: me.category, type: me.type, difficulty: me.difficulty, question: me.question, correctAnswer: me.correctAnswer, incorrectAnswers: me.incorrectAnswers, options: me.options)
    }
    
    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func jsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
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
