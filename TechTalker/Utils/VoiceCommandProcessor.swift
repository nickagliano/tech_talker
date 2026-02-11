import Foundation

/// Processes voice commands and converts them to markdown formatting
class VoiceCommandProcessor {
    
    /// Voice command mappings for markdown formatting
    private static var markdownCommands: [String: (String) -> String] = [
        // Code formatting
        "backtick": { content in "`\(content)`" },
        "code": { content in "`\(content)`" },
        "code block": { content in "```\n\(content)\n```" },
        "triple backtick": { content in "```\n\(content)\n```" },
        
        // Text formatting
        "bold": { content in "**\(content)**" },
        "italic": { content in "*\(content)*" },
        "strikethrough": { content in "~~\(content)~~" },
        
        // Headers
        "heading 1": { content in "# \(content)" },
        "heading 2": { content in "## \(content)" },
        "heading 3": { content in "### \(content)" },
        "header 1": { content in "# \(content)" },
        "header 2": { content in "## \(content)" },
        "header 3": { content in "### \(content)" },
        
        // Lists
        "bullet point": { content in "- \(content)" },
        "dash": { content in "- \(content)" },
        "number list": { content in "1. \(content)" },
        
        // Links
        "link": { content in "[\(content)]()" },
        
        // Quotes
        "quote": { content in "> \(content)" },
        "block quote": { content in "> \(content)" }
    ]
    
    /// Simple voice commands that don't require content (like "new line")
    private static var simpleCommands: [String: String] = [
        "new line": "\n",
        "newline": "\n",
        "line break": "\n",
        "paragraph": "\n\n"
    ]
    
    /// Process transcribed text and convert voice commands to markdown
    /// - Parameter text: The transcribed text from speech recognition
    /// - Returns: Text with voice commands converted to markdown syntax
    static func processVoiceCommands(_ text: String) -> String {
        var processedText = text
        
        // Process markdown commands (content-based)
        for (voiceCommand, formatter) in markdownCommands {
            processedText = processVoiceCommand(
                in: processedText,
                voiceCommand: voiceCommand,
                formatter: formatter
            )
        }
        
        // Process simple commands (no content needed)
        for (voiceCommand, replacement) in simpleCommands {
            processedText = processSimpleCommand(
                in: processedText,
                voiceCommand: voiceCommand,
                replacement: replacement
            )
        }
        
        return processedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Process a specific voice command in the text
    private static func processVoiceCommand(
        in text: String,
        voiceCommand: String,
        formatter: (String) -> String
    ) -> String {
        var result = text
        
        // Pattern: "command content command" -> formatted content
        let pattern = "\\b\(NSRegularExpression.escapedPattern(for: voiceCommand))\\s+(.+?)\\s+\(NSRegularExpression.escapedPattern(for: voiceCommand))\\b"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let matches = regex.matches(in: result, options: [], range: NSRange(location: 0, length: result.count))
            
            // Process matches in reverse order to maintain string indices
            for match in matches.reversed() {
                if let contentRange = Range(match.range(at: 1), in: result) {
                    let content = String(result[contentRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                    let formattedContent = formatter(content)
                    
                    if let fullRange = Range(match.range, in: result) {
                        result.replaceSubrange(fullRange, with: formattedContent)
                    }
                }
            }
        } catch {
            print("Regex error for command '\(voiceCommand)': \(error)")
        }
        
        return result
    }
    
    /// Process simple commands that don't require content
    private static func processSimpleCommand(
        in text: String,
        voiceCommand: String,
        replacement: String
    ) -> String {
        var result = text
        
        // Handle common speech recognition patterns for the command
        let commonVariations = [
            voiceCommand,
            "\(voiceCommand),", 
            "\(voiceCommand).",
            ", \(voiceCommand)",
            ". \(voiceCommand)",
            " \(voiceCommand) ",
            ", \(voiceCommand),",
            ", \(voiceCommand).",
        ]
        
        for variation in commonVariations {
            // Use simple string replacement (case insensitive)
            let beforeReplace = result
            result = result.replacingOccurrences(of: variation, with: replacement, options: .caseInsensitive)
            
            // If we made a replacement, break to avoid double-processing
            if result != beforeReplace {
                break
            }
        }
        
        return result
    }
    
    /// Get all available voice commands
    static func getAllCommands() -> [String: String] {
        var allCommands: [String: String] = [:]
        
        // Add markdown commands with their pattern description
        for (command, _) in markdownCommands {
            allCommands[command] = "\(command) [content] \(command)"
        }
        
        // Add simple commands
        for (command, replacement) in simpleCommands {
            allCommands[command] = "\(command) → \(replacement.replacingOccurrences(of: "\n", with: "\\n"))"
        }
        
        return allCommands
    }
    
    /// Add a markdown command
    static func addMarkdownCommand(_ command: String, formatter: @escaping (String) -> String) {
        markdownCommands[command] = formatter
        saveCommands()
    }
    
    /// Add a simple command
    static func addSimpleCommand(_ command: String, replacement: String) {
        simpleCommands[command] = replacement
        saveCommands()
    }
    
    /// Remove a command
    static func removeCommand(_ command: String) {
        markdownCommands.removeValue(forKey: command)
        simpleCommands.removeValue(forKey: command)
        saveCommands()
    }
    
    /// Save commands to UserDefaults
    private static func saveCommands() {
        // Save simple commands (they're just string mappings)
        UserDefaults.standard.set(simpleCommands, forKey: "VoiceCommandProcessor.simpleCommands")
        
        // For markdown commands, we'll save just the command names since the formatters can't be serialized
        let markdownCommandNames = Array(markdownCommands.keys)
        UserDefaults.standard.set(markdownCommandNames, forKey: "VoiceCommandProcessor.markdownCommands")
    }
    
    /// Load commands from UserDefaults
    static func loadCommands() {
        // Load simple commands
        if let savedSimpleCommands = UserDefaults.standard.dictionary(forKey: "VoiceCommandProcessor.simpleCommands") as? [String: String] {
            simpleCommands = savedSimpleCommands
        }
    }
}