import Foundation
import UIKit

class AlertPresenter {
    weak var delegate: MovieQuizViewController?
    
    func show(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default, handler: model.completion)
        
        alert.addAction(action)
        
        delegate?.present(alert, animated: true, completion: nil)
    }
}


