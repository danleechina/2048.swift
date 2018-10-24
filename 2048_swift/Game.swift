import Foundation

enum Directions {
    case UP
    case DOWN
    case RIGHT
    case LEFT
}

class Tile {
    var value: UInt = 0
    var blocked: Bool = false
    static let colors = [Modifier.red, Modifier.yellow, Modifier.magenta, Modifier.blue, Modifier.cyan, Modifier.yellow,
                         Modifier.red, Modifier.yellow, Modifier.magenta, Modifier.blue, Modifier.green]
    func tileColor(_ value: Int) -> Modifier {
        let log = Int(log2(Double(value)))
        let index = log < 12 ? log - 1 : 10
        return Tile.colors[index]
    }
}

private let CODE_ESC = 27
private let CODE_LSQUAREBRACKET = 91//"["
private let CODE_ANSI_TRIGGER_1 = CODE_ESC
private let CODE_ANSI_TRIGGER_2 = CODE_LSQUAREBRACKET
private let CODE_ANSI_UP = "A"
private let CODE_ANSI_DOWN = "B"
private let CODE_ANSI_LEFT = "D"
private let CODE_ANSI_RIGHT = "C"
private let CODE_WASD_UP = "W"
private let CODE_WASD_DOWN = "S"
private let CODE_WASD_LEFT = "A"
private let CODE_WASD_RIGHT = "D"
private let CODE_VIM_UP = "K"
private let CODE_VIM_DOWN = "J"
private let CODE_VIM_LEFT = "H"
private let CODE_VIM_RIGHT = "L"
private let CODE_HOTKEY_ACTION_SAVE = "Z"
private let CODE_HOTKEY_ALTERNATE_ACTION_SAVE = "P"

class Game {
    private var moved: Bool = false
    private var win: Bool = false
    private var boardFull: Bool = false
    private var rexit: Bool = false
    private var score: UInt = 0
    private var bestScore: UInt = 0
    private var largestTile: UInt = 0
    private var moveCount: UInt = 0
    private var duration: Double = 0
    private var gameBoardPlaySize: UInt = 4
    private var board: [[Tile]] = [[Tile]]()
    private var stateSaved: Bool = false
    private var noSave: Bool = false
    
    enum ContinueStatus: Int {
        case STATUS_END_GAME = 0
        case STATUS_CONTINUE = 1
    };
    enum KeyInputErrorStatus: Int {
        case STATUS_INPUT_VALID = 0
        case STATUS_INPUT_ERROR = 1
    };
    let COMPETITION_GAME_BOARD_PLAY_SIZE = 4
    
    func startGame() {
        let stats = Stats()
        if stats.collectStatistics() {
            bestScore = stats.bestScore
        }
        setBoardSize()
        initialiseBoardArray()
        addTile()
        playGame(.STATUS_END_GAME)
    }
    
    func continueGame() {
        let stats = Stats()
        if stats.collectStatistics() {
            bestScore = stats.bestScore
        }
        clearScreen()
        drawAscii()
        initialiseContinueBoardArray()
        playGame(.STATUS_CONTINUE)
    }
    
    private func initialiseBoardArray() {
        board.removeAll()
        for _ in 0..<gameBoardPlaySize {
            var bufferArray = [Tile]()
            for _ in 0..<gameBoardPlaySize {
                let bufferTile = Tile()
                bufferArray.append(bufferTile)
            }
            board.append(bufferArray)
        }
    }
    
    private func GetLines() -> UInt {
        var noOfLines: UInt = 0
        if let s = FileManager.default.stringContent(at: "./data/previousGame") {
            noOfLines = UInt(s.split(separator: "\n").count)
        }
        return noOfLines
    }
    
    private func initialiseContinueBoardArray() {
        guard let previousGameDataString = FileManager.default.stringContent(at: "./data/previousGame") else {
            noSave = true
            startGame()
            return
        }
        gameBoardPlaySize = GetLines()
        initialiseBoardArray()
        var tempArr = [[String]]()
        for tempLine in previousGameDataString.split(separator: "\n") {
            let s = tempLine.split(separator: ",").map( { return String($0) })
            tempArr.append(s)
        }
        
        for i in 0..<gameBoardPlaySize {
            for j in 0..<gameBoardPlaySize {
                let blocks = tempArr[Int(i)][Int(j)].split(separator: ":").map( { String($0) })
                board[Int(i)][Int(j)].value = UInt(Int(blocks[0]) ?? 0)
                board[Int(i)][Int(j)].blocked = (Int(blocks[1]) ?? 0) != 0
            }
        }
        if let statsDataString = FileManager.default.stringContent(at: "./data/previousGameStats") {
            let stats = statsDataString.split(separator: "\n")
            for stat in stats {
                // FIXME
                let s = stat.split(separator: ":")
                score = UInt(s[0]) ?? 0
                moveCount = UInt(s[1]) ?? 0
            }
        }
    }
    
    @discardableResult
    private func addTile() -> Bool {
        let CHANCE_OF_VALUE_FOUR_OVER_TWO = 89
        var freeTiles = collectFreeTiles()
        
        boardFull = freeTiles.count == 0
        let randomFreeTile = freeTiles[randInt() % freeTiles.count]
        let x = randomFreeTile[1]
        let y = randomFreeTile[0]
        board[y][x].value = randInt() % 100 > CHANCE_OF_VALUE_FOUR_OVER_TWO ? 4 : 2
        
        moveCount += 1
        moved = true
        
        if rexit {
            return !rexit
        }
        
        return canMove()
    }
    
    private func collectFreeTiles() -> [[Int]] {
        var freeTiles = [[Int]]()
        for y in 0..<gameBoardPlaySize {
            for x in 0..<gameBoardPlaySize {
                if board[Int(y)][Int(x)].value == 0 {
                    let temp = [Int(y), Int(x)]
                    freeTiles.append(temp)
                }
            }
        }
        return freeTiles
    }
    
    private func drawBoard() {
        clearScreen()
        drawAscii()
        drawScoreBoard()
        
        for y in 0..<gameBoardPlaySize {
            printWithNoNewLine("  ")
            if y == 0 {
                printWithNoNewLine("┌")
            } else {
                printWithNoNewLine("├")
            }
            for i in 0..<gameBoardPlaySize {
                printWithNoNewLine("──────")
                if i < gameBoardPlaySize - 1 {
                    if y == 0 {
                        printWithNoNewLine("┬")
                    } else {
                        printWithNoNewLine("┼")
                    }
                } else {
                    if y == 0 {
                        printWithNoNewLine("┐")
                    } else {
                        printWithNoNewLine("┤")
                    }
                }
            }
            endl();
            printWithNoNewLine(" ")
            
            for x in 0..<gameBoardPlaySize {
                let currentTile = board[Int(y)][Int(x)]
                printWithNoNewLine(" │ ")
                if currentTile.value == 0 {
                    printWithNoNewLine("    ")
                } else {
                    let mode = currentTile.tileColor(Int(currentTile.value))
                    printWithNoNewLine("\(currentTile.value)".padding(toLength: 4, withPad: " ", startingAt: 0).applyMode(mode: mode).bold_on, "".bold_off.def)
                }
            }
            
            printWithNoNewLine(" │ ")
            endl()
        }
        
        
        printWithNoNewLine("  └")
        for i in 0..<gameBoardPlaySize {
            printWithNoNewLine("──────")
            if i < gameBoardPlaySize - 1 {
                printWithNoNewLine("┴")
            } else {
                printWithNoNewLine("┘")
            }
        }
        endl(3)
    }
    
    private func drawScoreBoard() {
        // TODO
    }
    
    private func input(_ err: KeyInputErrorStatus = .STATUS_INPUT_VALID) {
        moved = false
        
        printWithNoNewLine("  W or K or \u{2191} => Up")
        endl()
        printWithNoNewLine("  A or H or \u{2190} => Left")
        endl()
        printWithNoNewLine("  S or J or \u{2193} => Down")
        endl()
        printWithNoNewLine("  D or L or \u{2192} => Right")
        endl()
        printWithNoNewLine("  Z or P => Save")
        endl(2)
        printWithNoNewLine("  Press the keys to start and continue.")
        endl()
        
        if err == .STATUS_INPUT_ERROR {
            printWithNoNewLine("  Invalid input. Please try again.".red, "".def)
            endl(2)
        }
        
        var c = inputChar()
        if c == CODE_ANSI_TRIGGER_1 {
            c = inputChar()
            if c == CODE_ANSI_TRIGGER_2 {
                let c = inputChar().charString
                endl(4)
                switch c {
                case CODE_ANSI_UP:
                    decideMove(.UP)
                case CODE_ANSI_DOWN:
                    decideMove(.DOWN)
                case CODE_ANSI_LEFT:
                    decideMove(.LEFT)
                case CODE_ANSI_RIGHT:
                    decideMove(.RIGHT)
                default:
                    _  = 1
                }
                unblockTiles()
                return
            } else {
                endl(4)
            }
        }
        
        endl(4)
        switch c.charString.uppercased() {
        case CODE_WASD_UP,
             CODE_VIM_UP:
            decideMove(.UP)
        case CODE_WASD_LEFT,
             CODE_VIM_LEFT:
            decideMove(.LEFT);
            break;
        case CODE_WASD_DOWN,
             CODE_VIM_DOWN:
            decideMove(.DOWN);
            break;
        case CODE_WASD_RIGHT,
             CODE_VIM_RIGHT:
            decideMove(.RIGHT);
            break;
        case CODE_HOTKEY_ACTION_SAVE,
             CODE_HOTKEY_ALTERNATE_ACTION_SAVE:
            saveState();
            stateSaved = true
        default:
            drawBoard();
            input(.STATUS_INPUT_ERROR)
        }
        unblockTiles()
    }
    
    private func canMove() -> Bool {
        for y in board {
            for x in y {
                if x.value == 0 {
                    return true
                }
            }
        }
        
        for (y, out) in board.enumerated() {
            for (x, element) in out.enumerated()  {
                if testAdd(y + 1, x, element.value) {
                    return true
                }
                if testAdd(y - 1, x, element.value) {
                    return true
                }
                if testAdd(y, x + 1, element.value) {
                    return true
                }
                if testAdd(y, x - 1, element.value) {
                    return true
                }
            }
        }
        return false
    }
    
    private func testAdd(_ y: Int, _ x: Int, _ value: UInt) -> Bool {
        
        if y < 0 || y > gameBoardPlaySize - 1 || x < 0 || x > gameBoardPlaySize - 1 {
            return false
        }
        
        return board[y][x].value == value
    }
    
    private func unblockTiles() {
        
        for y in board {
            for x in y {
                x.blocked = false
            }
        }
        
    }
    
    private func decideMove(_ direction: Directions) {
        switch direction {
        case .UP:
            for (x, _) in board.enumerated() {
                var y = 1
                while y < gameBoardPlaySize {
                    if board[y][x].value != 0 {
                        move(y, x, -1, 0)
                    }
                    y += 1
                }
            }
        case .DOWN:
            for x in board.indices {
                var y = Int(gameBoardPlaySize) - 2
                while y >= 0 {
                    if board[Int(y)][Int(x)].value != 0 {
                        move(Int(y), Int(x), 1, 0)
                    }
                    y -= 1
                }
            }
        case .LEFT:
            for y in board.indices {
                var x = 1
                while x < gameBoardPlaySize {
                    if board[Int(y)][x].value != 0 {
                        move(y, x, 0, -1)
                    }
                    x += 1
                }
            }
        case .RIGHT:
            for y in board.indices {
                var x = Int(gameBoardPlaySize) - 2
                while x >= 0 {
                    if board[Int(y)][Int(x)].value != 0 {
                        move(y, Int(x), 0, 1)
                    }
                    x -= 1
                }
            }

        }
    }
    
    private func move(_ y: Int, _ x: Int, _ k: Int, _ l: Int) {
        let GAME_TILE_WINNING_SCORE = 2048
        let currentTile = board[y][x]
        let targetTile = board[y + k][x + l]
        let A = currentTile.value
        let B = targetTile.value
        let C = currentTile.blocked
        let D = targetTile.blocked
        
        if B != 0 && A == B && !C && !D {
            
            currentTile.value = 0
            targetTile.value *= 2
            score += targetTile.value
            targetTile.blocked = true
            
            largestTile =
                largestTile < targetTile.value ? targetTile.value : largestTile;
            if (!win) {
                if (targetTile.value == GAME_TILE_WINNING_SCORE) {
                    win = true;
                    printWithNoNewLine("  You win! Press any key to continue or 'x' to exit: ".green.bold_on, "".bold_off.def)
                    let c = inputChar().charString.uppercased()
                    switch c {
                    case "X":
                        rexit = true
                    default:
                        break
                    }
                }
            }
            
            moved = true;
        } else if A != 0 && B == 0 {
            
            targetTile.value = currentTile.value;
            currentTile.value = 0;
            
            moved = true;
            
        }
        if (k + l == 1 && (k == 1 ? y : x) < gameBoardPlaySize - 2) {
            move(y + k, x + l, k, l);
        } else if (k + l == -1 && (k == -1 ? y : x) > 1) {
            move(y + k, x + l, k, l);
        }
    }
    
    private func statistics() {
        printWithNoNewLine("  STATISTICS".yellow, "".def)
        endl()
        printWithNoNewLine("  ──────────".yellow, "".def)
        endl()
        printWithNoNewLine("  Final score:       ", "\(score)".bold_on, "".bold_off)
        endl()
        printWithNoNewLine("  Largest Tile:      ", "\(largestTile)".bold_on, "".bold_off)
        endl();
        printWithNoNewLine("  Number of moves:   ", "\(moveCount)".bold_on, "".bold_off)
        endl();
        printWithNoNewLine("  Time taken:        ", secondsFormat(duration).bold_on, "".bold_off)
        endl()
        
    }
    
    private func saveStats() {
        let stats = Stats()
        stats.collectStatistics()
        stats.bestScore = stats.bestScore < score ? score : stats.bestScore
        stats.gameCount += 1
        stats.winCount = win ? stats.winCount + 1 : stats.winCount
        stats.totalMoveCount += moveCount
        stats.totalDuration += duration
        
        // TODO
        //        std::fstream statistics("../data/statistics.txt");
        //        statistics << stats.bestScore << std::endl
        //        << stats.gameCount << std::endl
        //        << stats.winCount << std::endl
        //        << stats.totalMoveCount << std::endl
        //        << stats.totalDuration;
    }
    
    private func saveScore() {
        let s = Scoreboard()
        s.score = score
        s.win = win
        s.moveCount = moveCount
        s.largestTile = largestTile
        s.duration = duration
        s.save()
    }
    
    private func saveState() {
//        std::remove("../data/previousGame");
//        std::remove("../data/previousGameStats");
//        std::fstream stats("../data/previousGameStats", std::ios_base::app);
//        std::fstream stateFile("../data/previousGame", std::ios_base::app);
//        for (int y = 0; y < gameBoardPlaySize; y++) {
//            for (int x = 0; x < gameBoardPlaySize; x++) {
//                stateFile << board[y][x].value << ":" << board[y][x].blocked << ",";
//                endl();
//            }
//            stateFile << "\n";
//        }
//        stateFile.close();
//        stats << score << ":" << moveCount;
//        stats.close();
    }
    
    private func playGame(_ cont: ContinueStatus) {
        let startTime = Date()
        while true {
            if moved {
                if !addTile() {
                    drawBoard()
                    break
                }
            }
            
            drawBoard()
            if stateSaved {
                printWithNoNewLine("The game has been saved feel free to take a break.".green.bold_on, "".def, "".bold_off)
                endl(2)
                stateSaved = false
            }
            input();
        }
        let finishTime = Date()
        duration = finishTime.timeIntervalSince1970 - startTime.timeIntervalSince1970
        
        let msg = win ? "  You win!" : "  Game over! You lose."
        if win {
            printWithNoNewLine(msg.green.bold_on, "".def, "".bold_off)
        } else {
            printWithNoNewLine(msg.red.bold_on, "".def, "".bold_off)
        }
        endl(3)
        
        if gameBoardPlaySize == COMPETITION_GAME_BOARD_PLAY_SIZE &&
            cont == .STATUS_END_GAME {
            statistics()
            saveStats()
            endl(2)
            saveScore()
        }
    }
    
    private func setBoardSize() {
        let MIN_GAME_BOARD_PLAY_SIZE = 3
        let MAX_GAME_BOARD_PLAY_SIZE = 10
        var err = false
        gameBoardPlaySize = 4
        
        while gameBoardPlaySize < MIN_GAME_BOARD_PLAY_SIZE ||
            gameBoardPlaySize > MAX_GAME_BOARD_PLAY_SIZE {
                clearScreen()
                drawAscii()
                
                if err {
                    printWithNoNewLine("  Invalid input. Gameboard size should range from \(MIN_GAME_BOARD_PLAY_SIZE) to \(MAX_GAME_BOARD_PLAY_SIZE).".red, "".def)
                    endl(2)
                } else if (noSave) {
                    printWithNoNewLine("No save game exist, Starting a new game.".red.bold_on, "".def.bold_off)
                    endl(2)
                    noSave = false
                }
                printWithNoNewLine("  Enter gameboard size (NOTE: Scores and statistics will be saved only for the 4x4 gameboard): ".bold_on, "".bold_off)
                
                if let s = readLine(), let value = UInt(s) {
                    gameBoardPlaySize = value
                }
                err = true
        }
    }
}
