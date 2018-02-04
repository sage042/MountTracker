//
//  RealmListModel.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/3/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation

struct RealmListModel: Codable {
	var realms: [RealmModel]
}

struct RealmModel: Codable {
	var type: String
	var population: String
	var queue: Bool
	var status: Bool
	var name: String
	var slug: String
	var battlegroup: String
	var locale: String
	var timezone: String
	var connected_realms: [String]
}
