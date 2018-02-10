//
//  PersistenceManager.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/4/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation

struct PersistenceManager {

	public static let main = PersistenceManager()

	private let jsonEncoder = JSONEncoder()
	private let jsonDecoder = JSONDecoder()

	func save<T: Codable>(_ object: T, with key: String) {
		let value = try? jsonEncoder.encode(object)
		save(value: value, with: key)
	}

	func save(value: Any?, with key: String) {
		if let value = value {
			UserDefaults.standard.setValue(value, forKey: key)
		} else {
			UserDefaults.standard.removeObject(forKey: key)
		}
		UserDefaults.standard.synchronize()
	}

	func load(with key: String) -> String? {
		return UserDefaults.standard.value(forKey: key) as? String
	}

	func load<T: Codable>(with key: String) -> T? {
		guard let value = UserDefaults.standard.value(forKey: key) as? Data else {
			return nil
		}
		let result: T? = try? jsonDecoder.decode(T.self, from: value)
		return result
	}
}
