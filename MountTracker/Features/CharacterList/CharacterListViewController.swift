//
//  CharacterListViewController.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/22/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class CharacterListViewController: UIViewController {

	// MARK: - Properties

	let gradientLayer: CAGradientLayer = GradientLayer()

	let viewModel: CharacterListViewModel
	private let router: CharacterListRouter

	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var activitySpinner: UIActivityIndicatorView!

	var disposeBag: DisposeBag = DisposeBag()

	// MARK: - Lifecycle

	init(_ injected: LoginFlowModel, router: CharacterListRouter) {
		self.viewModel = CharacterListViewModel(authentication: injected.auth, characterSelected: injected.selection)
		self.router = router
		super.init(nibName: "CharacterListViewController", bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		activitySpinner.startAnimating()

		collectionViewSetup()

		view.backgroundColor = Faction.neutral.backgroundColor

		gradientLayer.frame = view.frame
		view.layer.insertSublayer(gradientLayer, at: 0)
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if var list = navigationController?.viewControllers,
			let index = list.index(where: { $0 is LoginViewController }) {
			list.remove(at: index)
			navigationController?.viewControllers = list
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	// MARK: - RX Setup

	func collectionViewSetup() {
		collectionView.register(CharacterCollectionViewCell.self)

		let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, CharacterModel>>(
			configureCell: { (_, collectionView, indexPath, element) in
				let cell = collectionView.dequeue(CharacterCollectionViewCell.self, for: indexPath)
				cell.prepare(with: element)
				return cell
			})

		collectionView.rx
			.itemSelected
			.map { dataSource[$0] }
			.bind(to: viewModel.characterSelected)
			.disposed(by: disposeBag)

		viewModel.characterSelected
			.subscribe(onNext: { [weak self] in
				guard $0 != nil else { return }
				self?.router.pop()
			})
			.disposed(by: disposeBag)

		viewModel.characters
			.map { [SectionModel(model: "Characters", items: $0)] }
			.bind(to: collectionView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)

		var count = 0
		viewModel.characterList.asObservable()
			.subscribe(onNext: { [weak self] item in
				count += 1
				if count > 3 || item != nil {
					self?.activitySpinner.stopAnimating()
				}
			})
			.disposed(by: disposeBag)

		view.rx
			.observe(CGRect.self, "frame")
			.subscribe(onNext: { [weak self] frame in
				guard let frame = frame else { return }
				let flow = UICollectionViewFlowLayout()
				flow.itemSize = CGSize(width: frame.width - 28, height: 72)
				flow.sectionInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
				self?.collectionView.setCollectionViewLayout(flow, animated: false)
				self?.gradientLayer.frame = frame
			})
			.disposed(by: disposeBag)

	}

}
