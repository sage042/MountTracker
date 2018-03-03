//
//  MountListViewModel.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/2/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire
import RxDataSources

enum SortDirection {

	case topDown, bottomUp

	init(_ value: Bool) {
		self = value ? SortDirection.bottomUp : SortDirection.topDown
	}

	var glyph: String {
		switch self {
		case .topDown: return Glyph.sortDown.rawValue
		case .bottomUp: return Glyph.sortUp.rawValue
		}
	}
}

typealias MountListSection = SectionModel<String, MountModel>

final class MountListViewModel {

	private let disposeBag = DisposeBag()

	// MARK: - Properties
	private let masterMounts: Variable<MasterMountListModel?> = Variable(nil)
	public let searchTerm: Variable<String> = Variable("")
	public let sortDirection: Variable<SortDirection> = Variable(SortDirection.bottomUp)

	// MARK: - Observables
	public let characterMounts: Observable<CharacterMountsModel?>
	public let dataSource: Observable<[MountListSection]>
	public let collectedCount: Observable<Int>
	public let neededCount: Observable<Int>

	init(characterMounts: Observable<CharacterMountsModel?>) {

		self.characterMounts = characterMounts

		// Filter to remove race restricted mounts from needed list
		let raceFilter: RaceFilter = RaceFilter()
		let mountFilterRace: Observable<MountFilter?> = characterMounts
			.map { character in
				let filter = raceFilter.filter(race: character?.race)
				return filter ?? { _ in return true }
			}

		let masterList = Observable
			.combineLatest(masterMounts.asObservable().map { $0?.mounts ?? [] },
						   searchTerm.asObservable(),
						   mountFilterRace)
			.map(filterMount)

		let characterList = Observable
			.combineLatest(characterMounts.asObservable().map { $0?.mounts.collected ?? [] },
						   searchTerm.asObservable(),
						   Observable<MountFilter?>.just(nil))
			.map(filterMount)

		// Map dataSource to character and master lists
		dataSource = Observable
			.combineLatest(masterList,
						   characterList,
						   sortDirection.asObservable())
			.map(makeMountList)

		collectedCount = characterMounts.map {
			$0?.mounts.numCollected ?? 0
		}

		neededCount = characterMounts.map {
			$0?.mounts.numNotCollected ?? 0
		}

	}

	// MARK: - Networking Methods

	func fetch() {

		// Attempt to load from disk first
		if let mounts: MasterMountListModel = Persistence.bundle.load(with: "MountData/mounts.json") {
			masterMounts.value = mounts
			return
		}

		guard let url = Api.masterMountList() else {
			return
		}

		requestData(.get, url)
			.subscribe(onNext: { [unowned self] (r, data) in
				self.masterMounts.value = try? JSONDecoder().decode(MasterMountListModel.self, from: data)
			})
			.disposed(by: disposeBag)
	}

}

private func filterMount(list: [MountModel], searchTerm: String, raceFilter: MountFilter?) -> [MountModel] {
	do {
		let filteredList: [MountModel] = try raceFilter.map(list.filter) ?? list
		guard !searchTerm.isEmpty else { return filteredList }
		return filteredList.filter { $0.name.lowercased().contains(searchTerm) }
	}
	catch {
		print("filter mount \(error)")
		return list
	}
}

private func makeMountList(master: [MountModel],
						   character: [MountModel],
						   sortDirection: SortDirection) -> [SectionModel<String, MountModel>] {
	var result: [SectionModel<String, MountModel>] = []

	if character.count > 0 {
		// Add collected mounts
		result.append(SectionModel(
			model: "\(character.count) Collected",
			items: character))

		// if we have the masterlist, exclude the collected mounts
		let neededSet = Set<MountModel>(master)
			.subtracting(Set(character))
		if neededSet.count > 0 {
			result.append(SectionModel(
				model: "\(neededSet.count) Needed",
				items: Array(neededSet)))
		}
	}
	else {
		// No character list, so display all mounts
		result.append(SectionModel(
			model: "\(master.count) Total",
			items: master))
	}

	// reverse the order if bottomUp
	return sortDirection == .bottomUp ? result.reversed() : result
}

