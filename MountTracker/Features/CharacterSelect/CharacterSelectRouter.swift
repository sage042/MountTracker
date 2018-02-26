//
//  CharacterSelectRouter.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/8/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit

class CharacterSelectRouter: Router<CharacterViewModel> {

	override func present(from presenter: UIViewController, with injectables: CharacterViewModel) {
		let controller = CharacterSelectViewController(injectables, router: self)
		let nav = UINavigationController(rootViewController: controller)
		nav.modalPresentationStyle = .overFullScreen
		self.controller = controller
		presenter.present(nav, animated: true)
	}

	func presentLogin(_ injectables: LoginFlowModel) {
		guard let controller = self.controller else { return }
		let loginRouter = LoginRouter()
		loginRouter.present(from: controller, with: injectables)
	}

	func presentCharacterList(_ injectables: LoginFlowModel) {
		guard let controller = controller else { return }
		injectables.selection.onNext(nil)
		let router = CharacterListRouter()
		router.present(from: controller, with: injectables)
	}

}
