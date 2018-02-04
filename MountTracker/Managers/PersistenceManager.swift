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

	func save(_ object: String?, with key: String) {
		UserDefaults.standard.setValue(object, forKey: key)
		UserDefaults.standard.synchronize()
	}

	func save<T: Codable>(_ object: T, with key: String) {
		guard let value = try? jsonEncoder.encode(object) else {
			return
		}
		UserDefaults.standard.setValue(value, forKey: key)
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
