//
//  RxBidirectionalOperator.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/4/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire

infix operator <->

func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
	let bindToUIDisposable = variable.asObservable()
		.bind(to: property)
	let bindToVariable = property
		.subscribe(onNext: { n in
			variable.value = n
		}, onCompleted:  {
			bindToUIDisposable.dispose()
		})

	return Disposables.create(bindToUIDisposable, bindToVariable)
}

func response<T: Codable>(to resultType: T.Type) -> (HTTPURLResponse, Data) throws -> T {
	let closure: (HTTPURLResponse, Data) throws -> T = { (_, data) in
		let result = try JSONDecoder().decode(resultType, from: data)
		return result
	}
	return closure
}

func fetchURL<T: Codable>(_ model: T.Type) -> (URL?) throws -> Observable<T?> {
	return { (url) throws -> Observable<T?> in
		guard let url = url else { return Observable<T?>.just(nil) }
		return requestData(.get, url)
			.map(response(to: model))
			.catchErrorJustReturn(nil)
	}
}

func fetch<T: Codable>(to model: BehaviorSubject<T?>, dispose: DisposeBag) -> (URLRequest?) -> Void {
	return { (request) -> Void in
		guard let request = request else { return }
		requestData(request)
			.debug()
			.map(response(to: T.self))
			.catchErrorJustReturn(nil)
			.bind(to: model)
			.disposed(by: dispose)
	}
}
