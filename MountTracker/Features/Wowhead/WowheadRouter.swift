//
//  WowheadRouter.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/6/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit
import SafariServices

struct WowheadRouter {

	func present(from presenter: UIViewController, spellId: Int) {
		guard let url = URL(string: "https://www.wowhead.com/spell=\(spellId)") else {
			return
		}
		let webController = SFSafariViewController(url: url)
		presenter.present(webController, animated: true)
	}

}
