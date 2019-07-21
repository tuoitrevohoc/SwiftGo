//
//  MessageHeader.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-20.
//

import Foundation
import NIO

/// the mongodb opcode
enum OpCode: UInt32 {
    /// Reply to a client request. responseTo is set.
    case reply = 1
    
    /// Update document.
    case update = 2001
    
    /// Insert new document.
    case insert = 2002
    
    /// Query a collection.
    case query = 2004
    
    /// Get more data from a query. See Cursors.
    case getMore = 2005
    
    /// Delete documents.
    case delete = 2006
    
    /// Notify database that the client has finished with the cursor.
    case killCursor = 2007
    
    /// Send a message using the format introduced in MongoDB 3.6
    case message = 2013
}

/// The message header
public struct MessageHeader {

    /// The total size of the message in bytes. This total includes the 4 bytes that holds the message length.
    let messageLength: UInt32
    
    /// A client or database-generated identifier that uniquely identifies this message.
    /// For the case of client-generated messages (e.g. OP_QUERY and OP_GET_MORE),
    /// it will be returned in the responseTo field of the OP_REPLY message.
    /// Clients can use the requestID and the responseTo fields to associate query responses with the originating query.
    let requestId: UInt32
    
    /// In the case of a message from the database, this will be the requestID taken from the OP_QUERY or OP_GET_MORE messages from the client.
    ///  Clients can use the requestID and the responseTo fields to associate query responses with the originating query.
    let responseTo: UInt32
    
    /// Type of message.
    let opCode: OpCode
    
    /// Size of the message header
    static let size = 16
}

/// the message header
extension ByteBuffer {
    
    /// read the message header
    mutating func readMessageHeader() -> MessageHeader? {
        if let messageLength = readInteger(endianness: .little, as: UInt32.self),
            let requestId = readInteger(endianness: .little, as: UInt32.self),
            let responseTo = readInteger(endianness: .little, as: UInt32.self),
            let opCodeRaw = readInteger(endianness: .little, as: UInt32.self),
            let opCode = OpCode(rawValue: opCodeRaw) {
            
            return MessageHeader(
                messageLength: messageLength,
                requestId: requestId,
                responseTo: responseTo,
                opCode: opCode
            )
        }
        
        return nil
    }
    
    /// Write message header to the buffer
    /// - Parameter messageHeader: the message header
    mutating func write(messageHeader: MessageHeader) {
        writeInteger(messageHeader.messageLength, endianness: .little, as: UInt32.self)
        writeInteger(messageHeader.requestId, endianness: .little, as: UInt32.self)
        writeInteger(messageHeader.responseTo, endianness: .little, as: UInt32.self)
        writeInteger(messageHeader.opCode.rawValue, endianness: .little, as: UInt32.self)
    }
}
