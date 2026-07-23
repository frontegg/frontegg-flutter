import Foundation
import Flutter

protocol FronteggStateListener {
    func setEventSink(eventSink: FlutterEventSink?)
    
    func subscribe()

    func dispose()

    /// Emit the current auth state to Flutter on demand (used by `forceStateUpdate`, FR-25944).
    func forceNotifyChanges()
}
