//
//  BinarySubType.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-17.
//

import Foundation

/// Sub type for a binary field
public enum BinarySubType: UInt8 {
    case generic = 0x00
    case function = 0x01
    case uuid = 0x04
    case md5 = 0x05
    case userDefined = 0x80
}
