//
//  GalleryViewController.swift
//  homescreen1
//
//  Created by SDC-USER on 27/01/26.
//


import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var memories: [GardenMemory] = [] // Data passed from main screen
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "All Memories"
        
        setupLayout()
        
        // Register the SAME cell XIB we used before
        collectionView.register(UINib(nibName: "MemoryCell", bundle: nil), forCellWithReuseIdentifier: "MemoryCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupLayout() {
        // 3-Column Grid
        let layout = UICollectionViewFlowLayout()
        let width = (view.frame.width - 40) / 3 // 3 items per row
        layout.itemSize = CGSize(width: width, height: width) // Square
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoryCell", for: indexPath) as! MemoryCell
        let memory = memories[indexPath.row]
        
        cell.imageView.image = memory.image
        cell.imageView.contentMode = .scaleAspectFill
        // Hide the "Time Ago" label for the grid to keep it clean, or keep it if you want
        cell.dateLabel.isHidden = true 
        
        return cell
    }
}