//
//  CollectionViewController.swift
//  collView
//
//  Created by Jack Sp@rroW on 14/04/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController, UISearchBarDelegate , UITextFieldDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    var pixelBay: PixabayJson?
    var imageInfoArray = [ImageInfo]()
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 20.0,
                                             left: 20.0,
                                             bottom: 20.0,
                                             right: 20.0)
    
    private var page: Int  = { //страницы, начнем с первой
        var page = 1
        return page
    }()
    private var per_page: Int  = { //кол-во фото на странице
        var per_page = 30
        return per_page
    }()
    
    private var search: String  = { //поиск по картинкам
        var searchText = ""
        return searchText
    }()
    
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "введите текст"
        searchBar.enablesReturnKeyAutomatically = true
        searchBar.keyboardType = UIKeyboardType.alphabet
        return searchBar
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        
//        self.collectionView.performBatchUpdates(nil, completion: {
//            (result) in
//            print("load collectionview completed")
//        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pixelLoadJson(page: page, per_page: per_page, search: search)
    }
    

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        search = searchText
        imageInfoArray.removeAll()
        pixelLoadJson(page: page, per_page: per_page, search: search)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print(#function)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func pixelLoadJson(page: Int, per_page: Int, search: String) {
        
        activityIndicator.startAnimating()
        let url = URL(string: "https://pixabay.com/api/?key=12169393-c73621fb8fde92ee029635ac1&q=\(search)&image_type=photo&pretty=true&page=\(page)&per_page=\(per_page)")
        
        DispatchQueue.global().async {
           URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if error == nil {
                    do {
                        self.pixelBay = try JSONDecoder().decode(PixabayJson.self, from: data!)
                        self.imageInfoArray += self.pixelBay!.hits
                        
                    } catch {
                        print("pixelBay load error",error.localizedDescription)
                    }
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.searchBar.placeholder = "Найдено всего \(self.pixelBay!.totalHits) фото"
                        if search == "" {
                            self.searchBar.resignFirstResponder()
                        }
                    }
                }
                }.resume()
        }
        self.activityIndicator!.stopAnimating()
    }


    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageInfoArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
    
        let url = URL(string: imageInfoArray[indexPath.row].webformatURL)
        cell.image.downloadedFrom(url: url!, contentMode: .scaleAspectFill)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print(indexPath.row)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else { return }
        let url = URL(string: imageInfoArray[indexPath.row].previewURL)
        let urlToProfile = URL(string: imageInfoArray[indexPath.row].webformatURL)
        cell.image.downloadedFrom(url: url!, contentMode: .scaleAspectFill)
       performSegue(withIdentifier: "imageBack", sender: urlToProfile!)
    }
    
    //подготовка данных для пересылки во вьюконтроллер
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "imageBack" {
            let controller = segue.destination as! ProfileViewController
            controller.linkToImageFromLoad = sender as? URL
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == imageInfoArray.count - 1 {
            if (self.pixelBay!.totalHits / (page * per_page))  >= 1 {
                page += 1
                self.pixelLoadJson(page: page, per_page: per_page, search: search)
            }
        }
    }
}


extension CollectionViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
