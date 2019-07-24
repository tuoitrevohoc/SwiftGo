//
//  MongoConnectionTests.swift
//  SwiftGoTests
//
//  Created by Tran Thien Khiem on 2019-07-21.
//

import XCTest
import NIO
@testable import SwiftGo

/// testing the mongo connection
class MongoConnectionTests: XCTestCase {
    
    /// Test connecting to database
    func testConnection() throws {
        let connection = try MongoConnection(host: "localhost")
                .connect()
                .wait()
        
        XCTAssertNotNil(connection.channel)
    }
    
    /// Test create a record
    func testCreate() throws {
        let document = BsonDocument(
            elements: [
                "_id": .objectId([
                    0x1, 0x2, 0x3, 0x4, 0x5, 0x6,
                    0x7, 0x8, 0x9, 0xA, 0xB, 0xC
                ]),
                "name": .string("Daniel")
            ]
        )
        
        XCTAssertEqual(39, document.size)
        
        let command = InsertCommand(to: "test.test", document: document)
        
        let connection = try MongoConnection(host: "localhost")
                        .connect()
                        .wait()
        _ = try connection.send(command: command).wait()
    }
}
