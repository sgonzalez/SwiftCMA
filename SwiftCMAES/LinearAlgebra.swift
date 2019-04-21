//
//  LinearAlgebra.swift
//  SwiftCMAES
//
//  Created by Santiago Gonzalez on 4/13/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import Foundation

typealias Vector = [Double]

extension Vector {
	/// Returns a vector of zeros.
	static func zeros(_ dim: Int) -> Vector {
		return Vector(repeating: 0.0, count: dim)
	}
	
	/// Returns a vector of ones.
	static func ones(_ dim: Int) -> Vector {
		return Vector(repeating: 1.0, count: dim)
	}
	
	/// Returns the vector's squared magnitude.
	var squaredMagnitude: Double {
		return self.reduce(0, { $0 + $1 * $1 })
	}
	
	/// Returns a normalized version of the vector.
	var normalized: Vector {
		return self / sqrt(squaredMagnitude)
	}
	
	/// Returns the sum of the vector's elements.
	var sum: Double {
		return self.reduce(0, { $0 + $1 })
	}
	
	var squared: Vector {
		return self.map { $0 * $0 }
	}
	
	/// Performs element-wise multiplication.
	mutating func multiply(_ scalar: Double) {
		for i in 0..<count {
			self[i] *= scalar
		}
	}
}

func - (left: Vector, right: Vector) -> Vector {
	return left.enumerated().map { $1 - right[$0] }
}

func + (left: Vector, right: Vector) -> Vector {
	return left.enumerated().map { $1 + right[$0] }
}

func / (left: Vector, right: Double) -> Vector {
	return left.map { $0 / right }
}

typealias Matrix = [Vector]

// NOTE: Matrices are treated in row-major order.
extension Matrix {
	/// Returns a new identity matrix of the specified size.
	static func identity(dim: Int) -> Matrix {
		var mat = Matrix(repeating: Vector.zeros(dim), count: dim)
		for i in 0..<mat.count {
			mat[i][i] = 1.0
		}
		return mat
	}
	
	/// Creates a new, square matrix from a 1D, row-major list.
	init(fromList list: Vector, dimension: Int) {
		self = (0..<dimension).map { i in
			return (0..<dimension).map { j in
				return list[i*dimension + j]
			}
		}
	}
	
	/// Returns the dot product of the matrix with the specified vector.
	func dot(vec: Vector, transpose: Bool = false) -> Vector {
		var out = Vector.zeros(transpose ? self[0].count : self.count)
		for i in 0..<out.count {
			let sumVec = Vector.zeros(vec.count)
			out[i] = sumVec.enumerated().map { j, x in
				return self[transpose ? j : i][transpose ? i : j] * vec[j]
			}.sum
		}
		return out
	}
	
	/// Performs element-wise multiplication.
	mutating func multiply(_ scalar: Double) {
		for i in 0..<count {
			self[i].multiply(scalar)
		}
	}
	
	/// Adds the outer product of the specified vector with itself to the matrix, with an optional multiplier.
	mutating func addOuterProduct(vec: Vector, multiplier: Double = 1.0) {
		for i in 0..<count {
			for j in 0..<self[0].count {
				self[i][j] += multiplier * vec[i] * vec[j]
			}
		}
	}
}

func + (left: Matrix, right: Matrix) -> Matrix {
	return left.enumerated().map { $1 + right[$0] }
}

extension Collection where Self.Iterator.Element: RandomAccessCollection {
	/// Transposes 2D arrays (i.e., matrices)
	func transposed() -> [[Self.Iterator.Element.Iterator.Element]] {
		guard let firstRow = self.first else { return [] }
		return firstRow.indices.map { index in
			self.map{ $0[index] }
		}
	}
}

