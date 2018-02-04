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
	public let dataSource: Observable<[MountModel]>
	public let collectedCount: Observable<Int>
	public let totalCount: Observable<Int>

	init() {
		dataSource = Observable
			.combineLatest(masterMounts.asObservable(), characterMounts.asObservable())
			.map({ (master, character) in
				return character?.mounts.collected ?? master?.mounts ?? []
			})
		collectedCount = characterMounts.asObservable().map { model in
			return model?.mounts.numCollected ?? 0
		}
		totalCount = characterMounts.asObservable().map { model in
			var total = model?.mounts.numCollected ?? 0
			total += model?.mounts.numNotCollected ?? 0
			return total
		}

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
		guard !character.isEmpty, !character.isEmpty,
			let url = Api.mounts(character: character, realm: realm) else {
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
