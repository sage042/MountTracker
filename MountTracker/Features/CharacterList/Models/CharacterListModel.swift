//
//  CharacterListModel.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/22/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation

struct CharacterListModel: Codable {
	var characters: [CharacterModel]
}

struct CharacterModel: Codable {
	var name: String
	var realm: String
	var thumbnail: String
}
