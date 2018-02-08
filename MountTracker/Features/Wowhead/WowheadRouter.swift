//
//  WowheadRouter.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/6/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit
import SafariServices

class WowheadRouter: Router<Int> {

	override func present(from presenter: UIViewController, with injectables: Int) {
		guard let url = URL(string: "https://www.wowhead.com/spell=\(injectables)") else {
			return
		}
		let webController = SFSafariViewController(url: url)
		presenter.present(webController, animated: true)
	}

}
