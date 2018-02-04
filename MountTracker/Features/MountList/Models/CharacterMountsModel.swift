//
//  CharacterMountsModel.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/2/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation

struct CharacterMountsModel: Decodable {
	var name: String
	var realm: String
	var mounts: MountListModel
}

struct MountListModel: Decodable {
	var numCollected: Int
	var numNotCollected: Int
	var collected: [MountModel]
}

struct MountModel: Decodable {
	var name: String
	var spellId: Int
	var creatureId: Int
	var itemId: Int
	var qualityId: Int
	var icon: String
	var isGround: Bool
	var isFlying: Bool
	var isAquatic: Bool
	var isJumping: Bool
}