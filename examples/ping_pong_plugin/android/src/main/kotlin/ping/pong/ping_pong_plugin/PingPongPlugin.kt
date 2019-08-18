package ping.pong.ping_pong_plugin

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class PingPongPlugin(private val channel: MethodChannel) : MethodCallHandler {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "ping_pong_plugin")
            channel.setMethodCallHandler(PingPongPlugin(channel))
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "ping" -> {
                result.success(null)
                channel.invokeMethod("pong", "ping reply")
            }
            "ping2" -> result.success("pong2")
            else -> result.notImplemented()
        }
    }
}
