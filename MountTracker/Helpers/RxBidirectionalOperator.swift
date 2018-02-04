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
