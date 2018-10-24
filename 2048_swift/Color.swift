import Foundation

#if os(Linux) || CYGWIN
import Glibc
#else
import Darwin.C
#endif

private func getEnvValue(_ key: String) -> String? {
    guard let value = getenv(key) else {
        return nil
    }
    return String(cString: value)
}

// MARK: - Color

enum Color: Int {
    case BOLD = 1
    case RESET = 0
    case BG_BLUE = 44
    case BG_DEFAULT = 49
    case BG_GREEN = 42
    case BG_RED = 41
    case FG_BLACK = 30
    case FG_BLUE = 34
    case FG_CYAN = 36
    case FG_DARK_GRAY = 90
    case FG_DEFAULT = 39
    case FG_GREEN = 32
    case FG_LIGHT_BLUE = 94
    case FG_LIGHT_CYAN = 96
    case FG_LIGHT_GRAY = 37
    case FG_LIGHT_GREEN = 92
    case FG_LIGHT_MAGENTA = 95
    case FG_LIGHT_RED = 91
    case FG_LIGHT_YELLOW = 93
    case FG_MAGENTA = 35
    case FG_RED = 31
    case FG_WHITE = 97
    case FG_YELLOW = 33
}

extension Color {
    var xcode: String {
        switch self {
        case .FG_BLACK: return "fg0,0,0"
        case .FG_RED: return "fg255,0,0"
        case .FG_GREEN: return "fg0,204,0"
        case .FG_YELLOW: return "fg255,255,0"
        case .FG_BLUE: return "fg0,0,255"
        case .FG_MAGENTA: return "fg255,0,255"
        case .FG_CYAN: return "fg0,255,255"
        case .FG_WHITE: return "fg204,204,204"
        case .FG_DEFAULT: return ""
        case .FG_LIGHT_RED: return "fg255,102,102"
        case .FG_LIGHT_GREEN: return "fg102,255,102"
        case .FG_LIGHT_YELLOW: return "fg255,255,102"
        case .FG_LIGHT_BLUE: return "fg102,102,255"
        case .FG_LIGHT_MAGENTA: return "fg255,102,255"
        case .FG_LIGHT_CYAN: return "fg102,255,255"
        case .BG_DEFAULT: return ""
        case .BG_RED: return "bg255,0,0"
        case .BG_GREEN: return "bg0,204,0"
        case .BG_BLUE: return "bg0,0,255"
        default: return ""
//        case .BOLD: return ""
//        case .RESET: return ""
//        case .FG_LIGHT_GRAY: return ""
//        case .FG_DARK_GRAY: return ""
        }
    }
}

struct Modifier {
    static let bold_off = Modifier(code: Color.RESET)
    static let bold_on = Modifier(code: Color.BOLD)
    static let def = Modifier(code: Color.FG_DEFAULT)
    static let red = Modifier(code: Color.FG_RED)
    static let green = Modifier(code: Color.FG_GREEN)
    static let yellow = Modifier(code: Color.FG_YELLOW)
    static let blue = Modifier(code: Color.FG_BLUE)
    static let magenta = Modifier(code: Color.FG_MAGENTA)
    static let cyan = Modifier(code: Color.FG_CYAN)
    static let lightGray = Modifier(code: Color.FG_LIGHT_GRAY)
    static let darkGray = Modifier(code: Color.FG_DARK_GRAY)
    static let lightRed = Modifier(code: Color.FG_LIGHT_RED)
    static let lightGreen = Modifier(code: Color.FG_LIGHT_GREEN)
    static let lightYellow = Modifier(code: Color.FG_LIGHT_YELLOW)
    static let lightBlue = Modifier(code: Color.FG_LIGHT_BLUE)
    static let lightMagenta = Modifier(code: Color.FG_LIGHT_MAGENTA)
    static let lightCyan = Modifier(code: Color.FG_LIGHT_CYAN)
    let code: Color
}

extension Modifier: CustomStringConvertible {
    var description: String {
        let isXcode = (getEnvValue("XcodeColors") == "YES")
        let isConsole: Bool
        let termType = getEnvValue("TERM")
        if let t = termType, t.lowercased() != "dumb" && isatty(fileno(stdout)) != 0 {
            isConsole = true
        } else {
            isConsole = false
        }
        if isXcode {
            return "\u{001B}[\(code.xcode)m"
        } else if isConsole {
            return "\u{001B}[0;\(code.rawValue)m"
        }
        return ""
    }
}

extension String {
    func applyMode(mode: Modifier) -> String {
        return "\(mode)\(self)"
    }
    var bold_off: String { return applyMode(mode: Modifier.bold_off) }
    var bold_on: String { return applyMode(mode: Modifier.bold_on) }
    var def: String { return applyMode(mode: Modifier.def) }
    var red: String { return applyMode(mode: Modifier.red) }
    var green: String { return applyMode(mode: Modifier.green) }
    var yellow: String { return applyMode(mode: Modifier.yellow) }
    var blue: String { return applyMode(mode: Modifier.blue) }
    var magenta: String { return applyMode(mode: Modifier.magenta) }
    var cyan: String { return applyMode(mode: Modifier.cyan) }
    var lightGray: String { return applyMode(mode: Modifier.lightGray) }
    var darkGray: String { return applyMode(mode: Modifier.darkGray) }
    var lightRed: String { return applyMode(mode: Modifier.lightRed) }
    var lightGreen: String { return applyMode(mode: Modifier.lightGreen) }
    var lightYellow: String { return applyMode(mode: Modifier.lightYellow) }
    var lightBlue: String { return applyMode(mode: Modifier.lightBlue) }
    var lightMagenta: String { return applyMode(mode: Modifier.lightMagenta) }
    var lightCyan: String { return applyMode(mode: Modifier.lightCyan) }
}
