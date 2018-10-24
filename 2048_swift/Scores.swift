import Foundation

class Score {
    let name: String = ""
    let score: UInt = 0
    let win: Bool = false
    let largestTile: UInt = 0
    let moveCount: UInt = 0
    let duration: Double = 0
    
    init() {
    }
}

class Scoreboard {
    var score: UInt = 0
    var win: Bool = false
    var largestTile: UInt = 0
    var moveCount: UInt = 0
    var duration: Double = 0
    
    func printScore() {
    }
    func printStats() {
    }
    func save() {
    }
    
    private var name: String = ""
    private var scoreList: [Score] = [Score]()
    
    private func prompt() {
    
    }
    private func writeToFile() {
        
    }
    private func readFile() {
        
    }
    private func padding(_ name: String) {
        
    }
}
