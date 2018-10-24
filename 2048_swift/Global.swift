import Foundation

extension CChar {
    var charString: String {
        let s = [self, 0]
        return String(cString: s)
    }
}

func inputChar() -> CChar {
    var output: CChar = 0
    getInput(&output)
    return output
}

func printWithNoNewLine(_ items: Any...) {
    for item in items {
        print(item, separator: "", terminator: "")
    }
}

func randInt() -> Int {
    // TODO
    return 0
}

extension FileManager {
    func stringContent(at path: String, _ parentPath: String = FileManager.default.currentDirectoryPath) -> String? {
        if let data = FileManager.default.contents(atPath: "\(parentPath)/\(path)") {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

func drawAscii() {
    let logo =
"""
    /\\\\\\\\\\\\\\\\\\          /\\\\\\\\\\\\\\                /\\\\\\         /\\\\\\\\\\\\\\\\\\
  /\\\\\\///////\\\\\\      /\\\\\\/////\\\\\\            /\\\\\\\\\\       /\\\\\\///////\\\\\\
  \\///      \\//\\\\\\    /\\\\\\    \\//\\\\\\         /\\\\\\/\\\\\\      \\/\\\\\\     \\/\\\\\\
             /\\\\\\/    \\/\\\\\\     \\/\\\\\\       /\\\\\\/\\/\\\\\\      \\///\\\\\\\\\\\\\\\\\\/
           /\\\\\\//      \\/\\\\\\     \\/\\\\\\     /\\\\\\/  \\/\\\\\\       /\\\\\\///////\\\\\\
         /\\\\\\//         \\/\\\\\\     \\/\\\\\\   /\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\   /\\\\\\      \\//\\\\\\
        /\\\\\\/            \\//\\\\\\    /\\\\\\   \\///////////\\\\\\//   \\//\\\\\\      /\\\\\\
        /\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\   \\///\\\\\\\\\\\\\\/              \\/\\\\\\      \\///\\\\\\\\\\\\\\\\\\/
        \\///////////////      \\///////                \\///         \\/////////
"""
    print(logo.bold_on.green)
    endl(2)
}

func clearScreen() {
    system("clear")
}

func endl(_ n: Int = 1) {
    var n = n
    while n > 0 {
        print("")
        n -= 1
    }
}

func secondsFormat(_ sec: Double) -> String {
    var s = sec
    var m = Int(s/60)
    s -= Double(m) * 60
    let h = m/60;
    m %= 60
    s = Double(Int(s))
    
    var res = ""
    if h > 0 {
        res = "\(h)h "
    }
    if m > 0 {
        res += "\(m)m "
    }
    res += "\(s)s "
    return res
}

@discardableResult
func system(_ args: String...) -> Int32 {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}
