//
//  MountListViewController.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 1/31/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa
import RxDataSources

class MountListViewController: UITableViewController {

	// MARK: - Properties
	let realmViewModel: RealmListViewModel = RealmListViewModel()
	let characterViewModel: CharacterViewModel = CharacterViewModel()
	lazy var mountViewModel: MountListViewModel = {
		return MountListViewModel(characterMounts: self.characterViewModel.characterMounts)
	}()
	let disposeBag: DisposeBag = DisposeBag()

	lazy var router: MountlistRouter = {
		return MountlistRouter(controller: self)
	}()

	// MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

		tableViewSetup()
		tableViewHeaderSetup()
		styleSetup()
    }

	override func viewWillAppear(_ animated: Bool) {
		mountViewModel.fetch()
		realmViewModel.fetch()
	}

	// MARK: - RX Setup

	/// Bind MountListViewModel.dataSource to tableView cells
	func tableViewSetup() {
		tableView.dataSource = nil
		tableView.delegate = nil
		tableView.rowHeight = 88

		let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, MountModel>>(
			configureCell: { (_, tv, indexPath, element) in
				let cell = tv.dequeueReusableCell(withIdentifier: "MountTableViewCell", for: indexPath) as! MountTableViewCell
				cell.prepare(with: element)
				return cell
			},
			titleForHeaderInSection: { dataSource, sectionIndex in
				return dataSource[sectionIndex].model
			}
		)

		tableView.rx
			.itemSelected
			.map { indexPath in
				return dataSource[indexPath].spellId
			}
			.subscribe(onNext: router.presentWowhead)
			.disposed(by: disposeBag)

		// bind dataSource to MountTableViewCell items
		mountViewModel.dataSource
			.bind(to: tableView.rx.items(dataSource: dataSource))
			.disposed(by: disposeBag)
	}

	/// Bind tableView header to the RealmListViewModel and MountListViewModel
	func tableViewHeaderSetup() {
		guard let header = tableView.tableHeaderView as? CharacterSelectionHeaderView else {
			return
		}

		// update pickerView with realm lists pretty name
		realmViewModel.dataSource
			.bind(to: header.pickerView.rx.itemTitles) {
				_, item in
				return item.name
			}
			.disposed(by: disposeBag)

		// pickerView updates realm view model
		header.pickerView.rx
			.modelSelected(RealmModel.self)
			.subscribe(onNext: { [unowned self] items in
				self.characterViewModel.realm.value = items.first
			})
			.disposed(by: disposeBag)

		// update realmField with realm view model's pretty name
		characterViewModel.realm.asObservable()
			.map { $0?.name }
			.bind(to: header.realmField.rx.text)
			.disposed(by: disposeBag)

		// bidirectional update between characterField and character view model
		let characterField = header.characterField.rx
		(characterField.text <-> characterViewModel.characterString)
			.disposed(by: disposeBag)
	}

	func styleSetup() {

		characterViewModel.characterName
			.map { $0 ?? "Mounts" }
			.bind(to: navigationItem.rx.title)
			.disposed(by: disposeBag)

		// map faction to nav bar color
		characterViewModel.faction
			.map { (faction) -> UIColor in
				switch faction {
				case .alliance: return UIColor(red: 46/255, green: 73/255, blue: 148/255, alpha: 1)
				case .horde: return UIColor(red: 183/255, green: 38/255, blue: 43/255, alpha: 1)
				default: return UIColor.white
				}
			}
			.subscribe(onNext: { (color) in
				self.navigationController?.navigationBar.barTintColor = color
			})
			.disposed(by: disposeBag)

		// map faction to nav bar title color
		characterViewModel.faction
			.map { (faction) -> UIColor in
				switch faction {
				case .alliance: return UIColor(red: 241/255, green: 183/255, blue: 5/255, alpha: 1)
				case .horde: return UIColor.black
				default: return UIColor.black
				}
			}
			.subscribe(onNext: { [unowned self] (color) in
				self.navigationController?.navigationBar.titleTextAttributes = [
					.foregroundColor: color]
				self.navigationController?.navigationBar.largeTitleTextAttributes = [
					.foregroundColor: color
				]
				self.navigationItem.leftBarButtonItem?.tintColor = color
			})
			.disposed(by: disposeBag)

		// map character selection to left icon
		characterViewModel.thumbnail
			.subscribe(onNext: updateProfileButton)
			.disposed(by: disposeBag)
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
				attributes: [NSAttributedStringKey.font: UIFont.glyph(size: 32)])
			button.setAttributedTitle(labelString, for: .normal)
			button.setImage(nil, for: .normal)
		}
		button.contentHorizontalAlignment = .left

		// need to reset bar button item in order for the size to be set correctly
		navigationItem.leftBarButtonItem = nil
		navigationItem.leftBarButtonItem = barButton
	}

}
