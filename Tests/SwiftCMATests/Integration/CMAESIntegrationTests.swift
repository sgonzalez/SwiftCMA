//
//  CMAESIntegrationTests.swift
//  SwiftCMAESTests
//
//  Created by Santiago Gonzalez on 4/13/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import XCTest
import SwiftCMA

final class CMAESIntegrationTests: XCTestCase {

	func testCMAES() {
		
		// Solution variables.
		let startRangeBound: Double = 5.0
		let startSolution = [
			Double.random(in: -startRangeBound...startRangeBound),
			Double.random(in: -startRangeBound...startRangeBound),
			Double.random(in: -startRangeBound...startRangeBound)
		]
		var fitness = AckleyObjectiveEvaluator()
		
		// Hyperparameters.
		let populationSize = CMAES.populationSize(forDimensions: startSolution.count)
		let varSpan = startRangeBound * 2 // (max - min) of all inputs.
		let stepSigma = 0.3 * varSpan // from Kaitlin Maile.
		
		// Perform CMA-ES.
		let cmaes = CMAES(startSolution: startSolution, populationSize: populationSize, stepSigma: stepSigma)
		var solution: Vector?
		var solutionFitness: Double?
		var bestSolution: CMAES.EvaluatedSolution?
		for i in 0..<1000 {
			guard solution == nil else { break }
			cmaes.epoch(evaluator: &fitness) { newSolution, newFitness in
				solution = newSolution
				solutionFitness = newFitness
			}
			
			if bestSolution == nil || bestSolution!.value > cmaes.bestSolution!.value {
				bestSolution = cmaes.bestSolution
			}
			print("\(i):   \(cmaes.bestSolution!.value)")
		}

		// Print solution.
		if let solution = solution, let fitness = solutionFitness {
			print("Found solution with fitness \(fitness): \(solution)")
		} else {
			print("Failed to perfect solution.")
			print("Best: \(bestSolution!.value): \(bestSolution!.solution)")
			XCTFail()
		}
	}

	static var allTests = [
        ("testCMAES", testCMAES),
    ]
	
}

