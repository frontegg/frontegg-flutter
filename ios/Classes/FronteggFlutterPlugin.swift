import Flutter
import UIKit
import FronteggSwift

public class FronteggFlutterPlugin: NSObject, FlutterPlugin {
    private static let fronteggApp = FronteggApp.shared
    private static let methodChannelName: String = "frontegg_flutter"
    private static let stateEventChanelName: String = "frontegg_flutter/state_stream"
    private static var stateListener: FronteggStateListener? = nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let stateEventChannel = FlutterEventChannel(name: stateEventChanelName, binaryMessenger: registrar.messenger())
        stateListener = FronteggStateListenerImpl(fronteggApp: fronteggApp)
        
        let methodCallHandler = FronteggMethodCallHandler(fronteggApp: fronteggApp, stateListener: stateListener!)
        let channel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: registrar.messenger())
        channel.setMethodCallHandler(methodCallHandler.handle)
        
        
        let streamHandler = StateStreamHandler(stateListener: stateListener!)
        stateEventChannel.setStreamHandler(streamHandler)
        
        let instance = FronteggFlutterPlugin()
        registrar.addApplicationDelegate(instance)
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
