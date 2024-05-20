//
//  ListMemeTableViewCell.swift
//  ImagePicker
//
//  Created by Chung on 15/05/2024.
//

import UIKit

class ListMemeTableViewCell: UITableViewCell {

    @IBOutlet weak var labelMeme: UILabel!
    @IBOutlet weak var imageMeme: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.labelMeme.text = nil
        self.imageMeme.image = nil
    }
    
    func setupCell(labelMeme: String?, imageMeme: UIImage?) {
        self.labelMeme.text = labelMeme
        self.imageMeme.image = imageMeme
    }
}
