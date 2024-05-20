import Foundation
import Combine
import FronteggSwift
import Flutter


class FronteggStateListenerImpl: FronteggStateListener {
    private let fronteggApp: FronteggApp
    private var eventSink: FlutterEventSink? = nil
    private var cancellables = Set<AnyCancellable>()
    
    init(fronteggApp: FronteggApp) {
        self.fronteggApp = fronteggApp
    }
    
    func setEventSink(eventSink: FlutterEventSink?) {
        self.eventSink = eventSink
    }
    
    func subscribe() {
        let auth = fronteggApp.auth
        var anyChange: AnyPublisher<Void, Never> {
            return Publishers.Merge8 (
                auth.$accessToken.map { _ in },
                auth.$refreshToken.map {_ in },
                auth.$user.map {_ in },
                auth.$isAuthenticated.map {_ in },
                auth.$isLoading.map {_ in },
                auth.$initializing.map {_ in },
                auth.$showLoader.map {_ in },
                auth.$appLink.map {_ in }
            )
            .eraseToAnyPublisher()
        }
        
        anyChange.sink(receiveValue: { () in
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0.1) {
                let auth =  self.fronteggApp.auth
                
                var jsonUser: [String: Any]? = nil
                if let userData = try? JSONEncoder().encode(auth.user) {
                    jsonUser = try? JSONSerialization.jsonObject(with: userData, options: .allowFragments) as? [String: Any]
                }
                
                let state = FronteggState(
                    accessToken: auth.accessToken,
                    refreshToken: auth.refreshToken,
                    user: jsonUser,
                    isAuthenticated: NSNumber(value: auth.isAuthenticated),
                    isLoading: NSNumber(value: auth.isLoading),
                    initializing: NSNumber(value: auth.initializing),
                    showLoader: NSNumber(value: auth.showLoader),
                    appLink: NSNumber(value: auth.appLink)
                )
                
                self.sendState(state: state)
            }
            
        }).store(in: &cancellables)
    }
    
    func dispose() {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
        cancellables = Set<AnyCancellable>()
    }
    
    private func sendState(state: FronteggState) {
        DispatchQueue.main.sync {
            eventSink?(state.toMap())
        }
    }
}
