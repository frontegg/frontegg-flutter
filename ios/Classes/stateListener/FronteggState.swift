import Foundation

struct FronteggState {
    var accessToken: String?
    var refreshToken: String?
    var user: Dictionary<String, Any?>?
    var isAuthenticated: NSNumber
    var isLoading: NSNumber
    var initializing: NSNumber
    var showLoader: NSNumber
    var appLink: NSNumber
    var refreshingToken: NSNumber
    
    public func toMap() -> Dictionary<String, Any?> {
        return [
            "accessToken": accessToken,
            "refreshToken": refreshToken,
            "user": user,
            "isAuthenticated": isAuthenticated,
            "isLoading": isLoading,
            "initializing": initializing,
            "showLoader": showLoader,
            "appLink": appLink,
            "refreshingToken": refreshingToken,
        ]
    }
}
