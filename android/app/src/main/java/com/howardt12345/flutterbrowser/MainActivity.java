package com.howardt12345.flutterbrowser;

import android.content.Intent;
import android.os.Bundle;

import java.nio.ByteBuffer;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.ActivityLifecycleListener;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  String sharedText;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    Intent intent = getIntent();
    String action = intent.getAction();
    String type = intent.getType();

    handleSendText(intent); // Handle text being sent

    new MethodChannel(getFlutterView(), "app.channel.shared.data").setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        if (methodCall.method.contentEquals("getSharedText")) {
          result.success(sharedText);
            sharedText = null;
        }
      }
    });
  }

  void handleSendText(Intent intent) {
    sharedText = getUrlFromIntent(intent);
  }
  private String getUrlFromIntent(Intent intent) {
    return intent != null ? intent.getDataString() : null;
  }
}