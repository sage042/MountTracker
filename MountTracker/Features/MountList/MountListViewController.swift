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

class MountListViewController: UITableViewController {

	// MARK: - Properties
	let mountViewModel: MountListViewModel = MountListViewModel()
	let realmViewModel: RealmListViewModel = RealmListViewModel()
	let disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

		tableViewSetup()
    }

	override func viewWillAppear(_ animated: Bool) {
		mountViewModel.fetch()
		realmViewModel.fetch()
	}

	func tableViewSetup() {
		tableView.dataSource = nil
		tableView.delegate = nil
		tableView.rowHeight = 88

		// bind MountListViewModel.dataSource to tableView cells
		mountViewModel.dataSource.bind(to: tableView.rx.items(cellIdentifier: "MountTableViewCell", cellType: MountTableViewCell.self)) {
			(_, element, cell) in
			cell.prepare(with: element)
		}
		.disposed(by: disposeBag)

		// bind tableView header to the RealmListViewModel and MountListViewModel
		if let header = tableView.tableHeaderView as? CharacterSelectionHeaderView {
			realmViewModel.dataSource
				.bind(to: header.pickerView.rx.itemTitles) {
					_, item in
					return item.name
				}
				.disposed(by: disposeBag)

			let realmField = header.realmField
			header.pickerView.rx
				.modelSelected(RealmModel.self)
				.subscribe(onNext: { [unowned self] items in
					self.mountViewModel.realmString.value = items.first?.slug ?? ""
					realmField?.text = items.first?.name
				})
				.disposed(by: disposeBag)

			header.characterField.rx
				.text
				.map { $0?
					.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
					.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)?
					.lowercased() ?? "" }
				.bind(to: mountViewModel.characterString)
				.disposed(by: disposeBag)
		}
	}

}
