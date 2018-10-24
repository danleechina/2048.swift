import Foundation

struct Menu {
    func startMenu(_ err: Int = 0) {
        clearScreen()
        drawAscii()
        
        print("  Welcome to ".bold_on, "2048!".blue, "".def, "".bold_off)
        endl(1)
        print("          1. Play a New Game")
        endl(1)
        print("          2. Continue Previous Game")
        endl(1)
        print("          3. View Highscores and Statistics")
        
        input(err)
    }
    
    func input(_ err: Int) {
        if err != 0 {
            print("  Invalid input. Please try again.".red, "".def)
            endl(1)
        }
        
        print("  Enter Choice: ")
        let c = inputChar().charString
        switch c {
        case "1":
            startGame()
        case "2":
            continueGame()
        case "3":
            showScores()
        default:
            startMenu(1)
        }
    }
    
    func startGame() {
        let g = Game()
        g.startGame()
    }
    
    func continueGame() {
        let g = Game()
        g.continueGame()
    }
    
    func showScores() {
        let s = Scoreboard()
        s.printScore()
        s.printStats()
    }
}
