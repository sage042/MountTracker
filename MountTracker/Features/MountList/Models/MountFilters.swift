//
//  MountFilters.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 3/2/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation

typealias FilterStore = [String: Set<Int>]
typealias MountFilter = (MountModel) -> Bool

struct RaceFilter {
	let raceItems: FilterStore = {
		let races: FilterStore? = Persistence.bundle.load(with: "MountData/races.json")
		return races ?? [:]
	}()

	func filter(race: Int?) -> MountFilter? {
		guard let race = race,
			let raceSet = raceItems["\(race)"],
			let allSet = raceItems["-1"] else { return nil }
		let result: MountFilter = {
			return raceSet.contains($0.itemId) || allSet.contains($0.itemId)
		}
		return result
	}

}
