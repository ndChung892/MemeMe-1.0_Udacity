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
    let detailVC = DetailMemeViewController()
    var indexPath: IndexPath?
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

extension CollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let storyboard = self.storyboard?.instantiateViewController(identifier: "detailMemeViewController") as? DetailMemeViewController else {
            return
        }
        storyboard.image = memes[indexPath.row].memeImage
        self.navigationController?.pushViewController(storyboard, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            coordinator.animate(alongsideTransition: { context in
                self.collectionView.collectionViewLayout.invalidateLayout()
            }, completion: { context in
                self.collectionView.reloadData()
            })
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let isLandscape = bounds.width > bounds.height
        let cellsPerRow: CGFloat = isLandscape ? 3 : 2
        let totalSpacing = (cellsPerRow - 1) * 10
        let width = (bounds.width - totalSpacing) / cellsPerRow
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
