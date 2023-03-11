// swiftlint:disable all
import Amplify
import Foundation

extension AnnouncerPushNotif {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case body
    case deviceToken
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let announcerPushNotif = AnnouncerPushNotif.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "AnnouncerPushNotifs"
    
    model.attributes(
      .primaryKey(fields: [announcerPushNotif.id])
    )
    
    model.fields(
      .field(announcerPushNotif.id, is: .required, ofType: .string),
      .field(announcerPushNotif.body, is: .required, ofType: .string),
      .field(announcerPushNotif.deviceToken, is: .required, ofType: .string),
      .field(announcerPushNotif.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(announcerPushNotif.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension AnnouncerPushNotif: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}