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

final class CharacterViewModel {

	enum Keys: String {
		case characterString, realmString, characterMounts
	}

	private let disposeBag = DisposeBag()

	// MARK: - Properties
	private var _characterMounts: Variable<CharacterMountsModel?> = {
		let result: CharacterMountsModel? = Persistence.main.load(with: Keys.characterMounts.rawValue)
		return Variable(result)
	}()
	private let _thumbnail: Variable<UIImage?> = Variable(nil)
	private let _anonymous: Variable<UIImage?> = Variable(nil)

	public let realm: Variable<RealmModel?> = {
		let realm: RealmModel? = Persistence.main.load(with: Keys.realmString.rawValue)
		return Variable(realm)
	}()
	public let characterString: Variable<String?> = {
		let character: String? = Persistence.main.load(with: Keys.characterString.rawValue)
		return Variable(character)
	}()

	public let authentication = AuthenticationModel()
	public let characterSelect: BehaviorSubject<CharacterModel?> = {
		return BehaviorSubject(value: nil)
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
		let charRealm = Observable
			.combineLatest(characterString.asObservable(), realm.asObservable())
			.debounce(0.5, scheduler: MainScheduler.instance)

		// Save selections on change
		charRealm
			.subscribe(onNext: { (character, realm) in
				Persistence.main.save(character, with: Keys.characterString.rawValue)
				Persistence.main.save(realm, with: Keys.realmString.rawValue)
			})
			.disposed(by: disposeBag)

		// fetch character on change
		charRealm
			.map { ($0.0, $0.1?.slug) }
			.map(Api.mounts)
			.subscribe(onNext: fetch(to: _characterMounts, dispose: disposeBag))
			.disposed(by: disposeBag)

		characterMounts
			.subscribe(onNext: fetchThumbnail)
			.disposed(by: disposeBag)

		characterMounts
			.subscribe(onNext: { character in
				Persistence.main.save(character, with: Keys.characterMounts.rawValue)
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

