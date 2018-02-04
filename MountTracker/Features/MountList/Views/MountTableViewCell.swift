//
//  MountTableViewCell.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 1/31/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MountTableViewCell: UITableViewCell, RxImageReceiver {

	@IBOutlet weak var iconImage: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!

	var disposeBag: DisposeBag = DisposeBag()
	
	override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

	func prepare(with model: MountModel) {
		loadImage(Api.iconURL(model.icon),
				  in: iconImage)
		nameLabel.text = model.name
	}

}
