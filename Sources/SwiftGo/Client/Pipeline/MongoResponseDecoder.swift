//
//  MongoRequestDecoder.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-20.
//

import Foundation
import NIO

/// the mongo response
struct MongoResponse {
    
    // the message header
    let messageHeader: MessageHeader
    
    // the data
    let data: ByteBuffer
}

/// THe mongo response decoder
final class MongoResponseDecoder: ChannelDuplexHandler, RemovableChannelHandler {
    
    // the type alians
    typealias InboundIn = ByteBuffer
    
    // the inbound out
    typealias InboundOut = MongoResponse
    
    // the outbout in
    typealias OutboundIn = Never
    
    /// the header buffer
    var headerBuffer: ByteBuffer
    
    /// the body buffer
    var bodyBuffer: ByteBuffer!
    
    /// read state
    enum ReadState {
        case readingHeader
        case readingBody(header: MessageHeader, buffer: ByteBuffer)
    }
    
    /// the state
    var state = ReadState.readingHeader
    
    /// init function
    init() {
        let allocator = ByteBufferAllocator()
        headerBuffer = allocator.buffer(capacity: MessageHeader.size)
    }
    
    /// The channel read
    /// - Parameter context: the context
    /// - Parameter data: the data
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var incoming = unwrapInboundIn(data)
        
        print("Message received: \(incoming.readableBytes) bytes")
        
        while incoming.readableBytes > 0 {
            let readableBytes = incoming.readableBytes
            
            switch state {
            case .readingHeader:
                let availableBytes = headerBuffer.readableBytes
                
                if readableBytes + availableBytes >= MessageHeader.size {
                    let missingBytes = MessageHeader.size - availableBytes
                    
                    if var headerBufferData = incoming.readSlice(length: missingBytes) {
                        headerBuffer.writeBuffer(&headerBufferData)
                        
                        if let parsedHeader = headerBuffer.readMessageHeader() {
                            headerBuffer.moveReaderIndex(to: 0)
                            headerBuffer.moveWriterIndex(to: 0)
                            
                            let buffer = context.channel.allocator.buffer(capacity: Int(parsedHeader.messageLength))
                            state = .readingBody(header: parsedHeader, buffer: buffer)
                        } else {
                            print("Couldn't parse the message header")
                        }
                    }
                    
                } else {
                    headerBuffer.writeBuffer(&incoming)
                }
                
            case .readingBody(let header, var buffer):
                let existingBytes = buffer.readableBytes
                let remainBytes = Int(header.messageLength) - existingBytes
                let availableBytes = min(incoming.readableBytes, remainBytes)
                
                if availableBytes > 0 {
                    if var fragment = incoming.readSlice(length: availableBytes) {
                        buffer.writeBuffer(&fragment)
                    } else {
                        print("Couldn't read the message")
                    }
                }
                
                if buffer.readableBytes == header.messageLength {
                    let message = MongoResponse(messageHeader: header, data: buffer)
                    context.fireChannelRead(wrapInboundOut(message))
                    
                    print("Receiving message: \(header.messageLength) bytes")
                    
                    state = .readingHeader
                } else {
                    state = .readingBody(header: header, buffer: buffer)
                }
            }
        }
        
    }
}
