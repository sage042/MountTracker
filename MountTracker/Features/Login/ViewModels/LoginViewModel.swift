//
//  LoginViewModel.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/17/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire

final class LoginViewModel {

	// MARK: - Properties

	public let authentication: AuthenticationModel

	public var hasAccess: Observable<Bool> {
		return authentication.hasAccessToken
	}

	public var hasCode: Observable<Bool> {
		return authentication.hasAuthorizationCode
	}

	private let disposeBag = DisposeBag()

	// MARK: - Initialization

	init(_ authentication: AuthenticationModel) {
		self.authentication = authentication

		// when code is obtained, fetch access token
		let fetchRequest = fetch(to: authentication.accessTokenModel, dispose: disposeBag)
		authentication.code.asObserver()
			.map(LoginApi.accessTokenURL)
			.subscribe(onNext: fetchRequest)
			.disposed(by: disposeBag)
	}

	// MARK: - Methods

	static func authenticationCodeURL() -> URLRequest? {
		return LoginApi.authorizationCodeURL()
	}

	public func isRedirect(url: URL?) -> Bool {
		guard let url = url,
			url.absoluteString.range(of: LoginApi.redirect) != nil else {
				return false
		}
		return true
	}

	public func parseAuthenticationCode(url: URL?) {
		authentication.parseCode(from: url)
	}

}
