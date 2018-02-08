//
//  MountListRouter.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/6/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit

class MountlistRouter: Router<Any> {

	func presentWowhead(spellId: Int) {
		guard let controller = controller else { return }
		WowheadRouter().present(from: controller, with: spellId)
	}

	func presentCharacterSelect(_ characterViewModel: CharacterViewModel) {
		guard let controller = controller else { return }
		CharacterSelectRouter().present(from: controller, with: characterViewModel)
	}

}
