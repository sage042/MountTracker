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
	let mountViewModel: MountListViewModel = MountListViewModel()
	let realmViewModel: RealmListViewModel = RealmListViewModel()
	let disposeBag: DisposeBag = DisposeBag()

	// MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

		tableViewSetup()
		tableViewHeaderSetup()
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
				self.mountViewModel.realm.value = items.first
			})
			.disposed(by: disposeBag)

		// update realmField with realm view model's pretty name
		mountViewModel.realm.asObservable()
			.map { $0?.name }
			.bind(to: header.realmField.rx.text)
			.disposed(by: disposeBag)

		// bidirectional update between characterField and character view model
		let characterField = header.characterField.rx
		(characterField.text <-> mountViewModel.characterString)
			.disposed(by: disposeBag)
	}

}
