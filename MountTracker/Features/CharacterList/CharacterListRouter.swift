//
//  CharacterListRouter.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/22/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit

class CharacterListRouter: Router<LoginFlowModel> {

	override func present(from presenter: UIViewController, with injectables: LoginFlowModel) {
		let controller = CharacterListViewController(injectables, router: self)
		self.controller = controller
		presenter.navigationController?.pushViewController(controller, animated: true)
	}

}
