//
//  ExercisesTests.swift
//  ExercisesTests
//
//  Created by Aleksandra Lazarevic on 21.2.22..
//

import XCTest
@testable import Exercises

class ExercisesTests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {

    }

    
    func testGetAllExercises() throws {
        let allExercisesVC = AllExercisesViewController()
        allExercisesVC.getAllExercises { data in
        XCTAssertEqual(data.count, Config.pageLimit)
        }
    }
    
    func testGetAllVariations() throws {
        let exerciseDetailsVC = ExerciseDetailsViewController()
        var variations = exerciseDetailsVC.variations
        exerciseDetailsVC.getVariationsOfExercise(ids: [15, 17]) { receivedExercise in
            variations.append(receivedExercise)
            XCTAssertEqual(variations.count, 2)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
