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

class MountListViewModel {

	private let disposeBag = DisposeBag()

	// MARK: - Properties
	private let masterMounts: Variable<MasterMountListModel?> = Variable(nil)
	public let searchTerm: Variable<String> = Variable("")
	public let sortDirection: Variable<SortDirection> = Variable(SortDirection.topDown)

	// MARK: - Observables
	public let characterMounts: Observable<CharacterMountsModel?>
	public let dataSource: Observable<[MountListSection]>
	public let collectedCount: Observable<Int>
	public let neededCount: Observable<Int>

	init(characterMounts: Observable<CharacterMountsModel?>) {

		self.characterMounts = characterMounts

		let masterList = Observable
			.combineLatest(masterMounts.asObservable().map { $0?.mounts ?? [] },
						   searchTerm.asObservable())
			.map(filterMount)

		let characterList = Observable
			.combineLatest(characterMounts.asObservable().map { $0?.mounts.collected ?? [] },
						   searchTerm.asObservable())
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

private func filterMount(list: [MountModel], searchTerm: String) -> [MountModel] {
	guard !searchTerm.isEmpty else { return list }
	return list.filter { $0.name.lowercased().contains(searchTerm) }
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
