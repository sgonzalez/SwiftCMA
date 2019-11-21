//
//  LinearAlgebraTests.swift
//  SwiftCMAESTests
//
//  Created by Santiago Gonzalez on 4/20/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import XCTest
import SwiftCMA

class LinearAlgebraTests: XCTestCase {
	
	func testProperties() {
		let v1 = [1.0, 5.0, 3.5] as Vector
		XCTAssertEqual(v1.sum, 9.5)
		XCTAssertEqual(v1.squared, [1.0, 25.0, 12.25])
		XCTAssertEqual(v1.squaredMagnitude, v1.squared.sum)
	}
	
    func testVectorArithmetic() {
        let v1 = [1.0, 5.0, 3.5] as Vector
		let v2 = [2.0, 5.0, 0] as Vector
		XCTAssertEqual(v1 - v2, [-1.0, 0.0, 3.5])
		XCTAssertEqual(v1 + v2, [3.0, 10.0, 3.5])
    }
	
	func testVectorArithmeticInPlace() {
		var v1 = [1.0, 5.0, 3.5] as Vector
		v1.multiply(2.0)
		XCTAssertEqual(v1, [2.0, 10.0, 7.0])
	}
	
	func testInitMatrixFromList() {
		let matrix = Matrix(fromList: [1,2,3,4,5,6,7,8,9] as Vector, dimension: 3)
		let expected = Matrix([[1,2,3],[4,5,6],[7,8,9]])
		XCTAssertEqual(matrix, expected)
	}

	func testMatrixArithmeticInPlace() {
		var matrix = Matrix([[1,2,3],[4,5,6],[7,8,9]])
		let matrixDouble = Matrix([[2,4,6],[8,10,12],[14,16,18]])
		matrix.multiply(2.0)
		XCTAssertEqual(matrix, matrixDouble)
	}
	
	func testAddOuterProduct() {
		var matrix = Matrix([[1,2,3],[4,5,6],[7,8,9]])
		let vector = [1.0, 2.0, 3.0] as Vector
		let outerProduct = Matrix([[1,2,3],[2,4,6],[3,6,9]])
		let result = matrix + outerProduct + outerProduct
		matrix.addOuterProduct(vec: vector, multiplier: 2.0)
		XCTAssertEqual(matrix, result)
	}
	
	func testMatrixDotWithVector() {
		let matrix = Matrix([[1,2,3],[4,5,6],[7,8,9]])
		let vector = [1.0, 2.0, 3.0] as Vector
		let result = [14.0, 32.0, 50.0] as Vector
		XCTAssertEqual(matrix.dot(vec: vector), result)
	}
	
	func testMatrixDotWithVectorTransposed() {
		let matrix = Matrix([[1,2,3],[4,5,6],[7,8,9]]).transposed()
		let vector = [1.0, 2.0, 3.0] as Vector
		let result = [14.0, 32.0, 50.0] as Vector
		XCTAssertEqual(matrix.dot(vec: vector, transpose: true), result)
	}
	
	func testTransposition() {
		let matrix = Matrix([[1,2,3],[4,5,6],[7,8,9]])
		let matrixT = Matrix([[1,4,7],[2,5,8],[3,6,9]])
		XCTAssertEqual(matrix.transposed(), matrixT)
		XCTAssertEqual(matrix.transposed().transposed(), matrix)
		XCTAssertEqual(Matrix.identity(dim: 6).transposed(), Matrix.identity(dim: 6))
	}
	
	static var allTests = [
		("testProperties", testProperties),
		("testTransposition", testTransposition),
		("testVectorArithmetic", testVectorArithmetic),
		("testVectorArithmeticInPlace", testVectorArithmeticInPlace),
		("testInitMatrixFromList", testInitMatrixFromList),
		("testMatrixArithmeticInPlace", testMatrixArithmeticInPlace),
		("testAddOuterProduct", testAddOuterProduct),
		("testMatrixDotWithVector", testMatrixDotWithVector),
		("testMatrixDotWithVectorTransposed", testMatrixDotWithVectorTransposed),
        ("testTransposition", testTransposition),
    ]
	
}
