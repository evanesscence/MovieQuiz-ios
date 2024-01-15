import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - IB Outlets
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    // MARK: - Private Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statistic: StatisticServiceImplementation = StatisticServiceImplementation()
    private var alertPresenter = AlertPresenter()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        showLoadingIndicator()
        questionFactory?.loadData()
        
    }
    
    // MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButton(_ sender: Any) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        let answer = true
        
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButton(_ sender: Any) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        let answer = false
        
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.imageView.layer.borderColor = UIColor.ypBlack.cgColor
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statistic.store(correct: correctAnswers, total: questionsAmount)
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: "Ваш результат: \(correctAnswers)/\(questionsAmount) \n Количество сыгранных квизов: \(statistic.gamesCount) \n Рекорд: \(statistic.bestGame.correct)/\(statistic.bestGame.total) (\(statistic.bestGame.date.dateTimeString)) \n Средняя точность: \(String(format: "%.2f", statistic.totalAccuracy))%",
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    guard let self = self else { return }
                    
                    self.correctAnswers = 0
                    self.currentQuestionIndex = 0
                    
                    self.questionFactory?.requestNextQuestion()
                })
            
            alertPresenter.show(in: self, model: alertModel)
            
            noButton.isEnabled = true
            yesButton.isEnabled = true
            
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            
            noButton.isEnabled = true
            yesButton.isEnabled = true
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let errorAlert = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.show(in: self, model: errorAlert)
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
