//
//  AuthenticationModel.swift
//  BattleNet
//
//  Created by Christopher Matsumoto on 2/14/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation
import RxSwift

struct AccessTokenModel: Codable {

	var accessToken: String
	var expiresIn: Int

	enum CodingKeys: String, CodingKey {
		case accessToken = "access_token"
		case expiresIn = "expires_in"
	}

}

class AuthenticationModel {

	enum Keys: String {
		case authenticationCode, accessToken, expiration
	}

	var disposeBag: DisposeBag = DisposeBag()

	let code: BehaviorSubject<String?> = {
		let code: String? = Persistence.secure.load(with: Keys.authenticationCode.rawValue)
		return BehaviorSubject(value: nil)
	}()

	lazy var accessToken: BehaviorSubject<String?> = {
		let accessToken: String? = Persistence.secure.load(with: Keys.accessToken.rawValue)
		return BehaviorSubject(value: accessToken)
	}()

	lazy var expiration: BehaviorSubject<Date?> = {
		var date: Date? = nil
		if let result: String = Persistence.secure.load(with: Keys.expiration.rawValue),
			let refTime = Double(result) {
			let savedDate = Date(timeIntervalSinceReferenceDate: refTime)
			if savedDate.timeIntervalSinceNow > 24.hours {
				date = savedDate
			} else {
				accessToken.onNext(nil)
			}
		}
		return BehaviorSubject(value: date)
	}()

	let accessTokenModel: BehaviorSubject<AccessTokenModel?> = BehaviorSubject(value: nil)

	lazy var hasAccessToken: Observable<Bool> = {
		return accessToken.asObservable().map { $0 != nil }
	}()

	lazy var hasAuthorizationCode: Observable<Bool> = {
		return code.asObservable().map { $0 != nil }
	}()

	init() {
		code.asObserver()
			.subscribe(onNext: {
				Persistence.secure.save($0, with: Keys.authenticationCode.rawValue)
			})
			.disposed(by: disposeBag)
		accessToken.asObserver()
			.subscribe(onNext: {
				Persistence.secure.save($0, with: Keys.accessToken.rawValue)
			})
			.disposed(by: disposeBag)
		expiration.asObserver()
			.subscribe(onNext: {
				var result: String? = nil
				if let date = $0 {
					result = "\(date.timeIntervalSinceReferenceDate)"
				}
				Persistence.secure.save(result, with: Keys.expiration.rawValue)
			})
			.disposed(by: disposeBag)

		// Parse and persist accessToken and expiration date
		accessTokenModel.asObserver()
			.subscribe(onNext: parseToken())
			.disposed(by: disposeBag)
	}

	func parseToken() -> (AccessTokenModel?) -> Void {
		let accessToken = self.accessToken
		let expiration = self.expiration
		let result: (AccessTokenModel?) -> Void = { model in
			accessToken.onNext(model?.accessToken)
			expiration.onNext(Date() + Double(model?.expiresIn ?? 0))
		}
		return result
	}

	func parseCode(from url: URL?) {
		guard let url = url,
			let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
			code.onNext(nil)
			return
		}

		code.onNext(components
			.queryItems?
			.first(where: { $0.name == "code" })?
			.value)
	}

}

private func clear(accessToken: BehaviorSubject<String?>, expiration: BehaviorSubject<Date?>) -> (Bool?) -> Void {
	return { shouldClear in
		if shouldClear == true {
			accessToken.onNext(nil)
			expiration.onNext(nil)
		}
	}
}

