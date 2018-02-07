//
//  MountListRouter.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/6/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit

struct MountlistRouter {
	private weak var controller: UIViewController?

	init(controller: UIViewController) {
		self.controller = controller
	}

	func presentWowhead(spellId: Int) {
		guard let controller = controller else { return }
		WowheadRouter().present(from: controller, spellId: spellId)
	}

}
