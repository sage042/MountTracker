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
		default: return UIColor(red: 47/255, green: 63/255, blue: 79/255, alpha: 1)
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
		tintColor = faction.foregroundColor
	}
}

extension UISearchBar {

	/// Hack to get a search bar's text field
	///    Stackoverflow results suggest accessing an
	///    an Apple private property which could be rejected
	///    this method searches through the subviews and may change
	///    in future versions of iOS
	func findSearchField() -> UITextField? {
		return subviews.first?.subviews
			.filter { $0 is UITextField }
			.first as? UITextField
	}
}

public func GradientLayer() -> CAGradientLayer {
	let aLayer = CAGradientLayer()
	aLayer.colors = [
		UIColor(white: 1, alpha: 0.3).cgColor,
		UIColor(white: 0, alpha: 0.3).cgColor
	]
	aLayer.locations = [
		0.0,
		1.0
	]
	return aLayer
}


