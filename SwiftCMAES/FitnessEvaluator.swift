//
//  FitnessEvaluator.swift
//  SwiftCMAES
//
//  Created by Santiago Gonzalez on 4/13/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import Foundation

protocol FitnessEvaluator {
	associatedtype Genome
	func fitnessFor(genome: Genome, solutionCallback: (Genome, Double) -> ()) -> Double
}


struct SphereFitnessEvaluator: FitnessEvaluator {
	typealias Genome = Vector
	
	func fitnessFor(genome: Vector, solutionCallback: (Vector, Double) -> ()) -> Double {
		let diff = genome.squaredMagnitude // Distance from origin is the error.
		if diff < 0.01 {
			solutionCallback(genome, diff)
		}
		return genome.squared.sum
	}
}

struct RastriginFitnessEvaluator: FitnessEvaluator {
	typealias Genome = Vector
	
	func rastrigin(invec: Vector) -> Double {
		let sumTerms = invec.map { $0 * $0 - 10.0 * cos(2.0 * Double.pi * $0) }
		let summedTerm = sumTerms.reduce(0.0, { $0 + $1 })
		return 10.0 * Double(invec.count) + summedTerm
	}
	
	func fitnessFor(genome: Vector, solutionCallback: (Vector, Double) -> ()) -> Double {
		let diff = genome.squaredMagnitude // Distance from origin is the error.
		if diff < 0.1 {
			solutionCallback(genome, diff)
		}
		return rastrigin(invec: genome)
	}
}
