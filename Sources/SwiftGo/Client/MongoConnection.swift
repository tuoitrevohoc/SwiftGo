//
//  MongoConnection.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-20.
//

import Foundation
import NIO

/// THe mongo connection
public final class MongoConnection {
    
    /// the host
    public let host: String
    
    /// the port this connection is connecting to
    public let port: Int
    
    /// The group
    private let group: MultiThreadedEventLoopGroup
    
    /// the channel
    private(set) var channel: Channel!
    
    /// Setup a connection to host and port
    /// - Parameter host: the host
    /// - Parameter port: the port
    public init(host: String = "localhost", port: Int = 27017) {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        self.host = host
        self.port = port
    }
    
    /// Connect and return this connection
    func connect() -> EventLoopFuture<MongoConnection> {
        let bootstrap = ClientBootstrap(group: group) .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelInitializer { channel in
                channel.pipeline.addHandler(MongoResponseDecoder())
            }
        
        return bootstrap.connect(host: host, port: port)
            .map { channel in
            self.channel = channel
                
            return self
        }
    }
    
    /// Send the command to server
    /// - Parameter command: the command
    func send<T: AnyCommand>(command: T) -> EventLoopFuture<Void> {
        let messageHeader = MessageHeader(
            messageLength: UInt32(command.size + MessageHeader.size),
            requestId: 1,
            responseTo: 0,
            opCode: T.opCode
        )
        
        var buffer = channel.allocator.buffer(capacity: command.size)
        buffer.write(messageHeader: messageHeader)
        command.write(to: &buffer)
        
        assert(buffer.writerIndex == messageHeader.messageLength)
        
        print("Writing to the buffer")
        
        return channel.writeAndFlush(buffer)
    }
    
    /// deinit the object
    deinit {
        try! group.syncShutdownGracefully()
    }
}
