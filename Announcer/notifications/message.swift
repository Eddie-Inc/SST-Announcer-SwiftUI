//
//  message.swift
//  Announcer
//
//  Created by Ayaan Jain on 11/3/23.
//

import Foundation
import Amplify

public struct Message: Model {
    public let id: String
    public var body: String
    public var deviceToken: String
    
    public init(id: String = UUID().uuidString,
                body: String,
                deviceToken: String){
                self.id = id
                self.body = body
                self.deviceToken = deviceToken
    }
}
