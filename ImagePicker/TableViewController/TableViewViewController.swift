//
//  TableViewViewController.swift
//  ImagePicker
//
//  Created by Chung on 13/05/2024.
//

import UIKit

class TableViewViewController: UIViewController {
    
    let editMemeVC = EditMemeViewController()
    var memes: [Meme] = []
    @IBOutlet weak var tableView: UITableView!
    var isEditingMode: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "ListMemeTableViewCell", bundle: nil), forCellReuseIdentifier: "listMemeTableViewCell")
        handleNotificationCenter()
        getDataFromUserDefault()
    }

    
    func handleNotificationCenter() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleReloadTableView(_:)),
                                               name: NSNotification.Name("MemeSaved"),
                                               object: nil)
    }
    
    @objc func handleReloadTableView(_ notification: Notification) {
        getDataFromUserDefault()
        tableView.reloadData()
    }
    
    func getDataFromUserDefault() {
        if let savedMemesData = UserDefaults.standard.data(forKey: "Meme") {
            if let decodedMemes = try? JSONDecoder().decode([Meme].self, from: savedMemesData) {
                memes = decodedMemes
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension TableViewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let storyboard = self.storyboard?.instantiateViewController(identifier: "detailMemeViewController") as? DetailMemeViewController else {
            return
        }
        storyboard.image = memes[indexPath.row].memeImage
        self.navigationController?.pushViewController(storyboard, animated: true)
    }
}

extension TableViewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("aaa\(memes.count)")
        return memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "listMemeTableViewCell", for: indexPath) as? ListMemeTableViewCell else {
            return UITableViewCell()
        }
        
        let stringLabel: String = "...\(memes[indexPath.row].topText!)...\(memes[indexPath.row].bottomText!)..."
        
        cell.setupCell(labelMeme: stringLabel,
                       imageMeme: memes[indexPath.row].memeImage)
        return cell
    }
    
    
}
