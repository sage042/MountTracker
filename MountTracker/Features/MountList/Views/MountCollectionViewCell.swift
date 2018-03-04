//
//  MountCollectionViewCell.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 1/31/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MountCollectionViewCell: UICollectionViewCell, RxImageReceiver {

	@IBOutlet weak var iconImage: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!

	var disposeBag: DisposeBag = DisposeBag()
	
	override func awakeFromNib() {
        super.awakeFromNib()

		layer.cornerRadius = 4
    }
	
	func prepare(with model: MountModel) {
		if let path: Data = Persistence.bundle.load(with: "MountData/icons/\(model.icon).jpg") {
			iconImage.image = UIImage(data: path)
		}
		else {
			loadImage(Api.iconURL(model.icon),
					  in: iconImage)
		}
		nameLabel.text = model.name
	}

}
