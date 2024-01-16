import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsView)
    
    func highlightImageBorder(isCorrect: Bool)
    func yesAndNoButtons(areEnabled: Bool) 
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}
