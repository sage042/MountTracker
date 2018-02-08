//
//  Identifiable.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/8/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit

protocol Identifiable {
	static var identifier: String { get }
}

extension Identifiable {
	static var identifier: String {
		return String(describing: self)
	}
}

extension UITableViewCell: Identifiable {}
extension UICollectionViewCell: Identifiable {}
extension UIViewController: Identifiable {}
