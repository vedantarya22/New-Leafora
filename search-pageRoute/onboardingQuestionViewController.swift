//
//  onboardingQuestionViewController.swift
//
//  Created by SDC-USER on 05/02/26.
//

import UIKit

class onboardingQuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if questions.isEmpty { return 0 }
        return questions[currentIndex].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as? OptionTableViewCell else {
            return UITableViewCell()
        }

        let option = questions[currentIndex].options[indexPath.row]
        let isSelected = (selectedIndex == indexPath.row)

        cell.configure(option: option, isSelected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
    
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var tableHeightConstraints: NSLayoutConstraint!
    
    var questions: [OnboardingQuestion] = []
    var currentIndex = 0
    var selectedIndex: Int? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load Data
        questions = JSONLoader.loadOnboardingQuestions()
        
        // Setup TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OptionTableViewCell.self, forCellReuseIdentifier: "OptionCell") // Register class for safety
        
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0

        updateUI()
    }
    
    func updateUI() {
        guard !questions.isEmpty else { return }
        
        let q = questions[currentIndex]
        questionLabel.text = q.question
        selectedIndex = nil
        tableView.reloadData()

        DispatchQueue.main.async {
            self.tableHeightConstraints.constant = self.tableView.contentSize.height
        }

        tableView.layer.cornerRadius = 20
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = .white
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.layoutIfNeeded()
        tableHeightConstraints.constant = tableView.contentSize.height
    }



    @IBAction func NextPressed(_ sender: Any) {
        if currentIndex < questions.count - 1 {
                currentIndex += 1
                updateUI()
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
