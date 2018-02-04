//
//  CharacterSelectionHeaderView.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/3/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit

class CharacterSelectionHeaderView: UIView {

	@IBOutlet var characterField: UITextField!
	@IBOutlet var realmField: UITextField!
	var pickerView: UIPickerView = {
		let picker = UIPickerView()
		return picker
	}()
	var inputToolbar: UIToolbar = {
		let toolbar = UIToolbar()
		let done = UIBarButtonItem(
			barButtonSystemItem: UIBarButtonSystemItem.done,
			target: self, action: #selector(dismissKeyboard))
		toolbar.setItems([done], animated: false)
		toolbar.sizeToFit()
		return toolbar
	}()

	override func awakeFromNib() {
		super.awakeFromNib()
		realmField.inputView = pickerView
		characterField.inputAccessoryView = inputToolbar
		realmField.inputAccessoryView = inputToolbar
	}

	@objc func dismissKeyboard() {
		endEditing(true)
	}

}
