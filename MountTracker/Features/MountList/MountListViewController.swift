//
//  MountListViewController.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 1/31/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MountListViewController: UIViewController {

	// MARK: - Properties

	let gradientLayer: CAGradientLayer = GradientLayer()

	@IBOutlet var collectionView: UICollectionView!

	let realmViewModel: RealmListViewModel = RealmListViewModel()
	let characterViewModel: CharacterViewModel = CharacterViewModel()
	lazy var mountViewModel: MountListViewModel = {
		return MountListViewModel(characterMounts: self.characterViewModel.characterMounts)
	}()
	let disposeBag: DisposeBag = DisposeBag()

	lazy var router: MountListRouter = {
		return MountListRouter(controller: self)
	}()

	var searchController: UISearchController = {
		return UISearchController(searchResultsController: nil)
	}()

	// MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

		gradientLayer.frame = view.bounds
		view.layer.insertSublayer(gradientLayer, at: 0)

		collectionViewSetup()
		navBarSetup()
    }

	override func viewWillAppear(_ animated: Bool) {
		mountViewModel.fetch()
		realmViewModel.fetch()
	}

	// MARK: - RX Setup

	/// Bind MountListViewModel.dataSource to collectionView cells
	func collectionViewSetup() {
		collectionView.dataSource = nil
		collectionView.delegate = nil

		collectionView.register(MountCollectionViewCell.self)

		collectionView.register(
			MountHeaderCollectionReusableView.self,
			forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)

		let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, MountModel>>(
			configureCell: { (_, collectionView, indexPath, element) in
				let cell = collectionView.dequeue(MountCollectionViewCell.self, for: indexPath)
				cell.prepare(with: element)
				return cell
			},
			configureSupplementaryView: { (ds, cv, kind, indexPath) in
				let header = cv.dequeue(MountHeaderCollectionReusableView.self, ofKind: kind, for: indexPath)
				header.title.text = ds[indexPath.section].model
				return header
			}
		)

		collectionView.rx
			.itemSelected
			.map { dataSource[$0] }
			.subscribe(onNext: router.presentWowhead)
			.disposed(by: disposeBag)


		// bind dataSource to MountTableViewCell items
		mountViewModel.dataSource
			.bind(to: collectionView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)

		view.rx
			.observe(CGRect.self, "bounds")
			.subscribe(onNext: { [weak self] (frame) in
				guard let frame = frame else { return }
				let flow = UICollectionViewFlowLayout()
				flow.headerReferenceSize = CGSize(width: frame.width, height: 26)
				flow.itemSize = CGSize(width: frame.width - 28, height: 72)
				flow.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
				self?.collectionView.setCollectionViewLayout(flow, animated: false)
			})
			.disposed(by: disposeBag)


	}

	func navBarSetup() {

		updateSectionOrderButton()

		navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)

		// bind search bar to searchTerm
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.rx
			.text
			.orEmpty
			.debounce(0.5, scheduler: MainScheduler.instance)
			.map { $0.lowercased() }
			.bind(to: mountViewModel.searchTerm)
			.disposed(by: disposeBag)
		definesPresentationContext = true

		// Clear search term if user cancels
		searchController.rx
			.delegate
			.methodInvoked(#selector(UISearchControllerDelegate.didDismissSearchController(_:)))
			.subscribe(onNext: clearSearchTerm)
			.disposed(by: disposeBag)

		navigationItem.searchController = searchController

		// update search bar coloring
		let searchBar = searchController.searchBar
		let aView: UIView = view
		characterViewModel.faction
			.subscribe(onNext: { faction in
				searchBar.barTintColor = .white
				searchBar.tintColor = faction.foregroundColor
				let field = searchBar.findSearchField()
				field?.textColor = faction.foregroundColor
				aView.backgroundColor = faction.backgroundColor
			})
			.disposed(by: disposeBag)

		// bind character name to navigation title
		characterViewModel.characterName
			.map { $0 ?? "Mounts" }
			.bind(to: navigationItem.rx.title)
			.disposed(by: disposeBag)

		// map faction to nav bar colors
		if let navBar = navigationController?.navigationBar {
			characterViewModel.faction
				.subscribe(onNext: navBar.color)
				.disposed(by: disposeBag)
		}

		// map character selection to left icon
		characterViewModel.thumbnail
			.subscribe(onNext: updateProfileButton)
			.disposed(by: disposeBag)

		// present character select on left bar click
		if let navBarButton = navigationItem.leftBarButtonItem?.customView as? UIButton {
			navBarButton.rx
				.controlEvent(UIControlEvents.touchUpInside)
				.bind(onNext: presentCharacterSelect)
				.disposed(by: disposeBag)
		}
	}

	private func updateProfileButton(with thumbnail: UIImage?) {

		guard let barButton = navigationItem.leftBarButtonItem,
			let button: UIButton = barButton.customView as? UIButton else {
			return
		}
		if let thumbnail = thumbnail {
			button.setImage(thumbnail, for: .normal)
			button.imageView?.contentMode = .center
			button.setAttributedTitle(nil, for: .normal)
		} else {
			let labelString = NSAttributedString(
				string: Glyph.user.rawValue,
				attributes: [NSAttributedStringKey.font: UIFont.glyph(size: 32),
							 NSAttributedStringKey.foregroundColor: UIColor.black])
			button.setAttributedTitle(labelString, for: .normal)
			button.setImage(nil, for: .normal)
		}
		button.contentHorizontalAlignment = .left

		// need to reset bar button item in order for the size to be set correctly
		navigationItem.leftBarButtonItem = nil
		navigationItem.leftBarButtonItem = barButton
	}

	private func updateSectionOrderButton() {

		let sortButton = UIBarButtonItem(
			title: Glyph.sortDown.rawValue,
			style: UIBarButtonItemStyle.plain,
			target: nil,
			action: nil)
		sortButton.setTitleTextAttributes(
			[NSAttributedStringKey.font: UIFont.glyph(size: 28),
			 NSAttributedStringKey.foregroundColor: UIColor.black],
			for: .normal)
		sortButton.setTitleTextAttributes(
			[NSAttributedStringKey.font: UIFont.glyph(size: 28)],
			for: UIControlState.highlighted)

		sortButton.rx
			.tap
			.scan(false) { (last, next) -> Bool in
				return !last
			}
			.map(SortDirection.init)
			.bind(to: mountViewModel.sortDirection)
			.disposed(by: disposeBag)
		mountViewModel.sortDirection
			.asObservable()
			.map { direction -> String in
				direction.glyph
			}
			.bind(to: sortButton.rx.title)
			.disposed(by: disposeBag)
		navigationItem.rightBarButtonItem = sortButton
	}

	private func clearSearchTerm(_ stream: [Any]) {
		mountViewModel.searchTerm.value = ""
	}

	private func presentCharacterSelect() {
		router.presentCharacterSelect(characterViewModel)
	}

}
