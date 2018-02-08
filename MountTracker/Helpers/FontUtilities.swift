//
//  FontUtilities.swift
//  Presenter
//
//  Created by Christopher Matsumoto on 4/18/17.
//  Copyright © 2017 Chris. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {

	static func glyph(size: CGFloat) -> UIFont {
		return UIFont(name: "icomoon", size: size)!
	}

}

enum Glyph: String {
	case user = "\u{e971}"
}
