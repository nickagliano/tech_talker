import Foundation

/// Swift wrapper for autocorrect functionality (disabled)
class AutocorrectWrapper {
    
    /// Format text using autocorrect (disabled - returns original text)
    /// - Parameter text: The text to format
    /// - Returns: The original text unchanged
    static func format(_ text: String) -> String {
        return text
    }
    
    /// Format text for a specific file type (disabled - returns original text)
    /// - Parameters:
    ///   - text: The text to format
    ///   - filename: The filename to determine formatting rules
    /// - Returns: The original text unchanged
    static func format(_ text: String, for filename: String) -> String {
        return text
    }
    
    /// Check if autocorrect library is available (always returns false)
    /// - Returns: false (autocorrect is disabled)
    static func isAvailable() -> Bool {
        return false
    }
}