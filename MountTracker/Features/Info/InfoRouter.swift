//
//  InfoRouter.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/26/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit

class InfoRounter: Router<Void> {
	override func present(from presenter: UIViewController, with injectables: Void) {
		let controller = InfoViewController()
		presenter.navigationController?.pushViewController(controller, animated: true)
	}
}
