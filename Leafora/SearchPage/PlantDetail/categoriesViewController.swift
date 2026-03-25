//
//  categoriesViewController.swift
//  SearchPage
//
//  Created by SDC-USER on 28/01/26.
//

import UIKit

class categoriesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // pass selected category back
    var selectionHandler: ((String) -> Void)?
    
    
    let categories = JSONLoader.fetchCategories()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // keep nav bar above scrolling content
        if let navBar = view.subviews.first(where: { $0 is UINavigationBar }) {
            view.bringSubviewToFront(navBar)
        }
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        // register xib
        let nib = UINib(nibName: "categoriesCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: categoriesCollectionViewCell.identifier)
        
        // layout
        collectionView.collectionViewLayout = createLayout()
        
        // delegates
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func createLayout() -> UICollectionViewLayout {
        // 2 items per row
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(100) // tuned for 2-column layout
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(110)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        // keep first row below nav bar
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
            // pass selection after dismiss
            self.selectionHandler?(category.normalizedKey)
        }
    }
    
    private func showPreferencesAlert() {
        let alert = UIAlertController(
            title: "Complete Your Profile",
            message: "To get personalized plant recommendations, please complete your Gardening Preferences in your Profile.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let goToProfileAction = UIAlertAction(title: "Go to Profile", style: .default) { [weak self] _ in
            self?.navigateToProfilePreferences()
        }
        alert.addAction(goToProfileAction)
        
        present(alert, animated: true)
    }
    
    private func navigateToProfilePreferences() {
        // dismiss categories first
        dismiss(animated: true) {
            // let parent screen handle navigation
            NotificationCenter.default.post(name: NSNotification.Name("NavigateToGardeningPreferences"), object: nil)
        }
    }

}
