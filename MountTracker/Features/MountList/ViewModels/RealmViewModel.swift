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

class RealmListViewModel {

	private enum Keys: String {
		case realmList
	}

	// MARK: - Properties
	private let realmList: Variable<RealmListModel?> = {
		let value: RealmListModel? = PersistenceManager.main.load(with: Keys.realmList.rawValue)
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
		RxAlamofire
			.requestData(.get, url)
			.subscribe(onNext: { [unowned self] (r, data) in
				self.realmList.value = try? JSONDecoder().decode(RealmListModel.self, from: data)
			})
			.disposed(by: disposeBag)
	}

}
