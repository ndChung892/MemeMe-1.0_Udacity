//
//  DetailMemeViewController.swift
//  ImagePicker
//
//  Created by Chung on 21/05/2024.
//

import UIKit

class DetailMemeViewController: UIViewController {

    @IBOutlet weak var imageMeme: UIImageView!
    var image: UIImage?
    var text: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail Meme"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageMeme.image = image
    }

}
