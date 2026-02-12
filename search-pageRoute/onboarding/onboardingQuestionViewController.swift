import UIKit

class onboardingQuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var nextButton: UIButton!
    
    private let gradientLayer = CAGradientLayer.backgroundGreen()

    
    // Data
    var questions: [OnboardingQuestion] = JSONLoader.loadOnboardingQuestions()
    var currentIndex = 0
    
    // Storage: Question ID -> Option ID
    private var userAnswers: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupBotanicalBackground()
        view.layer.insertSublayer(gradientLayer, at: 0)

        setupTableView()
        setupProgressBar()
        setupNextButton()
        updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    // MARK: - Setup UI
    
//    private func setupBotanicalBackground() {
//        let topColor = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0).cgColor
//        let bottomColor = UIColor(red: 0.88, green: 0.94, blue: 0.89, alpha: 1.0).cgColor
//        
//        gradientLayer.colors = [topColor, bottomColor]
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
//        
//        view.layer.insertSublayer(gradientLayer, at: 0)
//    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
    }
    
    private func setupProgressBar() {
        progressBar.progressTintColor = .brandGreen
        progressBar.trackTintColor = .systemGray6
        progressBar.progress = 0.0
        progressBar.layer.cornerRadius = 4
        progressBar.clipsToBounds = true
    }
    
    private func setupNextButton() {
        nextButton.isEnabled = false
        nextButton.alpha = 0.5
    }
    
    // MARK: - Update UI
    
    func updateUI() {
        guard currentIndex < questions.count else { return }
        
        let currentQuestion = questions[currentIndex]
        questionLabel.text = currentQuestion.question
        
        updateProgress()
        updateNextButtonState()
        
        tableView.reloadData()
        
        tableView.layoutIfNeeded()
        tableHeightConstraints.constant = tableView.contentSize.height
    }
    
    private func updateProgress() {
        let progress = Float(currentIndex + 1) / Float(questions.count)
        progressBar.setProgress(progress, animated: true)
    }
    
    private func updateNextButtonState() {
        let question = questions[currentIndex]
        let isAnswered = userAnswers[question.id] != nil
        
        nextButton.isEnabled = isAnswered
        nextButton.alpha = isAnswered ? 1.0 : 0.5
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions[currentIndex].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath) as! OptionTableViewCell
        
        let question = questions[currentIndex]
        let option = question.options[indexPath.row]
        
        let selectedOptionId = userAnswers[question.id]
        let isSelected = (selectedOptionId == option.id)
        
        cell.configure(option: option.label, isSelected: isSelected, isMultiSelect: false)
        
        return cell
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let question = questions[currentIndex]
        let selectedOption = question.options[indexPath.row]
        
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
        
        userAnswers[question.id] = selectedOption.id
        
        updateNextButtonState()
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @IBAction func NextPressed(_ sender: Any) {
        
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            updateUI()
        } else {
            finishOnboarding()
        }
    }
    
    private func finishOnboarding() {
        print("Onboarding Complete! User Answers: \(userAnswers)")
    }
}
