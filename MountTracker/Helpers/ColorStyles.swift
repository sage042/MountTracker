//
//  ColorStyles.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/8/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit

extension Faction {

	init(_ factionInt: Int?) {
		guard let factionInt = factionInt else {
			self = .neutral
			return
		}
		self = Faction(rawValue: factionInt) ?? .neutral
	}

	var backgroundColor: UIColor {
		switch self {
		case .alliance: return UIColor(red: 46/255, green: 73/255, blue: 148/255, alpha: 1)
		case .horde: return UIColor(red: 183/255, green: 38/255, blue: 43/255, alpha: 1)
		default: return UIColor.white
		}
	}

	var foregroundColor: UIColor {
		switch self {
		case .alliance: return UIColor(red: 241/255, green: 183/255, blue: 5/255, alpha: 1)
		case .horde: return UIColor.black
		default: return UIColor.black
		}
	}

}

extension UINavigationBar {
	func color(for faction: Faction) {
		titleTextAttributes = [
			.foregroundColor: faction.foregroundColor]
		largeTitleTextAttributes = [
			.foregroundColor: faction.foregroundColor
		]
		barTintColor = faction.backgroundColor
	}
}


