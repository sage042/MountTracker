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

	enum Keys: String {
		case characterString, realmString
	}

	private let disposeBag = DisposeBag()

	// MARK: - Properties
	private let characterMounts: Variable<CharacterMountsModel?> = Variable(nil)
	private let masterMounts: Variable<MasterMountListModel?> = Variable(nil)
	
	public let realm: Variable<RealmModel?> = {
		let realm: RealmModel? = PersistenceManager.main.load(with: Keys.realmString.rawValue)
		return Variable(realm)
	}()
	public let characterString: Variable<String?> = {
		let character: String? = PersistenceManager.main.load(with: Keys.characterString.rawValue)
		return Variable(character)
	}()

	// MARK: - Observables
	public let dataSource: Observable<[SectionModel<String, MountModel>]>
	public let collectedCount: Observable<Int>
	public let neededCount: Observable<Int>

	init() {

		// Map dataSource to character and master lists
		dataSource = Observable
			.combineLatest(masterMounts.asObservable(), characterMounts.asObservable())
			.map({ (master, character) in
				let masterList = master?.mounts ?? []
				let characterList = character?.mounts.collected ?? []
				let needed = Set<MountModel>(masterList).subtracting(Set(characterList))
				return [SectionModel(model: "Collected", items: characterList),
						SectionModel(model: "Needed", items: Array(needed))]
			})

		collectedCount = characterMounts.asObservable().map {
			$0?.mounts.numCollected ?? 0
		}

		neededCount = characterMounts.asObservable().map {
			$0?.mounts.numNotCollected ?? 0
		}

		// observe changes to selected character and realm
		// fetch characterMounts every 0.5 seconds
		Observable
			.combineLatest(characterString.asObservable(), realm.asObservable())
			.debounce(0.5, scheduler: MainScheduler.instance)
			.subscribe(onNext: { [unowned self] (character, realm) in
				PersistenceManager.main.save(character, with: Keys.characterString.rawValue)
				PersistenceManager.main.save(realm, with: Keys.realmString.rawValue)
				self.fetchCharacterMounts(
					character: character ?? "",
					realm: realm?.slug ?? "")
			})
			.disposed(by: disposeBag)
	}

	func fetch() {
		fetchMasterMounts()
	}

	func fetchCharacterMounts(character: String, realm: String) {
		guard let url = Api.mounts(character: character, realm: realm) else {
			return
		}
		RxAlamofire
			.requestData(.get, url)
			.subscribe(onNext: { [unowned self] (r, data) in
				self.characterMounts.value = try? JSONDecoder().decode(CharacterMountsModel.self, from: data)
			})
			.disposed(by: disposeBag)
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
