import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - IB Outlets
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    // MARK: - Private Properties

    private var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - IB Actions
    
    @IBAction private func yesButton(_ sender: Any) {
        presenter.yesButton()
    }
    
    @IBAction private func noButton(_ sender: Any) {
        presenter.noButton()
    }
    
    // MARK: - Internal Methods
    
    func show(quiz step: QuizStepViewModel) {
        hideLoadingIndicator()
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsView) {
        let message = presenter.makeResultsMessage()
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alertPresenter.show(in: self, model: alertModel)
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func yesAndNoButtons(areEnabled: Bool) {
        yesButton.isEnabled = areEnabled
        noButton.isEnabled = areEnabled
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let errorAlert = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alertPresenter.show(in: self, model: errorAlert)
    }
}
