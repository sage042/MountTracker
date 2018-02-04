//
//  UIImageViewHelper.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/3/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire

protocol RxImageReceiver: class {

	var disposeBag: DisposeBag { get set }
	
}

extension RxImageReceiver {

	func loadImage(_ url: URL?, in imageView: UIImageView) {
		guard let url = url else { return }
		disposeBag = DisposeBag()
		let image: Variable<UIImage?> = Variable(nil)
		imageView.image = nil
		RxAlamofire
			.requestData(.get, url)
			.subscribe(onNext: { (r, data) in
				image.value = UIImage(data: data)
			})
			.disposed(by: disposeBag)
		image.asObservable()
			.bind { (image) in
				imageView.image = image
			}
			.disposed(by: disposeBag)
	}
}
