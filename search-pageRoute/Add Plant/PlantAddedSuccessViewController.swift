//
//  PlantAddedSuccessViewController.swift
//  PlantApp
//
//  Created by SDC-USER on 09/01/26.
//

import UIKit

class PlantAddedSuccessViewController: UIViewController {

  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func exploreButtonTapped(_ sender: UIButton) {
            navigationController?.popToRootViewController(animated: true)
        }
    
    
    @IBAction func gardenButtonTapped(_ sender: UIButton) {
        

        tabBarController?.selectedIndex = 1
            navigationController?.popToRootViewController(animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
