//
//  DiskInfo.swift
//  MenubarStatus
//
//  Created by Specify Agent on 2025/10/2.
//

import Foundation

/// Information about a disk volume
struct DiskInfo: Identifiable, Hashable {
    let id: String
    let path: String
    let name: String
    
    var displayName: String {
        if name.isEmpty || name == "/" {
            return path
        }
        return "\(name) (\(path))"
    }
    
    init(path: String, name: String) {
        self.id = path
        self.path = path
        self.name = name
    }
}

