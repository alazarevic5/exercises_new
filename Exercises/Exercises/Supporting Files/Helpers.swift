//
//  Helpers.swift
//  Exercises
//
//  Created by Aleksandra Lazarevic on 20.2.22..
//

import Foundation

// MARK: Setup constants here

class Config {
    static let baseURL              = "https://wger.de/api/v2/"
    static let exerciseInfoEndPoint = "exerciseinfo"
    
    static let pageLimit            = 20
}

// MARK: Useful extensions

extension String {
    func htmlAttributedString() -> NSAttributedString? {
        let htmlTemplate = """
        <!doctype html>
        <html>
          <head>
            <style>
              body {
                font-family: -apple-system;
                font-size: 15px;
              }
            </style>
          </head>
          <body>
            \(self)
          </body>
        </html>
        """

        guard let data = htmlTemplate.data(using: .utf16) else {
            return nil
        }

        guard let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
            ) else {
            return nil
        }
        return attributedString
    }
}
