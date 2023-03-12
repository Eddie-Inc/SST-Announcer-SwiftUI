// swiftlint:disable all
import Amplify
import Foundation

public struct AnnouncerPushNotif: Model {
  public let id: String
  public var body: String
  public var deviceToken: String
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      body: String,
      deviceToken: String) {
    self.init(id: id,
      body: body,
      deviceToken: deviceToken,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      body: String,
      deviceToken: String,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.body = body
      self.deviceToken = deviceToken
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}