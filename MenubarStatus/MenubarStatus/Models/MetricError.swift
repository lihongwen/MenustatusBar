//
//  MetricError.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation

/// Errors that can occur during metric collection
enum MetricError: Error, LocalizedError {
    case permissionDenied
    case systemAPIUnavailable
    case timeout
    case invalidData
    case pathNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permission denied to access system metrics"
        case .systemAPIUnavailable:
            return "System monitoring API is unavailable"
        case .timeout:
            return "Metric collection timed out"
        case .invalidData:
            return "Received invalid metric data from system"
        case .pathNotFound(let path):
            return "Path not found: \(path)"
        }
    }
}




