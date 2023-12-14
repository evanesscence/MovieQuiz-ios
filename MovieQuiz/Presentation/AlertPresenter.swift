import Foundation
import UIKit

class AlertPresenter {
    weak var delegate: MovieQuizViewController?
    
    func show(quiz result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default, handler: result.completion)
            
        
        alert.addAction(action)
        
        delegate?.present(alert, animated: true, completion: nil)
    }
}


