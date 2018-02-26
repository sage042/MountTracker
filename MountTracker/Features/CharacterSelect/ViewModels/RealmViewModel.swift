//
//  RealmViewModel.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/3/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire

final class RealmListViewModel {

	private enum Keys: String {
		case realmList
	}

	// MARK: - Properties
	public let realmList: Variable<RealmListModel?> = {
		let value: RealmListModel? = Persistence.main.load(with: Keys.realmList.rawValue)
		return Variable(value)
	}()
	private let disposeBag = DisposeBag()

	// MARK: - Observables
	public let dataSource: Observable<[RealmModel]>

	init() {
		dataSource = realmList.asObservable().map { model in
			return model?.realms ?? []
		}
	}

	func fetch() {
		guard let url = Api.realms() else {
			return
		}

		requestData(.get, url)
			.map(response(to: RealmListModel.self))
			.catchErrorJustReturn(nil)
			.bind(to: realmList)
			.disposed(by: disposeBag)
	}

}
