//
//  HTMLString.swift
//  Announcer
//
//  Created by Kai Quan Tay on 7/1/23.
//

import Foundation

extension String {
    func stripHTML() -> String {
        // Use a regular expression to strip out HTML tags
        guard let regex = try? NSRegularExpression(pattern: "<[^>]+>", options: .caseInsensitive) else { return self }
        let range = NSRange(location: 0, length: self.utf16.count)
        let strippedHTML = regex.stringByReplacingMatches(in: self, range: range, withTemplate: "")

        // Decode any remaining HTML entities
        let decodedHTML = strippedHTML.htmlDecoded
        return decodedHTML
    }

    var htmlDecoded: String {
        let decoded = try? NSAttributedString(data: Data(utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil).string

        return decoded ?? self
    }
}
