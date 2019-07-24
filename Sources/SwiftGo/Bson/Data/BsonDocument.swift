//
//  BsonDocument.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-17.
//

import Foundation

/// bson document
public struct BsonDocument {
    
    /// Size of document boundary
    static let boundary = 5
    
    /// size for the type byte
    static let typeByteSize = 1
    
    /// Null ending size
    static let nullEndingSize = 1
    
    /// the size of the document
    var size: Int {
        BsonDocument.boundary
            + elements.map(toElementSize).reduce(0, { $0 + $1})
    }
    
    /// list of the element
    var elements: [String: BsonValue]
    
    /// get or set an element
    public subscript(index: String) -> Any? {
        
        // get an item
        get {
            return elements[index]?.rawValue
        }
        
        // set an item
        set (newValue) {
            if let value = BsonValue.from(rawValue: newValue) {
                elements[index] = value
            }
        }
    }
    
    /// the size of the document
    fileprivate func keySize(_ key: String) -> Int {
        return key.count + BsonDocument.nullEndingSize
    }
    
    /// Calculate an element size
    /// - Parameter key: the key
    /// - Parameter value: the value
    fileprivate func toElementSize(key: String, value: BsonValue) -> Int {
        BsonDocument.typeByteSize + keySize(key) + value.size
    }
}
