//
//  EigenDecompositionTests.swift
//  SwiftCMAESTests
//
//  Created by Santiago Gonzalez on 4/13/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import XCTest
@testable import SwiftCMA

/// A helper to check for equality between floating-point numbers.
func epsilonEqual(_ a: Double, _ b: Double, epsilon: Double = 0.0001) -> Bool {
	return a > b - epsilon && a < b + epsilon
}

class EigenDecompositionTests: XCTestCase {

    func testBasicEigen() {
		let mat = [[5.0, 0.0], [0.0, 5.0]]
		let eig = eigenDecompose(mat)
		XCTAssertEqual(eig.0, [5.0, 5.0])
		XCTAssertEqual(eig.1, [[1.0, 0.0], [0.0, 1.0]])
    }
	
	func testIdentityEigen() {
		let mat = Matrix.identity(dim: 4)
		let eig = eigenDecompose(mat)
		XCTAssertEqual(eig.0, [1.0, 1.0, 1.0, 1.0])
		XCTAssertEqual(eig.1, [
			[1.0, 0.0, 0.0, 0.0],
			[0.0, 1.0, 0.0, 0.0],
			[0.0, 0.0, 1.0, 0.0],
			[0.0, 0.0, 0.0, 1.0]
		])
	}
	
	func testMoreComplexEigen() {
		let mat = Matrix([[2,-1,0],[-1,2,-1],[0,-1,2]])
		let eig = eigenDecompose(mat)
		let trueValues = [2.0-sqrt(2.0), 2.0, 2.0+sqrt(2.0)]
		let trueVecs = Matrix([[1, +sqrt(2.0), 1], [-1, 0, 1], [1, -sqrt(2.0), 1]]).map { $0.normalized }
		// Check eigenvalues.
		XCTAssertTrue(epsilonEqual(eig.0[0], trueValues[0]))
		XCTAssertTrue(epsilonEqual(eig.0[1], trueValues[1]))
		XCTAssertTrue(epsilonEqual(eig.0[2], trueValues[2]))
		// Check eigenvector 1.
		XCTAssertTrue(epsilonEqual(eig.1[0][0], -trueVecs[0][0]))
		XCTAssertTrue(epsilonEqual(eig.1[1][0], -trueVecs[0][1]))
		XCTAssertTrue(epsilonEqual(eig.1[2][0], -trueVecs[0][2]))
		// Check eigenvector 2.
		XCTAssertTrue(epsilonEqual(eig.1[0][1], trueVecs[1][0]))
		XCTAssertTrue(epsilonEqual(eig.1[1][1], trueVecs[1][1]))
		XCTAssertTrue(epsilonEqual(eig.1[2][1], trueVecs[1][2]))
		// Check eigenvector 3.
		XCTAssertTrue(epsilonEqual(eig.1[0][2], trueVecs[2][0]))
		XCTAssertTrue(epsilonEqual(eig.1[1][2], trueVecs[2][1]))
		XCTAssertTrue(epsilonEqual(eig.1[2][2], trueVecs[2][2]))
	}
	
	static var allTests = [
		("testBasicEigen", testBasicEigen),
		("testIdentityEigen", testIdentityEigen),
		("testMoreComplexEigen", testMoreComplexEigen),
    ]
	
}

/*
NOT A POSITIVE DEFINITE MATRIX, BUT MIGHT BE USEFUL IN THE FUTURE
let mat = Matrix([[1,2,3],[2,8,6],[3,6,16]])
let eig = eigenDecompose(mat)
let trueValues = [19.8931, 4.81458, 0.292346]
let trueVecs = Matrix([[0.21604, 0.540826, 1], [-0.151306, -1.78858, 1], [-7.64807, 1.20609, 1]])
// Check eigenvalues.
XCTAssertTrue(epsilonEqual(eig.0[0], trueValues[0]))
XCTAssertTrue(epsilonEqual(eig.0[1], trueValues[1]))
XCTAssertTrue(epsilonEqual(eig.0[2], trueValues[2]))
// Check eigenvector 1.
XCTAssertTrue(epsilonEqual(eig.1[0][0], trueVecs[0][0]))
XCTAssertTrue(epsilonEqual(eig.1[1][0], trueVecs[0][1]))
XCTAssertTrue(epsilonEqual(eig.1[2][0], trueVecs[0][2]))
// Check eigenvector 2.
XCTAssertTrue(epsilonEqual(eig.1[0][1], trueVecs[1][0]))
XCTAssertTrue(epsilonEqual(eig.1[1][1], trueVecs[1][1]))
XCTAssertTrue(epsilonEqual(eig.1[2][1], trueVecs[1][2]))
// Check eigenvector 3.
XCTAssertTrue(epsilonEqual(eig.1[0][2], trueVecs[2][0]))
XCTAssertTrue(epsilonEqual(eig.1[1][2], trueVecs[2][1]))
XCTAssertTrue(epsilonEqual(eig.1[2][2], trueVecs[2][2]))
*/
