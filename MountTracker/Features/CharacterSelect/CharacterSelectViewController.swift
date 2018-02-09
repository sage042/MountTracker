//
//  CharacterSelectViewController.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/8/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CharacterSelectViewController: UIViewController {

	// MARK: - Properties

	@IBOutlet weak var characterField: UITextField!
	@IBOutlet weak var realmField: UITextField!
	@IBOutlet weak var imageView: UIImageView!

	private let characterViewModel: CharacterViewModel
	private let realmViewModel: RealmListViewModel = RealmListViewModel()

	private var pickerView: UIPickerView = {
		let picker = UIPickerView()
		return picker
	}()
	private var inputToolbar: UIToolbar = {
		let toolbar = UIToolbar()
		let spacer = UIBarButtonItem(
			barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
			target: nil,
			action: nil)
		let done = UIBarButtonItem(
			barButtonSystemItem: UIBarButtonSystemItem.done,
			target: self, action: #selector(dismissKeyboard))
		toolbar.setItems([spacer, done], animated: false)
		toolbar.sizeToFit()
		return toolbar
	}()

	private let disposeBag: DisposeBag = DisposeBag()

	// MARK: - Lifecycle

	init(_ characterViewModel: CharacterViewModel) {
		self.characterViewModel = characterViewModel
		super.init(nibName: CharacterSelectViewController.identifier, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		realmField.inputView = pickerView
		characterField.inputAccessoryView = inputToolbar
		realmField.inputAccessoryView = inputToolbar

		fieldSetup()
		portraitSetup()
		navBarSetup()

		realmViewModel.fetch()
		characterViewModel.fetchAnonymousThumbnail()
    }

	func fieldSetup() {

		// update pickerView with realm lists pretty name
		realmViewModel.dataSource
			.bind(to: pickerView.rx.itemTitles) {
				_, item in
				return item.name
			}
			.disposed(by: disposeBag)

		// pickerView updates realm view model
		pickerView.rx
			.modelSelected(RealmModel.self)
			.map { $0.first }
			.bind(to: characterViewModel.realm)
			.disposed(by: disposeBag)

		// update realmField with realm view model's pretty name
		characterViewModel.realm.asObservable()
			.map { $0?.name }
			.bind(to: realmField.rx.text)
			.disposed(by: disposeBag)

		// bidirectional update between characterField and character view model
		(characterField.rx.text <-> characterViewModel.characterString)
			.disposed(by: disposeBag)
	}

	func portraitSetup() {

		// bind imageView to character thumbnail
		Observable
			.combineLatest(characterViewModel.thumbnail, characterViewModel.anonymous)
			.subscribe(onNext: { [unowned self] (character, anon) in
				self.imageView.image = character ?? anon
			})
			.disposed(by: disposeBag)
	}

	func navBarSetup() {

		let backButton = UIBarButtonItem(
			barButtonSystemItem: UIBarButtonSystemItem.done,
			target: self,
			action: #selector(dismissView))
		navigationItem.leftBarButtonItem = backButton

		// mapy faction to nav bar colors
		if let navBar = navigationController?.navigationBar {
			characterViewModel.faction
				.subscribe(onNext: navBar.color)
				.disposed(by: disposeBag)
		}

		// Set back button color
		if let button = navigationItem.leftBarButtonItem {
			characterViewModel.faction
				.map { $0.foregroundColor }
				.subscribe(onNext: { button.tintColor = $0 })
				.disposed(by: disposeBag)
		}
	}

	// MARK: - Methods

	@objc func dismissKeyboard() {
		view.endEditing(true)
	}

	@objc func dismissView() {
		self.dismiss(animated: true)
	}

}
