import FronteggSwift

extension RegionConfig {
    func toMap() -> [String: Any?] {
        return [
            "key": key,
            "baseUrl": baseUrl,
            "clientId": clientId,
            "applicationId": applicationId,
        ]
    }
}
