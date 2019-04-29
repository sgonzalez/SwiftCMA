//
//  Utilities.swift
//  SwiftCMAES
//
//  Created by Santiago Gonzalez on 4/29/19.
//  Copyright © 2019 Santiago Gonzalez. All rights reserved.
//

import Foundation

extension Collection {
	
	/// Syntactic sugar, equivalent to calling `.enumerated().map`.
	func indexedMap<T>(_ transform: ((offset: Int, element: Self.Element)) throws -> T) rethrows -> [T] {
		return try self.enumerated().map(transform)
	}
	
}
