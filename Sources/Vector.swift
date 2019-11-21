//
//  Vector.swift
//  SwiftCMAES
//
//  Created by Santiago Gonzalez on 4/13/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import Foundation

/// Vectors are arrays of floating-point numbers.
public typealias Vector = [Double]

extension Vector {
	/// Returns a vector of zeros.
	public static func zeros(_ dim: Int) -> Vector {
		return Vector(repeating: 0.0, count: dim)
	}
	
	/// Returns a vector of ones.
	public static func ones(_ dim: Int) -> Vector {
		return Vector(repeating: 1.0, count: dim)
	}
	
	/// Returns the vector's squared magnitude.
	public var squaredMagnitude: Double {
		return self.reduce(0, { $0 + $1 * $1 })
	}
	
	/// Returns a normalized version of the vector.
	public var normalized: Vector {
		return self / sqrt(squaredMagnitude)
	}
	
	/// Returns the sum of the vector's elements.
	public var sum: Double {
		return self.reduce(0, { $0 + $1 })
	}
	
	/// Returns a vector with squared elements.
	public var squared: Vector {
		return self.map { $0 * $0 }
	}
	
	/// Performs element-wise multiplication.
	public mutating func multiply(_ scalar: Double) {
		for i in 0..<count {
			self[i] *= scalar
		}
	}
}

public func - (left: Vector, right: Vector) -> Vector {
	return left.indexedMap { $1 - right[$0] }
}

public func + (left: Vector, right: Vector) -> Vector {
	return left.indexedMap { $1 + right[$0] }
}

public func / (left: Vector, right: Double) -> Vector {
	return left.map { $0 / right }
}
