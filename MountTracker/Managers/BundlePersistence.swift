//
//  BundlePersistence.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 3/2/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation

struct BundlePersistence: PersistenceManager {

	private let jsonDecoder = JSONDecoder()

	func save<T: Codable>(_ object: T, with key: String) {
		assertionFailure("Bundle Persistence does not allow saving")
	}

	func load<T: Codable>(with key: String) -> T? {
		guard let path = Bundle.main.path(forResource: key, ofType: nil),
			let data = FileManager.default.contents(atPath: path) else {
			return nil
		}
		do {
			let result: T = try jsonDecoder.decode(T.self, from: data)
			return result
		}
		catch {
			print("BundlePersistence error: \(error)")
		}
		return nil
	}

}
