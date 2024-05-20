//
//  CollectionViewController.swift
//  ImagePicker
//
//  Created by Chung on 13/05/2024.
//

import UIKit

class CollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var memes: [Meme] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupCollectionView()
        handleNotificationCenter()
        getDataFromUserDefault()
        
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        collectionView.collectionViewLayout = layout
        
        collectionView.register(UINib(nibName: "ListMemeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "listMemeCollectionViewCell")
    }
    
    func handleNotificationCenter() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleReloadTableView(_:)),
                                               name: NSNotification.Name("MemeSaved"),
                                               object: nil)
    }
    
    @objc func handleReloadTableView(_ notification: Notification) {
        getDataFromUserDefault()
        collectionView.reloadData()
    }
    
    func getDataFromUserDefault() {
        if let savedMemesData = UserDefaults.standard.data(forKey: "Meme") {
            if let decodedMemes = try? JSONDecoder().decode([Meme].self, from: savedMemesData) {
                memes = decodedMemes
            }
        }
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = (bounds.width - 30)/3
        let height = width * 1.5
        return CGSize(width: width, height: height)
    }
}

extension CollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listMemeCollectionViewCell", for: indexPath) as? ListMemeCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.setupCell(image: memes[indexPath.row].memeImage)
        return cell
        
    }
    
}
