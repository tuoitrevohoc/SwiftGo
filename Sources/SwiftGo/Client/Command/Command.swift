//
//  Command.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-20.
//

import Foundation
import NIO

/// the protocol command
protocol AnyCommand {
    
    /// the opcode of this command
    static var opCode: OpCode {
        get
    }
    
    /// the size of the command
    var size: Int {
        get
    }
    
    /// Write to a byte buffer
    /// - Parameter buffer: the byte buffer
    func write(to buffer: inout ByteBuffer)
}
