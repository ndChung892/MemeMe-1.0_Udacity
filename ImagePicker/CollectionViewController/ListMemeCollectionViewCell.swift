//
//  ListMemeCollectionViewCell.swift
//  ImagePicker
//
//  Created by Chung on 15/05/2024.
//

import UIKit

class ListMemeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageMeme: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
         super.prepareForReuse()
        self.imageMeme.image = UIImage(named: "")
    }
    
    func setupCell(image: UIImage?) {
        self.imageMeme.image = image
    }
}
