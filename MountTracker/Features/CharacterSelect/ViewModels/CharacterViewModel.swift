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
		case characterString, realmString, characterMounts
	}

	private let disposeBag = DisposeBag()

	// MARK: - Properties
	private var _characterMounts: Variable<CharacterMountsModel?> = {
		let result: CharacterMountsModel? = PersistenceManager.main.load(with: Keys.characterMounts.rawValue)
		return Variable(result)
	}()
	private let _thumbnail: Variable<UIImage?> = Variable(nil)
	private let _anonymous: Variable<UIImage?> = Variable(nil)

	public let realm: Variable<RealmModel?> = {
		let realm: RealmModel? = PersistenceManager.main.load(with: Keys.realmString.rawValue)
		return Variable(realm)
	}()
	public let characterString: Variable<String?> = {
		let character: String? = PersistenceManager.main.load(with: Keys.characterString.rawValue)
		return Variable(character)
	}()

	// MARK: - Observables
	public let characterMounts: Observable<CharacterMountsModel?>
	public let faction: Observable<Faction>
	public let thumbnail: Observable<UIImage?>
	public let anonymous: Observable<UIImage?>
	public let characterName: Observable<String?>

	// MARK: - Lifecycle

	init() {
		characterMounts = _characterMounts.asObservable()
		faction = characterMounts.map { $0?.faction ?? .neutral }
		thumbnail = _thumbnail.asObservable()
		anonymous = _anonymous.asObservable()
		characterName = characterMounts.map { $0?.name }

		// observe changes to selected character and realm
		// fetch characterMounts every 0.5 seconds
		Observable
			.combineLatest(characterString.asObservable(), realm.asObservable())
			.debounce(0.5, scheduler: MainScheduler.instance)
			.subscribe(onNext: fetchCharacterMounts)
			.disposed(by: disposeBag)

		characterMounts
			.subscribe(onNext: fetchThumbnail)
			.disposed(by: disposeBag)

		characterMounts
			.subscribe(onNext: { character in
				PersistenceManager.main.save(character, with: Keys.characterMounts.rawValue)
			})
			.disposed(by: disposeBag)
	}

	func fetchCharacterMounts(character: String?, realm: RealmModel?) {
		PersistenceManager.main.save(value: character, with: Keys.characterString.rawValue)
		PersistenceManager.main.save(realm, with: Keys.realmString.rawValue)

		// if the character field is emptied force delete the character
		if (character ?? "").isEmpty {
			self._characterMounts.value = nil
		}

		guard let url = Api.mounts(character: character, realm: realm?.slug) else {
			return
		}

		requestData(.get, url)
			.subscribe(onNext: { [unowned self] (r, data) in
				self._characterMounts.value = try? JSONDecoder().decode(CharacterMountsModel.self, from: data)
			})
			.disposed(by: disposeBag)
	}

	func fetchAnonymousThumbnail() {
		guard let url = Api.iconURL("ability_rogue_disguise") else { return }

		requestData(.get, url)
			.subscribe(onNext: { [unowned self] (r, data) in
				self._anonymous.value = UIImage(data: data)
			})
			.disposed(by: disposeBag)
	}

	func fetchThumbnail(character: CharacterMountsModel?) {
		guard let url = Api.thumbnailURL(character?.thumbnail) else {
			_thumbnail.value = nil
			return
		}

		requestData(.get, url)
			.subscribe(onNext: { [unowned self] (r, data) in
				self._thumbnail.value = UIImage(data: data)
				})
			.disposed(by: disposeBag)
	}

}
