//
//  ApiIconUrl.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/3/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation

/// Secret Keys for api access are saved to a resource file named Secret.json
/// Secret.json is git ignored, please generate and store your own keys
/// See example file structure: ExampleSecret.json
struct SecretKeys: Decodable {

	/// Obtained through Mashery account at http://dev.battle.net
	let blizzardKey: String
}

enum Api {

	static let baseUrl: String = "https://us.api.battle.net/wow"

	/// Load SecretKeys from bundle resources
	private static let secrets: SecretKeys? = {
		guard let filePath = Bundle.main.path(forResource: "Secret", ofType: "json"),
			FileManager.default.fileExists(atPath: filePath),
			let file = FileManager.default.contents(atPath: filePath) else {
				return nil
		}
		let result = try? JSONDecoder().decode(SecretKeys.self, from: file)
		return result
	}()

	static func iconURL(_ icon: String) -> URL? {
//		let urlString = "http://media.blizzard.com/wow/icons/56/\(icon).jpg"
		let urlString = "http://wow.zamimg.com/images/wow/icons/large/\(icon).jpg"
		return URL(string: urlString)
	}

	static func thumbnailURL(_ thumbnail: String?) -> URL? {
		guard let thumbnail = thumbnail else { return nil }
		let urlString = "https://render-us.worldofwarcraft.com/character/\(thumbnail)"
		return URL(string: urlString)
	}

	static func masterMountList() -> URL? {
		guard let secrets = secrets else { return nil }
		let urlString = baseUrl + "/mount/?locale=en_US&apikey=\(secrets.blizzardKey)"
		return URL(string: urlString)
	}

	static func mounts(character: String?, realm: String?) -> URL? {
		guard let secrets = secrets,
			let character = character?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed),
			!character.isEmpty,
			let realm = realm, !realm.isEmpty else {
			return nil
		}
		let urlString = baseUrl + "/character/\(realm)/\(character)?fields=mounts&locale=en_US&apikey=\(secrets.blizzardKey)"
		return URL(string: urlString)
	}

	static func realms() -> URL? {
		guard let secrets = secrets else { return nil }
		let urlString = baseUrl + "/realm/status?locale=en_US&apikey=\(secrets.blizzardKey)"
		return URL(string: urlString)
	}

	static func wowheadLink(spellId: Int?, itemId: Int?) -> URL? {
		if let itemId = itemId, itemId != 0 {
			return URL(string: "https://www.wowhead.com/item=\(itemId)")
		}
		else if let spellId = spellId, spellId != 0 {
			return URL(string: "https://www.wowhead.com/spell=\(spellId)")
		}
		return nil
	}
}
