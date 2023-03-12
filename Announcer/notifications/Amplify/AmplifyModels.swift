// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "499d0139d05422bee2c055cb540a15aa"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: AnnouncerPushNotif.self)
  }
}