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
		let controller = CharacterSelectViewController(injectables)
		let nav = UINavigationController(rootViewController: controller)
		nav.modalPresentationStyle = .overFullScreen
		self.controller = controller
		presenter.present(nav, animated: true)
	}
	
}
