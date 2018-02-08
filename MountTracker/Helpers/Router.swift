//
//  Router.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/8/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit

class Router <Injectables> {

	var controller: UIViewController?

	init(controller: UIViewController? = nil) {
		self.controller = controller
	}

	func present(from presenter: UIViewController, with injectables: Injectables) {}

}
