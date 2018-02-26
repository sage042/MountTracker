//
//  LoginViewController.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/17/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit
import WebKit
import RxSwift

class LoginViewController: UIViewController {

	@IBOutlet weak var webView: WKWebView!

	private let viewModel: LoginViewModel
	private let router: LoginRouter
	private let disposeBag: DisposeBag = DisposeBag()

	// MARK: - Lifecycle

	init(_ authentication: AuthenticationModel, router: LoginRouter) {
		self.viewModel = LoginViewModel(authentication)
		self.router = router
		super.init(nibName: LoginViewController.identifier, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
        super.viewDidLoad()

		webView.navigationDelegate = self

		viewModel.hasCode
			.debug("hasCode")
			.subscribe(onNext: { [weak self] in self?.handleCodeChange($0) })
			.disposed(by: disposeBag)
    }

	func handleCodeChange(_ hasCode: Bool) {
		guard !hasCode,
			let urlRequest = LoginViewModel.authenticationCodeURL() else {
			router.presentCharacterList(viewModel.authentication)
			return
		}
		webView.load(urlRequest)
	}

}

// MARK: - WKNavigationDelegate
extension LoginViewController: WKNavigationDelegate {

	/// parse callback URL for authentication code
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		if viewModel.isRedirect(url: navigationAction.request.url) {
			viewModel.parseAuthenticationCode(url: navigationAction.request.url)
			decisionHandler(WKNavigationActionPolicy.cancel)
			return
		}
		decisionHandler(WKNavigationActionPolicy.allow)
	}

}
