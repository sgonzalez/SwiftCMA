//
//  ViewController.swift
//  SwiftCMAES
//
//  Created by Santiago Gonzalez on 4/13/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		
		
		
		
		/*
		DispatchQueue.global().async {
		
			// Solution variables.
			let startSolution = Vector(repeating: 0.5, count: 10)
			//		let startSolution = [Double.random(in: -5.0...5.0), Double.random(in: -5.0...5.0), Double.random(in: -5.0...5.0),
			//							 Double.random(in: -5.0...5.0), Double.random(in: -5.0...5.0), Double.random(in: -5.0...5.0),
			//							 Double.random(in: -5.0...5.0), Double.random(in: -5.0...5.0), Double.random(in: -5.0...5.0),
			//							 Double.random(in: -5.0...5.0)]
			let fitness = SphereFitnessEvaluator()
			
			// Hyperparameters.
			let populationSize = Int(4+floor(3*log(Double(startSolution.count))))
			let varSpan = 10.0 // (max - min) of all inputs.
			let stepSigma = 0.5 //FIXME//0.3 * varSpan // from Kaitlin.
			
			let cmaes = CMAES(startSolution: startSolution, populationSize: populationSize, stepSigma: stepSigma)
			for i in 0..<100 {
				//			print(cmaes.C.eigenvalues.first ?? [])
				//			print(sqrt(cmaes.xmean.squaredMagnitude))
				cmaes.epoch(evaluator: fitness)
				print(cmaes.bestSolution!.1)
			}
			
		}*/
		
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

