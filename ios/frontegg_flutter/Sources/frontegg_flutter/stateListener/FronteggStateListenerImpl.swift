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
        // Cancel any prior subscriptions first: onListen can run again (e.g. Flutter hot restart
        // or re-listen) and appending to `cancellables` without clearing leaked Combine sinks and
        // fired updateState() once per accumulated sink (FR-25944).
        dispose()

        let auth = fronteggApp.auth
        var stateChange: AnyPublisher<Void, Never> {
            return Publishers.MergeMany(
                auth.$refreshingToken.map { _ in },
                auth.$isAuthenticated.map {_ in },
                auth.$isLoading.map {_ in },
                auth.$initializing.map {_ in },
                auth.$showLoader.map {_ in },
                auth.$isOfflineMode.map { _ in },
            )
            .eraseToAnyPublisher()
        }
        
        var dataChange: AnyPublisher<Void, Never> {
            return Publishers.Merge4 (
                auth.$accessToken.map { _ in },
                auth.$refreshToken.map {_ in },
                auth.$user.map {_ in },
                auth.$selectedRegion.map{_ in}
            )
            .eraseToAnyPublisher()
        }
        
        stateChange.sink(receiveValue: { () in
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0.1) {
                self.updateState()
            }
        }).store(in: &cancellables)
        
        dataChange.sink(receiveValue: { () in
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 0.1) {
                self.updateState()
            }
        }).store(in: &cancellables)
    }
    
    func forceNotifyChanges() {
        // Hop off the calling thread before updateState(): sendState() uses DispatchQueue.main.sync,
        // and forceStateUpdate is invoked from the method-channel handler on the main thread, so a
        // direct call would deadlock. This mirrors how the Combine sinks dispatch updateState().
        DispatchQueue.global(qos: .userInteractive).async {
            self.updateState()
        }
    }

    private func updateState() {
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
            appLink: NSNumber(value: auth.appLink),
            refreshingToken: NSNumber(value: auth.refreshingToken),
            isOfflineMode: NSNumber(value: auth.isOfflineMode)
        )
        
        self.sendState(state: state)
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
