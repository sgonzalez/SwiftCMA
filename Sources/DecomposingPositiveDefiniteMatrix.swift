//
//  DecomposingPositiveDefiniteMatrix.swift
//  SwiftCMAES
//
//  Created by Santiago Gonzalez on 4/13/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import Foundation

/// A symmetric, positive-definite matrix that maintains its own eigendecomposition.
class DecomposingPositiveDefiniteMatrix {
	
	/// The backing matrix.
	var matrix: Matrix
	/// The matrix's dimension.
	var n: Int
	
	/// The matrix's eigenbasis. Each column is a base vector.
	var eigenbasis: Matrix
	/// The matrix's eigenvalues.
	var eigenvalues: Vector
	
	/// The "squooshinnes" of the distribution; the ratio of the largest eigenvalue to the smallest eigenvalue. More spherical distributions
	/// have a smaller condition number.
	var conditionNumber: Double
	var invsqrt: Matrix
	var updatedEval: Double
	
	/// Creates a new matrix of the specified dimension.
	init(dim: Int) {
		n = dim
		matrix = Matrix.identity(dim: n)
		eigenbasis = Matrix.identity(dim: n)
		eigenvalues = Vector.ones(n)
		conditionNumber = 1.0
		invsqrt = Matrix.identity(dim: n)
		updatedEval = 0.0
	}
	
	/// Performs eigendecomposition if `currentEval > lazyGapEvals + updatedEval`.
	func updateEigensystem(currentEval: Double, lazyGapEvals: Double) {
		//guard currentEval > lazyGapEvals + updatedEval else { return } // FIXME: uncomment
		
		enforceSymmetry()
		
		(eigenvalues, eigenbasis) = eigenDecompose(matrix)
		guard eigenvalues.min()! > 0 else {
			fatalError("Found negative eigenvalue!")
		}
		
		conditionNumber = eigenvalues.max()! / eigenvalues.min()!
		// Compute invsqrt(C) = C**(-1/2) = B D**(-1/2) B
		// O(n^3) and takes about 25% of the time of eig
		for i in 0..<n {
			for j in 0..<(i+1) {
				let sum = eigenvalues.indexedMap { k, eigenvalue in
					return eigenbasis[i][k] * eigenbasis[j][k] / sqrt(eigenvalue)
				}.sum
				invsqrt[i][j] = sum
				invsqrt[j][i] = sum
			}
		}
		
		updatedEval = currentEval
	}
	
	/// Returns the Mahalanobis distance to the specified vector from the
	/// distribution represented by this covariance matrix.
	func mahalanobisDistance(dx: Vector) -> Double {
		return sqrt(invsqrt.dot(vec: dx).squared.sum)
	}
	
	/// Enforces the matrix's symmetry.
	private func enforceSymmetry() {
		for i in 0..<n {
			for j in 0..<i {
				let avg = (matrix[i][j] + matrix[j][i]) / 2.0
				matrix[i][j] = avg
				matrix[j][i] = avg
			}
		}
	}
}
