//
//  categoriesViewController.swift
//  SearchPage
//
//  Created by SDC-USER on 28/01/26.
//

import UIKit

class categoriesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // Callback to pass data back to SearchViewController
    var selectionHandler: ((String) -> Void)?
    
    
    let categories = JSONLoader.fetchCategories()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fix: Bring the Navigation Bar to the front so it covers the collection view when scrolling
        if let navBar = view.subviews.first(where: { $0 is UINavigationBar }) {
            view.bringSubviewToFront(navBar)
        }
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        // Register XIB
        let nib = UINib(nibName: "categoriesCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: categoriesCollectionViewCell.identifier)
        
        // Layout
        collectionView.collectionViewLayout = createLayout()
        
        // Delegates
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func createLayout() -> UICollectionViewLayout {
        // 2 items per row
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(100) // Adjusted height for 2-column look, maybe 100-120
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(110)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        // Fix: Add top padding so the first row starts BELOW the navigation bar.
        section.contentInsets = NSDirectionalEdgeInsets(top: 80, leading: 16, bottom: 16, trailing: 16)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    

    
    // MARK: - Actions
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        print("Clear Filter Tapped")
        dismiss(animated: true) {
            self.selectionHandler?("all")
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension categoriesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoriesCollectionViewCell.identifier, for: indexPath) as? categoriesCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let category = categories[indexPath.row]
        cell.configure(with: category)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        print("Selected category: \(category.title) -> Filtering by: \(category.normalizedKey)")
        
        if category.normalizedKey == "recommended_plant" {
            if !HomeDataStore.shared.arePreferencesSet() {
                showPreferencesAlert()
                return
            }
        }
        
        dismiss(animated: true) {
            // Pass selection back AFTER dismissal to avoid presentation conflicts
            self.selectionHandler?(category.normalizedKey)
        }
    }
    
    private func showPreferencesAlert() {
        let alert = UIAlertController(
            title: "Complete Your Profile",
            message: "To get personalized plant recommendations, please complete your Gardening Preferences in your Profile.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        // Optional: Add "Go to Profile" action if navigation is possible from here
        
        present(alert, animated: true)
    }

}
