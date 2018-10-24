import Foundation

class Stats {
    @discardableResult
    func collectStatistics() -> Bool {
        return false;
    }
    var bestScore: UInt = 0
    var totalMoveCount: UInt = 0
    var gameCount: Int = 0
    var totalDuration: Double = 0
    var winCount: Int = 0
}
