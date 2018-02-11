//
//  WowheadRouter.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/6/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit
import SafariServices

class WowheadRouter: Router<MountModel> {

	override func present(from presenter: UIViewController, with injectables: MountModel) {
		guard let url = Api.wowheadLink(spellId: injectables.spellId, itemId: injectables.itemId) else {
			return
		}
		let webController = SFSafariViewController(url: url)
		presenter.present(webController, animated: true)
	}

}
