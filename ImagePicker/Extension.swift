//
//  File.swift
//  ImagePicker
//
//  Created by Chung on 15/05/2024.
//

import Foundation
import UIKit

extension UIViewController {
    func setupNavBar() {
        self.navigationItem.title = "Sent meme"
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(addMemeButtonTapp))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc func addMemeButtonTapp() {
        guard let storyboard = self.storyboard?.instantiateViewController(identifier: "editMemeViewController") as? EditMemeViewController else { return }
        self.present(storyboard, animated: true)
    }
}
