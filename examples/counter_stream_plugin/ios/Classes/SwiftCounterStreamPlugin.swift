import Flutter
import UIKit

public class SwiftCounterStreamPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    var sink: FlutterEventSink? = nil
    var timer: Timer = Timer()
    var counter = 0
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.sink = events
        startTimer()
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.sink = nil
        stopTimer()
        return nil
    }
    
    func startTimer(){
        stopTimer()
        sendSink()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(sendSink), userInfo: nil, repeats: true)
    }
    
    @objc func sendSink(){
        guard self.sink != nil else {
            return
        }
        counter += 1
        self.sink!(counter)
    }
    
    func stopTimer(){
        timer.invalidate()
    }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterEventChannel(name: "counter_stream_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftCounterStreamPlugin()
    channel.setStreamHandler(instance)
  }

}
