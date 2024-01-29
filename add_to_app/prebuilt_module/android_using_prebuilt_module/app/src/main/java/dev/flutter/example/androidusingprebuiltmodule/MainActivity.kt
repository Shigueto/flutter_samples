// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.example.androidusingprebuiltmodule

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.android.FlutterActivity
import java.lang.RuntimeException

class MainActivity : AppCompatActivity() {
    private lateinit var counterLabel: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        counterLabel = findViewById(R.id.counter_label)

        val button = findViewById<Button>(R.id.launch_button)

        button.setOnClickListener {
            val intent = FlutterActivity
                .withCachedEngine(ENGINE_ID)
                .build(this)
            startActivity(intent)
        }
        val crashButton = findViewById<Button>(R.id.crashlytics_exception)
        crashButton.setOnClickListener {
            throw RuntimeException("teste")
        }

    }

    override fun onResume() {
        super.onResume()
        val app = application as MyApplication
        counterLabel.text = "Current count: ${app.count}"
    }
}
