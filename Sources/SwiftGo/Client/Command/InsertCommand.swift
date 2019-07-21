//
//  InsertCommand.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-20.
//

import Foundation
import NIO

public struct InsertOptions: OptionSet {
    
    /// the raw value
    public let rawValue: UInt32
    
    /// continue on error
    static let continueOnError = InsertOptions(rawValue: 1)
    
    /// Initialize the item
    /// - Parameter rawValue: the value
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

/// Insert the command
public struct InsertCommand: AnyCommand {
    
    /// the opCode
    static let opCode = OpCode.insert
    
    /// the size of the element
    var size: Int {
        4 + collectionName.count + 1 + documents.reduce(0, { $0 + $1.size })
    }
    
    /// the collection name
    let collectionName: String
    
    /// insert options
    let options: InsertOptions
    
    /// list of documents to inser
    let documents: [BsonDocument]
    
    /// Create this command for inserting documents
    ///
    /// - Parameter collection: the collection name
    /// - Parameter documents: the documents
    /// - Parameter options: the options
    init(to collectionName: String, documents: [BsonDocument], options: InsertOptions = []) {
        self.collectionName = collectionName
        self.documents = documents
        self.options = options
    }
    
    /// Create this command for inserting one document
    ///
    /// - Parameter collectionName: the collection name
    /// - Parameter document: the document to insert
    /// - Parameter options: the options
    init(to collectionName: String, document: BsonDocument, options: InsertOptions = []) {
        self.collectionName = collectionName
        self.documents = [document]
        self.options = options
    }
    
    /// Write this command to buffer
    /// - Parameter buffer: the buffer
    func write(to buffer: inout ByteBuffer) {
        buffer.writeInteger(options.rawValue, endianness: .little, as: UInt32.self)
        buffer.writeCString(collectionName)
        
        for document in documents {
            buffer.write(document: document)
        }
    }
}
