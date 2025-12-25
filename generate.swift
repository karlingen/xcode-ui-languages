import Foundation

// Usage: `swift generate.swift` for JSON output, or `swift generate.swift -t` for text output.

struct LanguageInfo: Codable {
    let name: String
    let symbol: String
}

enum OutputMode {
    case json, text
}

func main() {
    let outputMode: OutputMode = CommandLine.arguments.contains("-t") ? .text : .json
    let fileURL = URL(fileURLWithPath: "xcode-ui-languages-list.txt")
    
    let identifiers: [String]
    do {
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        identifiers = contents
            .components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
    } catch {
        print("Error reading file: \(error)")
        return
    }
    
    let locale = Locale(identifier: "en-US")
    
    // Map identifiers to LanguageInfo, using display names
    let languageInfos: [LanguageInfo] = identifiers.compactMap { code in
        guard let displayName = locale.localizedString(forIdentifier: code) else { return nil }
        return LanguageInfo(name: displayName, symbol: code)
    }.sorted { $0.name < $1.name }
    
    // Ensure symbol uniqueness
    let symbols = Set(languageInfos.map { $0.symbol })
    if symbols.count != languageInfos.count {
        print("WARNING: Symbols are not unique.")
    }
    
    // Output
    switch outputMode {
    case .text:
        languageInfos.forEach { puts("\($0.name) (\($0.symbol))") }
    case .json:
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(languageInfos)
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            print("Error during JSON encoding: \(error)")
            exit(-1)
        }
    }
}

main()
