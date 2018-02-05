//
//  CharacterViewModel.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/4/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire

class CharacterViewModel {

	enum Keys: String {
		case characterString, realmString
	}

	private let disposeBag = DisposeBag()

	// MARK: - Properties
	private let _characterMounts: Variable<CharacterMountsModel?> = Variable(nil)

	public let realm: Variable<RealmModel?> = {
		let realm: RealmModel? = PersistenceManager.main.load(with: Keys.realmString.rawValue)
		return Variable(realm)
	}()
	public let characterString: Variable<String?> = {
		let character: String? = PersistenceManager.main.load(with: Keys.characterString.rawValue)
		return Variable(character)
	}()

	// MARK: - Observables
	public var characterMounts: Observable<CharacterMountsModel?> {
		return _characterMounts.asObservable()
	}

	// MARK: - Lifecycle

	init() {
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

	func fetchCharacterMounts(character: String, realm: String) {
		guard let url = Api.mounts(character: character, realm: realm) else {
			return
		}
		RxAlamofire
			.requestData(.get, url)
			.subscribe(onNext: { [unowned self] (r, data) in
				self._characterMounts.value = try? JSONDecoder().decode(CharacterMountsModel.self, from: data)
			})
			.disposed(by: disposeBag)
	}

}
