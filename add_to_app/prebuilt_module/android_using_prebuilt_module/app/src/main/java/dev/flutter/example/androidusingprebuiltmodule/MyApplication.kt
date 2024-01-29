// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.example.androidusingprebuiltmodule

import androidx.multidex.MultiDexApplication
import com.google.firebase.crashlytics.FirebaseCrashlytics
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

const val ENGINE_ID = "1"

class MyApplication : MultiDexApplication() {
    var count = 0

    private lateinit var channel: MethodChannel

    override fun onCreate() {
        super.onCreate()

        val flutterEngine = FlutterEngine(this)
        flutterEngine
            .dartExecutor
            .executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )

        FlutterEngineCache.getInstance().put(ENGINE_ID, flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor, "dev.flutter.example/counter")

        channel.setMethodCallHandler { call, _ ->
            when (call.method) {
                "incrementCounter" -> {
                    count++
                    reportCounter()
                }

                "requestCounter" -> {
                    reportCounter()
                }

                "reportException" -> {
                    val stack = call.argument<String>("stack")!!
                    reportException(stack)
                }
            }
        }
    }

    private fun reportCounter() {
        channel.invokeMethod("reportCounter", count)
    }

    private fun reportException(stackTrace: String) {
        val message = "Flutter Exception"
        val elements = ArrayList<StackTraceElement>()
        // Use regex to remove lines that starts with *** ***
        val regex = Regex(
            "^(pid:|os:|isolate.*:|build_id:|\\*\\*\\* \\*\\*\\*).*\n",
            setOf(RegexOption.MULTILINE)
        )
        val stack = stackTrace.replace(regex, "")
        stack.split('\n').forEach { stackLine ->
            val stackElement = generateTraceElement(stackLine)
            elements.add(element = stackElement)
        }
        val e = FlutterException(message, message)
        e.stackTrace = elements.toTypedArray()
        FirebaseCrashlytics.getInstance().recordException(e)
    }

    private fun generateTraceElement(stackInfo: String): StackTraceElement {
        val declaringClass = ""
        val fileName = null
        val lineNumber = -2
        return StackTraceElement(declaringClass, stackInfo, fileName, lineNumber)
    }
}


class FlutterException internal constructor(message: String?, cause: String?) :
    Throwable(
        message,
        FlutterCause(cause),
        false,
        true
    )


class FlutterCause internal constructor(cause: String?) : Throwable(
    cause,
    null,
    false,
    true
) {
    init {
        val elements = arrayOf(
            StackTraceElement("", cause, null, -2)
        )
        stackTrace = elements
    }
}
