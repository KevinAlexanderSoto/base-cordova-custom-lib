package com.kalex.plugings.helloWorld;

import android.widget.Toast;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * This class echoes a string called from JavaScript.
 */
public class CordovaHelloWorld extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("sayHello")) {
            String message = args.getString(0);
            this.sayHello(message, callbackContext);
            return true;
        }
        return false;
    }

    private void sayHello(String message, CallbackContext callbackContext) {
        if (message != null && message.length() > 0) {
            Toast.makeText(webView.getContext(), message, Toast.LENGTH_LONG).show();
            callbackContext.success(message);
        } else {
            callbackContext.error("Expected one non-empty string argument.");
        }
    }
}
