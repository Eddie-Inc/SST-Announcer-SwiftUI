//
//  HTMLString.swift
//  Announcer
//
//  Created by Kai Quan Tay on 7/1/23.
//

import Foundation

private let htmlTagRegex = try? NSRegularExpression(pattern: "<[^>]+>", options: .caseInsensitive)
private let undesirableRegex = try? NSRegularExpression(pattern: "(font-size: [^;]+;|color: #[0-9a-fA-F]{6};|background-color: \\w+;)", options: .caseInsensitive)

extension String {
    func stripHTML() -> String {
        // Use a regular expression to strip out HTML tags
        guard let htmlTagRegex else { return self }
        let range = NSRange(location: 0, length: self.utf16.count)
        let htmlStripped = htmlTagRegex.stringByReplacingMatches(in: self,
                                                                 range: range,
                                                                 withTemplate: "")

        // Remove &nbsp;
        let decodedHTML = htmlStripped.replacingOccurrences(of: "&nbsp;", with: "")
        return decodedHTML
    }

    func stripHtmlFont() -> String {
        // Use a regular expression to strip out HTML tags
        guard let undesirableRegex else { return self }

        let range = NSRange(location: 0, length: self.utf16.count)
        let undesirableStripped = undesirableRegex.stringByReplacingMatches(in: self,
                                                                            range: range,
                                                                            withTemplate: "")

        return undesirableStripped
    }

    @available(*, deprecated, message: "This causes attribute graph errors")
    var htmlDecoded: String {
        let decoded = try? NSAttributedString(data: Data(utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil).string

        return decoded ?? self
    }
}
