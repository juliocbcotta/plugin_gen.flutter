package flutter.gen.sample.flutter_gen_sample_plugin

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import android.os.Handler
import java.util.*


class FlutterGenSamplePlugin(val methodChannel: MethodChannel) : MethodCallHandler, EventChannel.StreamHandler {
  private var timer: Timer? = null
  private var timerTask: TimerTask? = null
  private val handler = Handler()

  private fun stopTimer() {
    if (timer != null) {
      timer?.cancel()
      timer?.purge()
    }
  }

  val data1 = MyData(data = "text1", value = MyValue.VALUE_1)
  val data2 = MyData(data = "text2", value = MyValue.VALUE_2)
  val other = MyOtherData(otherData = "other text")

  private fun startTimer() {
    stopTimer()
    timer = Timer()
    timerTask = object : TimerTask() {
      override fun run() {
        handler.post {
          sink?.success(mapOf(++counter to data2.copy(data = (counter).toString()).toJson()))

          if (counter == 3) {
            methodChannel.invokeMethod("onDataList", listOf(data2.copy(data = (counter).toString()).toJson()), object : Result {
              override fun notImplemented() {

              }

              override fun error(p0: String?, p1: String?, p2: Any?) {
                println(p0!!)
              }

              override fun success(data: Any?) {
                val d = data as Map<Any, Any>
                d.map { (key, value) -> MyData.fromJson(key) to MyValue.valueOf(value.toString()) }
                println(d.toString())
              }
            })
          }
        }
      }
    }
    timer?.schedule(timerTask, 0, 1000)
  }

  var sink: EventSink? = null
  var counter = 0
  override fun onListen(p0: Any?, sink: EventSink) {
    this.sink = sink
  }

  override fun onCancel(p0: Any?) {
    sink = null
  }

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val methodChannel = MethodChannel(registrar.messenger(), "my channel name")
      val eventChannel = EventChannel(registrar.messenger(), "my event channel")
      val plugin = FlutterGenSamplePlugin(methodChannel)
      methodChannel.setMethodCallHandler(plugin)
      eventChannel.setStreamHandler(plugin)
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {

    methodChannel.invokeMethod("onData", data1.toJson(), object : Result {
      override fun error(p0: String?, p1: String?, p2: Any?) {

      }

      override fun success(p0: Any?) {
        val data = MyOtherData.fromJson(p0!!)
        println(data)
      }

      override fun notImplemented() {

      }
    })

    when (call.method) {
      "receiveSuperComplexData" -> {
        val map1 = mapOf(data1.toJson() to other.toJson())
        val map2 = mapOf(other.toJson() to data1.toJson())
        val complexMap = mapOf(listOf(map1) to other.toJson())
        val map = mapOf(complexMap to map2)

        result.success(map)
      }
      "sendSuperComplexData" -> {
        result.success(call.arguments)
      }
      "startCounter" -> {
        startTimer()
        result.success(null)
      }
      "stopCounter" -> {
        stopTimer()
        counter = 0
        result.success(null)
      }
      "receiveString" -> result.success("Android")
      "receiveVoid" -> result.success(null)
      "receiveNull" -> result.success(null)
      "receiveInt" -> result.success(42)
      "receiveDouble" -> result.success(1.0)
      "receiveSimpleStringList" -> result.success(listOf("a", "b", "c"))
      "receiveSimpleIntList" -> result.success(listOf(1, 2, 3))
      "receiveSimpleMap" -> result.success(mapOf(1.0 to "some value", 2.0 to "value 2"))
      "receiveComplexMap" -> result.success(mapOf(data1.toJson() to other.toJson(), data2.toJson() to other.toJson()))
      "receiveSimpleKeyComplexValueMap" -> result.success(mapOf("key1" to other.toJson(), "key2" to other.toJson()))
      "receiveComplexKeySimpleValueMap" -> result.success(mapOf(data1.toJson() to "value1", data2.toJson() to "value2"))
      "receiveMyData" -> {
        val data1 = MyData(data = "some text", value = MyValue.VALUE_1)
        result.success(data1.toJson())
      }
      "receiveMyDataList" -> {
        result.success(listOf(data1.toJson(), data2.toJson()))
      }
      "sendString" -> {
        val str = call.arguments as String
        result.success(str)
      }
      "sendMultipleDartTypes" -> {
        val str = call.argument<String>("str")!!
        val number = call.argument<Int>("number")!!
        val floating = call.argument<Double>("floating")!!
        result.success("$str \n\n $number \n\n $floating")
      }
      "sendMultipleMixedTypes" -> {
        val data = MyData.fromJson(call.argument<Any>("data")!!)
        val str = call.argument<String>("str")!!
        val listAny = call.argument<Any>("datas") as List<Any>
        val myDataList = listAny.map { MyData.fromJson(it) }
        val listAnyNumber = call.argument<Any>("number") as List<Any>
        val intList = listAnyNumber.map { it as Int }
        val floating = call.argument<Double>("floating")!!

        result.success("$data\n\n $str\n\n $myDataList\n\n $intList\n\n $floating")
      }
      "sendMyData" -> {
        val data = MyData.fromJson(call.arguments)
        result.success(data.toJson())
      }
      "sendMyDataList" -> {
        val list = call.arguments as List<Any>
        val myDataList = list.map { MyData.fromJson(it) }
        val jsonList = myDataList.map { it.toJson() }
        result.success(jsonList)
      }
      "sendSimpleMap" -> {
        val map = call.arguments as Map<String, String>
        result.success(map)
      }
      "sendSimpleKeyComplexValueMap" -> {
        val map = call.arguments as Map<String, Any>
        val mapped = map.map { (key, value) -> key to MyOtherData.fromJson(value) }.toMap()
        result.success(mapped.map { (key, value) -> key to value.toJson() }.toMap())
      }
      "sendComplexKeySimpleValueMap" -> {
        val map = call.arguments as Map<Any, String>
        val mapped = map.map { (key, value) -> MyData.fromJson(key) to value }.toMap()
        result.success(mapped.map { (key, value) -> key.toJson() to value }.toMap())
      }
      "sendComplexMap" -> {
        val map = call.arguments as Map<Any, Any>
        val mapped = map.map { (key, value) -> MyData.fromJson(key) to MyOtherData.fromJson(value) }.toMap()
        result.success(mapped.map { (key, value) -> key.toJson() to value.toJson() }.toMap())
      }
      "sendMultipleMaps" -> {
        val map = call.arguments as Map<String, Any>
        val map1 = map["map1"] as Map<String, String>
        val map2 = map["map2"] as Map<String, Any>
        val map3 = map["map3"] as Map<Any, String>
        val map4 = map["map4"] as Map<Any, Any>
        val mapped2 = map2.map { (key, value) -> key to MyData.fromJson(value) }.toMap()
        val mapped3 = map3.map { (key, value) -> MyData.fromJson(key) to value }.toMap()
        val mapped4 = map4.map { (key, value) -> MyData.fromJson(key) to MyOtherData.fromJson(value) }.toMap()
        result.success("$map1 \n\n $mapped2 \n\n $mapped3 \n\n $mapped4")
      }
      else -> result.notImplemented()
    }
  }
}

enum class MyValue {
  VALUE_1,
  VALUE_2
}

data class MyData(val data: String, val value: MyValue) {

  fun toJson(): Map<String, Any?> {
    return mapOf("data" to data, "value" to value.name)
  }

  companion object {
    fun fromJson(blob: Any): MyData {
      val map = blob as Map<String, Any?>
      return MyData(data = map["data"] as String, value = MyValue.valueOf(map["value"] as String))
    }
  }
}

data class MyOtherData(val otherData: String) {

  fun toJson(): Map<String, Any?> {
    return mapOf("other" to otherData)
  }

  companion object {
    fun fromJson(blob: Any): MyOtherData {
      val map = blob as Map<String, Any?>
      return MyOtherData(otherData = map["other"] as String)
    }
  }
}