//
//  EigenDecomposition.swift
//  SwiftCMAES
//
//  Created by Santiago Gonzalez on 4/13/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//


#if os(OSX) || os(iOS)

import Accelerate

typealias LPInt = __CLPK_integer
typealias LPDouble = __CLPK_doublereal
typealias LPComplex = __CLPK_doublecomplex

#elseif os(Linux)

import CLapacke_Linux

typealias LPInt = Int32
typealias LPDouble = Double

struct LPComplex {
	var r: Double
	var i: Double
	
	init() {
		self.init(r:0, i: 0)
	}
	
	init(r: Double, i: Double) {
		self.r = r
		self.i = i
	}
}

#endif

/// Decomposes the matrix, returning its eigenvalues and eigenvector basis.
func eigenDecompose(_ mat: Matrix) -> (Vector, Matrix) {
	var n = LPInt(mat.count)
	var lda = n
	var w = Array(repeating: LPDouble(0), count: Int(n))
	
	var a = mat.flatMap { $0 } // Stored in column-major order. Technically `mat` would need to be transposed if we need to handle complex numbers, but is ommitted for the real case for efficiency.
	
	var jobz = Int8(86) // V: Compute eigenvalues and eigenvectors
	var uplo = Int8(76) // L: Lower triangular part
	var info = LPInt(0)
	
	#if os(OSX) || os(iOS)
	
	typealias LAPACKType = Double // or LPComplex
	
	// Get optimal workspace.
	var tmpWork = LAPACKType()
	var lengthTmpWork = LPInt(-1)
	var tmpIWork = LPInt(0)
	var lengthTmpIWork = LPInt(-1)
	
	dsyevd_(&jobz, &uplo, &n, &a, &lda, &w, &tmpWork, &lengthTmpWork, &tmpIWork, &lengthTmpIWork, &info)
	
	// Compute eigenvalues and eigenvectors.
	var lengthWork = LPInt(tmpWork)
	var work = Array(repeating: LAPACKType(), count: Int(lengthWork))
	var lengthIWork = tmpIWork
	var iWork = Array(repeating: LPInt(0), count: Int(lengthIWork))
	
	dsyevd_(&jobz, &uplo, &n, &a, &lda, &w, &work, &lengthWork, &iWork, &lengthIWork, &info)
	
	#elseif os(Linux)
	
	let aPointer =  UnsafeMutablePointer(mutating: a)
	
	info = LAPACKE_dsyev(LAPACK_COL_MAJOR, jobz, uplo, n, aPointer, lda, &w)
	
	#endif
	
	guard info == 0 else {
		fatalError("ERROR: Failed to compute eigenvalues and eigenvectors.")
	}
	
	let eigenbasis = Matrix(fromList: a, dimension: mat.count)
	
	return (w, eigenbasis.transposed())
}

/// Decomposes the Hermitian matrix, returning its eigenvalues and eigenvector
/// basis (both real and imaginary components).
func eigenDecomposeComplex(_ mat: Matrix) -> (Vector, Matrix, Matrix) {
	var n = LPInt(mat.count)
	var lda = n
	var w = Array(repeating: LPDouble(0), count: Int(n))
	
	var a = mat.transposed().map { $0.map { elem in
		return LPComplex(r: elem, i: 0.0)
		}}.flatMap { $0 } // Stored in column major order. Technically the transpose is unnecessary for real values, but whatevs, it makes this correct if we need to handle complex numbers.
	
	var jobz = Int8(86) // V: Compute eigenvalues and eigenvectors
	var uplo = Int8(76) // L: Lower triangular part
	var info = LPInt(0)
	
	#if os(OSX) || os(iOS)
	
	typealias LAPACKType = LPComplex
	
	// Get optimal workspace.
	var tmpWork = LAPACKType()
	var lengthTmpWork = LPInt(-1)
	var tmpRWork = LPDouble()
	var lengthTmpRWork = LPInt(-1)
	var tmpIWork = LPInt(0)
	var lengthTmpIWork = LPInt(-1)
	
	zheevd_(&jobz, &uplo, &n, &a, &lda, &w, &tmpWork, &lengthTmpWork, &tmpRWork, &lengthTmpRWork, &tmpIWork, &lengthTmpIWork, &info)
	
	// Compute eigenvalues and eigenvectors.
	var lengthWork = LPInt(tmpWork.r)
	var work = Array(repeating: LAPACKType(), count: Int(lengthWork))
	var lengthRWork = LPInt(tmpRWork)
	var rWork = Array(repeating: LPDouble(0), count: Int(lengthRWork))
	var lengthIWork = tmpIWork
	var iWork = Array(repeating: LPInt(0), count: Int(lengthIWork))
	
	zheevd_(&jobz, &uplo, &n, &a, &lda, &w, &work, &lengthWork, &rWork, &lengthRWork, &iWork, &lengthIWork, &info)
	
	#elseif os(Linux)
	
	let aPointer =  UnsafeMutablePointer(mutating: a)
	let aOpaquePointer = OpaquePointer(aPointer)
	
	info = LAPACKE_zheevd(LAPACK_COL_MAJOR, jobz, uplo, n, aOpaquePointer, lda, &w)
	
	#endif
	
	guard info == 0 else {
		fatalError("ERROR: Failed to compute eigenvalues and eigenvectors.")
	}
	
	let eigenbasisReal = Matrix(fromList: a.map { $0.r }, dimension: mat.count)
	let eigenbasisImaginary = Matrix(fromList: a.map { $0.i }, dimension: mat.count)
	
	return (w, eigenbasisReal.transposed(), eigenbasisImaginary.transposed())
}
