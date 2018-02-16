//
//  CollectionViewHelpers.swift
//  Presenter
//
//  Created by Christopher Matsumoto on 2/26/17.
//  Copyright © 2017 Chris. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {

	func register(_ type: Identifiable.Type) {
		register(UINib(nibName: type.identifier, bundle: nil),
		         forCellWithReuseIdentifier: type.identifier)
	}

	func register(_ type: Identifiable.Type, forSupplementaryViewOfKind kind: String) {
		register(UINib(nibName: type.identifier, bundle: nil),
		         forSupplementaryViewOfKind: kind,
		         withReuseIdentifier: type.identifier)
	}

	func dequeue<T: Identifiable>(_ type: T.Type,
	             for indexPath: IndexPath) -> T {
		let cell = dequeueReusableCell(withReuseIdentifier: type.identifier,
		                               for: indexPath)
		return cell as! T
	}

	func dequeue<T: Identifiable>(_ type: T.Type, ofKind elementKind: String, for indexPath: IndexPath) -> T {
		let reusable = dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: T.identifier, for: indexPath)
		return reusable as! T
	}
}

extension UICollectionReusableView: Identifiable { }
