import Foundation
import Flutter

protocol FronteggStateListener {
    func setEventSink(eventSink: FlutterEventSink?)
    
    func subscribe()
    
    func dispose()
}
