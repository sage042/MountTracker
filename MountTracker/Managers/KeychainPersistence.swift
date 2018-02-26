//
//  KeychainPersistence.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/17/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation
import KeychainAccess

struct KeychainPersistence: PersistenceManager {

	let keychain: Keychain = {
		let bundleID = Bundle.main.bundleIdentifier ?? "com.mounttracker"
		return Keychain(service: bundleID)
	}()

	func save<T: Codable>(_ object: T, with key: String) {
		if let item = object as? String {
			keychain[key] = item
		}
		else if let data = try? JSONEncoder().encode(object) {
			keychain[data: key] = data
		}
	}

	func load<T: Codable>(with key: String) -> T? {
		if let item = keychain[data: key],
			let result = try? JSONDecoder().decode(T.self, from: item) {
			return result
		}
		return keychain[key] as? T
	}

}
