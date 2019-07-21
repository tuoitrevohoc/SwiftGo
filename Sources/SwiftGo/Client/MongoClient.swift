//
//  MongoClient.swift
//  CNIOAtomics
//
//  Created by Tran Thien Khiem on 2019-07-20.
//
import Foundation

/// the mongo client
public class MongoClient {
    
    /// The host name
    let host: String
    
    /// the port name
    let port: Int
    
    /// Initialize a client with host and port
    ///
    /// - Parameter host: the host
    /// - Parameter port: port
    init(host: String = "localhost", port: Int = 27017) {
        self.host = host
        self.port = port
    }
    
    /// Connect to the server
    func connect() -> MongoConnection {
        return MongoConnection(host: host, port: port)
    }
    
}
