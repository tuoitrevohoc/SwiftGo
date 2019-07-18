//
//  BsonDocument.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-17.
//

import Foundation

/// bson document
struct BsonDocument {
    
    /// the size of the document
    let size: Int
    
    /// list of the element
    let elements: [BsonElement]
}
