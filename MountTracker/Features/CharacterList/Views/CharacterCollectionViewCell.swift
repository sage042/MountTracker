//
//  CharacterCollectionViewCell.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/23/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CharacterCollectionViewCell: UICollectionViewCell, RxImageReceiver {

	@IBOutlet weak var profileImage: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var realmLabel: UILabel!

	var disposeBag: DisposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()

		layer.cornerRadius = 4
    }

	func prepare(with model: CharacterModel) {
		loadImage(Api.thumbnailURL(model.thumbnail),
				  in: profileImage)
		nameLabel.text = model.name
		realmLabel.text = model.realm
	}

}
