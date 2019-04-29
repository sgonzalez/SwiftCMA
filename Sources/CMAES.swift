//
//  CMAES.swift
//  SwiftCMAES
//
//  Created by Santiago Gonzalez on 4/13/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import Foundation

/// Embodies Covariance Matrix Adaptation Evolutionary Strategy (CMA-ES)
class CMAES {
	
	/// Returns a good population size for the specified number of dimensions.
	static func populationSize(forDimensions n: Int) -> Int {
		return Int(4+floor(3*log(Double(n))))
	}
	
	/// Dimensionality.
	let n: Int
	/// The number of solutions at each generation.
	let populationSize: Int
	/// Step size, standard deviation.
	var stepSigma: Double
	/// Points for recombination.
	let mu: Int
	/// Variance-effectiveness.
	let mueff: Double
	/// Recombination weights.
	var weights: Vector
	
	/// Time constant for cumulation for C.
	let cc: Double
	/// Time constant for cumulation for sigma control.
	let cs: Double
	/// Learning rate for rank-1 update of C.
	let c1: Double
	/// Learning rate for rank-mu update of C.
	let cmu: Double
	/// Damping constant for sigma.
	let damps: Double
	
	/// Distribution mean.
	var xmean: Vector
	/// The best.
	var bestSolution: (Vector, Double)?
	/// Evolution path for C; anisotropic evolution path.
	var pc: Vector
	/// Evolution path for sigma; isotropic evolution path.
	var ps: Vector
	/// Coordinate system definition.
	let B: Matrix
	/// Defines scaling.
	let D: Vector
	/// Covariance matrix.
	let C: DecomposingPositiveDefiniteMatrix
	/// Evaluation counter.
	var countEval: Double
	/// Gap to postpone eigendecomposition to achieve O(N**2) per eval.
	let lazyGapEvals: Double
	
	/// Initializes a new CMA-ES run.
	init(startSolution: Vector, populationSize: Int, stepSigma: Double) {
		n = startSolution.count
		xmean = startSolution
		self.populationSize = populationSize
		self.stepSigma = stepSigma
		
		// Selection parameter initialization.
		mu = populationSize / 2
		weights = Vector.zeros(populationSize)
		for i in 0..<populationSize {
			if i < mu {
				weights[i] = log(Double(mu) + 0.5) - log(Double(i) + 1.0)
			} else {
				weights[i] = 0.0
			}
		}
		let weightsSum = Vector(weights[0..<mu]).sum
		weights = weights.map { $0 / weightsSum } // Normalize.
		mueff = Vector(weights[0..<mu]).sum * Vector(weights[0..<mu]).sum / Vector(weights[0..<mu]).squared.sum
		
		// Adaptation parameter initialization.
		cc = (4.0 + mueff / Double(n)) / (Double(n) + 4.0 + 2.0 * mueff / Double(n))
		cs = (mueff + 2.0) / (Double(n) + mueff + 5.0)
		c1 = 2.0 / (pow(Double(n) + 1.3, 2) + mueff)
		cmu = min(1.0 - c1, 2.0 * (mueff - 2.0 + 1.0 / mueff) / (pow(Double(n) + 2.0, 2) + mueff))
		damps = 2.0 * mueff / Double(populationSize) + 0.3 + cs
		
		// Dynamic strategy parameter and constant initialization.
		pc = Vector.zeros(n)
		ps = Vector.zeros(n)
		B = Matrix.identity(dim: n)
		D = Vector.ones(n)
		C = DecomposingPositiveDefiniteMatrix(dim: n)
		countEval = 0.0
		lazyGapEvals = 0.5 * Double(n) * Double(populationSize) * (1.0 / (c1 + cmu)) / (Double(n) * Double(n)) // 0.5 is chosen such that eig takes 2 times the time of tell in >= 20-D		
	}
	
	typealias SolutionCallback = (Vector, Double) -> ()
	
	/// A convenient wrapper for `epoch` that takes an objective evaluator.
	func epoch<E: ObjectiveEvaluator>(evaluator: inout E, solutionCallback: @escaping SolutionCallback) where E.Genome == Vector {
		epoch(valuesForCandidates: { candidateSolutions, innerSolutionCallback in
			return candidateSolutions.map { solution in
				return evaluator.objective(genome: solution, solutionCallback: innerSolutionCallback)
			}
		}, solutionCallback: solutionCallback)
	}
	
	/// Performs an evolutionary epoch.
	func epoch(valuesForCandidates: ([Vector], @escaping SolutionCallback) -> ([Double]), solutionCallback: @escaping SolutionCallback) {
		// Generate offspring.
		C.updateEigensystem(currentEval: countEval, lazyGapEvals: lazyGapEvals)
		var candidateSolutions = [Vector]()
		for _ in 0..<populationSize {
			let z = C.eigenvalues.map { stepSigma * sqrt($0) * Double.randomGaussian(mu: 0.0, sigma: 1.0) }
			let y = C.eigenbasis.dot(vec: z)
			candidateSolutions.append(xmean + y)
		}
		
		// Evaluate fitnesses.
		var fitnesses = valuesForCandidates(candidateSolutions, solutionCallback)
		
		// Bookkeeping.
		countEval += Double(fitnesses.count)
		
		// Sort by fitness.
		candidateSolutions = zip(candidateSolutions, fitnesses).sorted(by: { $1.1 > $0.1 }).map { $0.0 }
		fitnesses = fitnesses.sorted(by: { $1 > $0 })
		bestSolution = (candidateSolutions.first!, fitnesses.first!)
		
		// Recombination.
		let xold = xmean
		xmean = (Array(candidateSolutions.prefix(mu)) as Matrix).dot(vec: Array(weights.prefix(mu)), transpose: true)
		
		// Cumulation.
		let y = xmean - xold
		let z = C.invsqrt.dot(vec: y)
		let csn = sqrt(cs * (2.0 - cs) * mueff) / stepSigma
		ps = ps.indexedMap { (1.0 - cs) * $1 + csn * z[$0] } // Update evolution path.
		let ccn = sqrt(cc * (2.0 - cc) * mueff) / stepSigma
		let hsig: Bool = (ps.squared.sum / Double(n) / (1.0 - pow(1.0 - cs, 2.0 * countEval / Double(populationSize)))) < 2.0 + 4.0 / (Double(n) + 1.0) // Turn off rank-one accumulation when sigma increases quickly.
		let hsigValue = hsig ? 1.0 : 0.0
		pc = pc.indexedMap { (1.0 - cc) * $1 + ccn * hsigValue * y[$0] } // Update evolution path.
		
		// Adapt covariance matrix C.
		let c1a: Double = c1 * (1.0 - (1.0 - hsigValue * hsigValue) * cc * (2.0 - cc))
		C.matrix.multiply(1.0 - c1a - cmu * weights.sum)
		C.matrix.addOuterProduct(vec: pc, multiplier: c1)
		for k in 0..<weights.count { // Rank-mu update.
			if weights[k] < 0 { // Ensure positive-definite.
				weights[k] *= Double(n) * pow(stepSigma / C.mahalanobisDistance(dx: candidateSolutions[k] - xold), 2)
			}
			C.matrix.addOuterProduct(vec: candidateSolutions[k] - xold, multiplier: weights[k] * cmu / (stepSigma * stepSigma))
		}
		
		// Adapt sigma.
		let cn = cs / damps
		let sumSquarePs = ps.squared.sum
		stepSigma *= exp(min(1.0, cn * (sumSquarePs / Double(n) - 1.0) / 2.0))
		
	}
}