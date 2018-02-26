//
//  CharacterListViewModel.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/22/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation
import RxSwift

class CharacterListViewModel {

	private let authentication: AuthenticationModel
	private let characterList: BehaviorSubject<CharacterListModel?> = {
		return BehaviorSubject(value: nil)
	}()

	public let characterSelected: BehaviorSubject<CharacterModel?>

	public lazy var characters: Observable<[CharacterModel]> = {
		return characterList.map { $0?.characters ?? [] }
	}()

	private let disposeBag: DisposeBag = DisposeBag()

	init(authentication: AuthenticationModel, characterSelected: BehaviorSubject<CharacterModel?>) {
		self.authentication = authentication
		self.characterSelected = characterSelected

		let fetchRequest = fetch(to: characterList, dispose: disposeBag)
		authentication.accessToken.asObserver()
			.map(Api.profile)
			.subscribe(onNext: fetchRequest)
			.disposed(by: disposeBag)
	}

}
