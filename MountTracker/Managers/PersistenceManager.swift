//
//  PersistenceManager.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/4/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation
protocol PersistenceManager {

	func save<T: Codable>(_ object: T, with key: String)
	func load<T: Codable>(with key: String) -> T?

}

enum Persistence {

	static var main: PersistenceManager = {
		return UserPersistence()
	}()
	static var secure: PersistenceManager = {
		return KeychainPersistence()
	}()
}

// MARK: - Global instances
private let userPersistence = UserPersistence()
private let keychainPersistence = KeychainPersistence()

struct UserPersistence: PersistenceManager {


	private let jsonEncoder = JSONEncoder()
	private let jsonDecoder = JSONDecoder()

	func save<T: Codable>(_ object: T, with key: String) {
		var value: Any? = nil

		if object is String {
			value = object
		}
		else {
			value = try? jsonEncoder.encode(object)
		}

		if let value = value {
			UserDefaults.standard.setValue(value, forKey: key)
		} else {
			UserDefaults.standard.removeObject(forKey: key)
		}
		UserDefaults.standard.synchronize()
	}

	func save(value: Any?, with key: String) {
		if let value = value {
			UserDefaults.standard.setValue(value, forKey: key)
		} else {
			UserDefaults.standard.removeObject(forKey: key)
		}
		UserDefaults.standard.synchronize()
	}

	func load<T: Codable>(with key: String) -> T? {
		let saved = UserDefaults.standard.value(forKey: key)
		if let value = saved as? Data {
			return try? jsonDecoder.decode(T.self, from: value)
		}
		return saved as? T
	}
}
