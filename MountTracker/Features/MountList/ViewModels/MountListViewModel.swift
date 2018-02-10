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

class MountListViewModel {

	private let disposeBag = DisposeBag()

	// MARK: - Properties
	private let masterMounts: Variable<MasterMountListModel?> = Variable(nil)
	public let searchTerm: Variable<String> = Variable("")
	public let sortDirection: Variable<SortDirection> = Variable(SortDirection.topDown)

	// MARK: - Observables
	public let characterMounts: Observable<CharacterMountsModel?>
	public let dataSource: Observable<[SectionModel<String, MountModel>]>
	public let collectedCount: Observable<Int>
	public let neededCount: Observable<Int>

	init(characterMounts: Observable<CharacterMountsModel?>) {

		self.characterMounts = characterMounts

		// Map dataSource to character and master lists
		dataSource = Observable
			.combineLatest(masterMounts.asObservable(), characterMounts, searchTerm.asObservable(), sortDirection.asObservable())
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

private func makeMountList(master: MasterMountListModel?,
						   character: CharacterMountsModel?,
						   searchTerm: String,
						   sortDirection: SortDirection) -> [SectionModel<String, MountModel>] {

	var masterList = master?.mounts ?? []
	// filter master list by search term
	if !searchTerm.isEmpty {
		masterList = masterList.filter { $0.name.lowercased().contains(searchTerm) }
	}
	var result: [SectionModel<String, MountModel>] = []

	if let character = character {
		var characterList = character.mounts.collected
		// filter character list by search term
		if !searchTerm.isEmpty {
			characterList = characterList.filter { $0.name.lowercased().contains(searchTerm) }
		}

		// Add collected mounts
		result.append(SectionModel(
			model: "\(character.mounts.numCollected) Collected",
			items: characterList))

		// if we have the masterlist, exclude the collected mounts
		let neededSet = Set<MountModel>(masterList)
			.subtracting(Set(characterList))
		if neededSet.count > 0 {
			result.append(SectionModel(
				model: "\(character.mounts.numNotCollected) Needed",
				items: Array(neededSet)))
		}
	}
	else {
		// No character list, so display all mounts
		result.append(SectionModel(
			model: "\(masterList.count) Total",
			items: masterList))
	}

	// reverse the order if bottomUp
	return sortDirection == .bottomUp ? result.reversed() : result
}
