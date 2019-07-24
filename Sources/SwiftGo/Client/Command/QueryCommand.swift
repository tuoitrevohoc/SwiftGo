//
//  QueryCommand.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-23.
//
import Foundation
import NIO

/// The query options
public struct QueryOptions: OptionSet {
    
    /// the raw value
    public let rawValue: UInt32
    
    /// Tailable means cursor is not closed when the last data is retrieved.
    ///  Rather, the cursor marks the final object’s position.
    ///  You can resume using the cursor later, from where it was located,
    ///  if more data were received.
    ///  Like any “latent cursor”,
    ///  the cursor may become invalid at some point (CursorNotFound)
    ///  – for example if the final object it references were deleted.
    public static let tailableCursor = QueryOptions(rawValue: 1)
    
    /// Allow query of replica slave.
    /// Normally these return an error except for namespace “local”.
    public static let slaveOk = QueryOptions(rawValue: 1 << 2)
    
    /// Internal replication use only - driver should not set.
    public static let oplogReplay = QueryOptions(rawValue: 1 << 3)
    
    /// The server normally times out idle cursors after an inactivity period
    /// (10 minutes) to prevent excess memory use.
    /// Set this option to prevent that.
    public static let noCursorTimeout = QueryOptions(rawValue: 1 << 4)
    
    /// Use with TailableCursor.
    /// If we are at the end of the data,
    /// block for a while rather than returning no data.
    /// After a timeout period, we do return as normal.
    public static let awaitData = QueryOptions(rawValue: 1 << 5)
    
    /// Stream the data down full blast in multiple “more” packages,
    /// on the assumption that the client will fully read all data queried.
    /// Faster when you are pulling a lot of data and
    /// know you want to pull it all down.
    /// Note: the client is not allowed to not read all
    /// the data unless it closes the connection.
    public static let exhaust = QueryOptions(rawValue: 1 << 6)
    
    /// Get partial results from a mongos if some shards are down
    /// (instead of throwing an error)
    public static let partial = QueryOptions(rawValue: 1 << 7)
    
    /// Initialize the item
    /// - Parameter rawValue: the value
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

/// The OP_QUERY message is used to query the database for documents in a collection.
public struct QueryCommand: AnyCommand {

    /// The query command opcode
    static let opCode = OpCode.query
    
    /// The flags
    var options: QueryOptions
    
    /// The full collection name; i.e. namespace.
    /// The full collection name is the concatenation of the database name with the collection name,
    /// using a . for the concatenation.
    /// For example, for the database foo and the collection bar, the full collection name is foo.bar.
    var fullCollectionName: String
    
    /// Sets the number of documents to omit - starting from the first document in the resulting dataset - when returning the result of the query.
    var numberToSkip: UInt32

    /// Limits the number of documents in the first OP_REPLY message to the query.
    /// However, the database will still establish a cursor and return the cursorID to the client if there are more results than numberToReturn.
    /// If the client driver offers ‘limit’ functionality (like the SQL LIMIT keyword),
    /// then it is up to the client driver to ensure that no more than the specified number of document are returned to the calling application.
    /// If numberToReturn is 0, the db will use the default return size.
    /// If the number is negative, then the database will return that number and close the cursor.
    /// No further results for that query can be fetched.
    /// If numberToReturn is 1 the server will treat it as -1 (closing the cursor automatically).
    var numberToReturn: UInt32
    
    /// BSON document that represents the query.
    /// The query will contain one or more elements, all of which must match for a document to be included in the result set.
    /// Possible elements include $query, $orderby, $hint, and $explain.
    var query: BsonDocument
    
    /// Optional.
    /// BSON document that limits the fields in the returned documents.
    /// The returnFieldsSelector contains one or more elements,
    /// each of which is the name of a field that should be returned,
    /// and and the integer value 1. In JSON notation, a returnFieldsSelector to limit to the fields a, b and c would be:
    ///
    /// { a : 1, b : 1, c : 1}
    var fieldSelector: BsonDocument? = nil
    
    /// the size of the query
    public var size: Int {
        4
        + fullCollectionName.count
        + 8
        + query.size
        + (fieldSelector?.size ?? 0)
    }
    
    /// Write this command into a buffer
    /// - Parameter buffer: the byte buffer
    public func write(to buffer: inout ByteBuffer) {
        buffer.writeInteger(options.rawValue, endianness: .little)
        buffer.writeString(fullCollectionName)
        buffer.writeInteger(0 as UInt8)
        buffer.writeInteger(numberToSkip, endianness: .little)
        buffer.writeInteger(numberToReturn, endianness: .little)
        buffer.write(document: query)
        
        if let fieldSelector = fieldSelector {
            buffer.write(document: fieldSelector)
        }
    }
}
