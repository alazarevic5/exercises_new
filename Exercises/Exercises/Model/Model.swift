//
//  Model.swift
//  Exercises
//
//  Created by Aleksandra Lazarevic on 20.2.22..
//

import Foundation

// Instance contains array of exercises and number of exercises.
struct Root: Codable {
    var count: Int
    var exercises: [Exercise]
    
    private enum  CodingKeys: String, CodingKey { case count, exercises = "results" }
}

// Instance contains information about exercise.
struct Exercise: Codable {
    var id: Int
    var name: String
    var description: String
    var variations: [Int]
    var images: [ExerciseImage]
    
    private enum  CodingKeys: String, CodingKey { case id, name, description, variations, images }
}

// Instance represents an image of exercise. If image isMain it should be shown on the first page as image of exercise. Other images should be inside collection view (exercise details)
struct ExerciseImage: Codable {
    var imgPath: String
    var isMain: Bool
    
    private enum  CodingKeys: String, CodingKey { case imgPath = "image", isMain = "is_main" }
    
}
