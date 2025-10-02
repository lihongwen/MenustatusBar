//
//  CircularBuffer.swift
//  MenubarStatus
//
//  Created by AI Assistant on 2025-10-02.
//

import Foundation

/// A generic circular buffer implementation for fixed-capacity data storage
/// When full, new items replace the oldest items automatically
struct CircularBuffer<T> {
    private var buffer: [T?]
    private var head = 0  // Index where next element will be written
    private var count = 0  // Current number of elements
    private let capacity: Int
    
    init(capacity: Int) {
        precondition(capacity > 0, "Capacity must be positive")
        self.capacity = capacity
        self.buffer = Array(repeating: nil, count: capacity)
    }
    
    /// Add an element to the buffer, replacing the oldest if full
    mutating func append(_ element: T) {
        buffer[head] = element
        head = (head + 1) % capacity
        count = min(count + 1, capacity)
    }
    
    /// Get all elements as an array, ordered from oldest to newest
    func asArray() -> [T] {
        guard count > 0 else { return [] }
        
        var result: [T] = []
        result.reserveCapacity(count)
        
        // If buffer isn't full, elements are from 0 to count-1
        if count < capacity {
            for i in 0..<count {
                if let element = buffer[i] {
                    result.append(element)
                }
            }
        } else {
            // Buffer is full, start from head (oldest element)
            for i in 0..<capacity {
                let index = (head + i) % capacity
                if let element = buffer[index] {
                    result.append(element)
                }
            }
        }
        
        return result
    }
    
    /// Number of elements currently in the buffer
    var currentCount: Int {
        return count
    }
    
    /// Whether the buffer is full
    var isFull: Bool {
        return count == capacity
    }
    
    /// Whether the buffer is empty
    var isEmpty: Bool {
        return count == 0
    }
    
    /// Clear all elements from the buffer
    mutating func clear() {
        buffer = Array(repeating: nil, count: capacity)
        head = 0
        count = 0
    }
}

