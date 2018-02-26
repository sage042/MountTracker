//
//  LoginRouter.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/18/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit
import RxSwift

typealias LoginFlowModel = (auth: AuthenticationModel, selection: BehaviorSubject<CharacterModel?>)

class LoginRouter: Router<LoginFlowModel> {

	var injected: LoginFlowModel?

	override func present(from presenter: UIViewController, with injectables: LoginFlowModel) {
		injected = injectables
		let controller = LoginViewController(injectables.auth, router: self)
		self.controller = controller
		presenter.navigationController?.pushViewController(controller, animated: true)
	}

	func presentCharacterList(_ authenticationModel: AuthenticationModel) {
		guard let controller = controller,
			let injectables = injected else { return }
		let router = CharacterListRouter()
		router.present(from: controller, with: injectables)
	}
}
