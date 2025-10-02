//
//  AppLanguage.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import Foundation

/// Supported application languages
enum AppLanguage: String, Codable, CaseIterable {
    case english = "en"
    case chinese = "zh"
    
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .chinese:
            return "中文"
        }
    }
    
    var nativeName: String {
        switch self {
        case .english:
            return "English"
        case .chinese:
            return "中文（简体）"
        }
    }
}


