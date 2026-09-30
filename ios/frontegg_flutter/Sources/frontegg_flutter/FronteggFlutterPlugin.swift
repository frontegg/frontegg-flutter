import Flutter
import UIKit
import FronteggSwift

public class FronteggFlutterPlugin: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate {
    private static let fronteggApp = FronteggApp.shared
    private static let methodChannelName: String = "frontegg_flutter"
    private static let stateEventChanelName: String = "frontegg_flutter/state_stream"
    private static var stateListener: FronteggStateListener? = nil
    private var pendingLaunchLinks: [URL] = []
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodCallHandler = FronteggMethodCallHandler(fronteggApp: fronteggApp)
        let channel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: registrar.messenger())
        channel.setMethodCallHandler(methodCallHandler.handle)
        
        let stateEventChannel = FlutterEventChannel(name: stateEventChanelName, binaryMessenger: registrar.messenger())
        stateListener = FronteggStateListenerImpl(fronteggApp: fronteggApp)
        methodCallHandler.setStateListener(stateListener!)
        let streamHandler = StateStreamHandler(stateListener: stateListener!)
        stateEventChannel.setStreamHandler(streamHandler)
        
        let instance = FronteggFlutterPlugin()
        registrar.publish(instance)
        registrar.addApplicationDelegate(instance)
        registrar.addSceneDelegate(instance)
    }

    public func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions?
    ) -> Bool {
        guard let connectionOptions else { return false }
        let launchLinks = connectionOptions.userActivities.compactMap(\.webpageURL)
            + connectionOptions.urlContexts.map(\.url)
        pendingLaunchLinks = launchLinks.filter(Self.isFronteggLink)
        return !pendingLaunchLinks.isEmpty
    }

    public func sceneDidBecomeActive(_ scene: UIScene) {
        let launchLinks = pendingLaunchLinks
        pendingLaunchLinks = []
        _ = launchLinks.contains { FronteggAuth.shared.handleOpenUrl($0, true) }
    }

    public func scene(_ scene: UIScene, continue userActivity: NSUserActivity) -> Bool {
        guard let link = userActivity.webpageURL else { return false }
        return FronteggAuth.shared.handleOpenUrl(link, true)
    }

    public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
        URLContexts.contains { FronteggAuth.shared.handleOpenUrl($0.url, true) }
    }

    static func isFronteggLink(_ link: URL) -> Bool {
        let baseUrl = FronteggAuth.shared.baseUrl
        return !baseUrl.isEmpty && link.absoluteString.hasPrefix(baseUrl)
    }
    
    public func detachFromEngine(for registrar: any FlutterPluginRegistrar) {
        FronteggFlutterPlugin.stateListener?.dispose()
    }
    
    class StateStreamHandler: NSObject, FlutterStreamHandler {
        var stateListener: FronteggStateListener
        
        init(stateListener: FronteggStateListener) {
            self.stateListener = stateListener
        }
        
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            stateListener.setEventSink(eventSink:events)
            stateListener.subscribe()
            return nil
        }
        
        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            stateListener.setEventSink(eventSink: nil)
            return nil
        }
    }
}
