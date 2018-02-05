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

class MountListViewModel {

	private let disposeBag = DisposeBag()

	// MARK: - Properties
	private let masterMounts: Variable<MasterMountListModel?> = Variable(nil)


	// MARK: - Observables
	public let characterMounts: Observable<CharacterMountsModel?>
	public let dataSource: Observable<[SectionModel<String, MountModel>]>
	public let collectedCount: Observable<Int>
	public let neededCount: Observable<Int>

	init(characterMounts: Observable<CharacterMountsModel?>) {

		self.characterMounts = characterMounts

		// Map dataSource to character and master lists
		dataSource = Observable
			.combineLatest(masterMounts.asObservable(), characterMounts)
			.map({ (master, character) in
				let masterList = master?.mounts ?? []
				let characterList = character?.mounts.collected ?? []
				let needed = Set<MountModel>(masterList).subtracting(Set(characterList))
				return [SectionModel(model: "Collected", items: characterList),
						SectionModel(model: "Needed", items: Array(needed))]
			})

		collectedCount = characterMounts.map {
			$0?.mounts.numCollected ?? 0
		}

		neededCount = characterMounts.map {
			$0?.mounts.numNotCollected ?? 0
		}

	}

	func fetch() {
		fetchMasterMounts()
	}

	func fetchMasterMounts() {
		guard let url = Api.masterMountList() else {
			return
		}
		RxAlamofire
			.requestData(.get, url)
			.subscribe(onNext: { [unowned self] (r, data) in
				self.masterMounts.value = try? JSONDecoder().decode(MasterMountListModel.self, from: data)
			})
			.disposed(by: disposeBag)
	}
	
}
