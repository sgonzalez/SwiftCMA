//
//  Matrix.swift
//  SwiftCMAES
//
//  Created by Santiago Gonzalez on 4/29/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import Foundation

/// Matrices are row-major, 2D arrays of floating-point numbers.
public typealias Matrix = [Vector]

extension Matrix {
	/// Returns a new identity matrix of the specified size.
	public static func identity(dim: Int) -> Matrix {
		var mat = Matrix(repeating: Vector.zeros(dim), count: dim)
		for i in 0..<mat.count {
			mat[i][i] = 1.0
		}
		return mat
	}
	
	/// Creates a new, square matrix from a 1D, row-major list.
	public init(fromList list: Vector, dimension: Int) {
		self = (0..<dimension).map { i in
			return (0..<dimension).map { j in
				return list[i*dimension + j]
			}
		}
	}
	
	/// Returns the dot product of the matrix with the specified vector.
	public func dot(vec: Vector, transpose: Bool = false) -> Vector {
		var out = Vector.zeros(transpose ? self[0].count : self.count)
		for i in 0..<out.count {
			let sumVec = Vector.zeros(vec.count)
			out[i] = sumVec.indexedMap { j, x in
				return self[transpose ? j : i][transpose ? i : j] * vec[j]
				}.sum
		}
		return out
	}
	
	/// Performs element-wise multiplication.
	public mutating func multiply(_ scalar: Double) {
		for i in 0..<count {
			self[i].multiply(scalar)
		}
	}
	
	/// Adds the outer product of the specified vector with itself to the
	/// matrix, with an optional multiplier.
	public mutating func addOuterProduct(vec: Vector, multiplier: Double = 1.0) {
		for i in 0..<count {
			for j in 0..<self[0].count {
				self[i][j] += multiplier * vec[i] * vec[j]
			}
		}
	}
}

public func + (left: Matrix, right: Matrix) -> Matrix {
	return left.indexedMap { $1 + right[$0] }
}

extension Collection where Self.Iterator.Element: RandomAccessCollection {
	/// Transposes 2D arrays (i.e., matrices).
	public func transposed() -> [[Self.Iterator.Element.Iterator.Element]] {
		guard let firstRow = self.first else { return [] }
		return firstRow.indices.map { index in
			self.map{ $0[index] }
		}
	}
}

