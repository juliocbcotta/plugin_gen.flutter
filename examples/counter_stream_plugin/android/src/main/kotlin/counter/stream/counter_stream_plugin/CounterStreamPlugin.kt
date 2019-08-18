package counter.stream.counter_stream_plugin


import android.os.Handler
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.*

class CounterStreamPlugin(registrar: Registrar) : StreamHandler {

    private val handler = Handler()
    private var counter = 0
    private var timer: Timer? = null
    private var sink: EventSink? = null


    init {
        // when the Activity is destroyed there is no call,
        // so we need to do it ourselves.
        registrar.addViewDestroyListener {
            onCancel(null)
            false
        }
    }

    private fun stopTimer() {
        if (timer != null) {
            timer?.cancel()
            timer?.purge()
        }
    }

    private fun startTimer() {
        stopTimer()
        timer = Timer()
        val timerTask = object : TimerTask() {
            override fun run() {
                handler.post {
                    sink!!.success(++counter)
                }
            }
        }
        timer!!.schedule(timerTask, 0, 1000)
    }


    override fun onListen(p0: Any?, sink: EventSink) {
        this.sink = sink
        startTimer()
    }

    override fun onCancel(p0: Any?) {
        stopTimer()
        sink = null

    }


    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = EventChannel(registrar.messenger(), "counter_stream_plugin")
            channel.setStreamHandler(CounterStreamPlugin(registrar))
        }
    }

}
