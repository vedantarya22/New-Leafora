//
//  Add_plant_q2_ViewController.swift
//  PlantApp
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class PlantQuantityViewController: UIViewController {

    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    
  
    var session: PlantQuestionSession!


    
    var quantity = 1   // default value
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateQuantityLabel()
      
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        
        //  Save the quantity into answers model
        session.plantCount = quantity
        
        print("Saved plant quantity:", session.plantCount)
       
//         If selected → continue to next screen
            performSegue(withIdentifier: "toNextScreen", sender: self)
    }
    
   
    
    @IBAction func didTapMinus(_ sender: UIButton) {
        if quantity > 1 {
                quantity -= 1
                updateQuantityLabel()
            }
    }
    
    
    @IBAction func didTapPlus(_ sender: UIButton) {
        if quantity < 10 {
               quantity += 1
               updateQuantityLabel()
           }
    }
    
    func updateQuantityLabel() {
        qtyLabel.text = "\(quantity)"
        minusBtn.isEnabled = quantity > 1
        plusBtn.isEnabled = quantity < 10
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNextScreen" {
            if let nextVC = segue.destination as? PlantLightViewController {
                nextVC.session = self.session
            }
        }
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
