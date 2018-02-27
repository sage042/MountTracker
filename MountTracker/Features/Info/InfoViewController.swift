//
//  InfoViewController.swift
//  MountTracker
//
//  Created by Christopher Matsumoto on 2/26/18.
//  Copyright © 2018 Christopher Matsumoto. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

	@IBOutlet weak var textView: UITextView!

	init() {
		super.init(nibName: InfoViewController.identifier, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

		if let path = Bundle.main.url(forResource: "Info", withExtension: "html") {
			textView.attributedText = try? NSAttributedString(
				url: path,
				options: [.documentType: NSAttributedString.DocumentType.html,
						  .characterEncoding: String.Encoding.utf8.rawValue],
				documentAttributes: nil)
		} else {
			textView.attributedText = nil
		}

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
