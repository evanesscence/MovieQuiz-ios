import Foundation

class StatisticServiceImplementation: StatisticService {
    
    var totalAccuracy: Double {
        get {
            userDefaults.double(forKey: "totalAccuracy")
        }
        
        set {
            userDefaults.set(newValue, forKey: "totalAccuracy")
        }
    }
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    var total: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var correct: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    func store(correct count: Int, total amount: Int) {
        let newRecord = GameRecord(correct: count,
                                   total: amount,
                                   date: Date())
        
        let isTheBest = newRecord.bestRecord(bestGame)
        if isTheBest {
            bestGame = newRecord
        }
        
        total += newRecord.total
        correct += newRecord.correct
        
        totalAccuracy = Double(correct) / Double(total) * 100
        gamesCount += 1
    }
    
}
