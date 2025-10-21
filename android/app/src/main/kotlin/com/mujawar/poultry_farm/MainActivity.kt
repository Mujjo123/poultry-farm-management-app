package com.mujawar.poultry_farm

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.telephony.SmsManager
import android.util.Log
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.mujawar.poultry_farm/sms"
    private val TAG = "PoultryFarm_SMS"
    private val SMS_SENT = "SMS_SENT"
    private val SMS_DELIVERED = "SMS_DELIVERED"

    private val sentReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (resultCode) {
                RESULT_OK -> {
                    Log.d(TAG, "✅ SMS sent successfully!")
                    Toast.makeText(context, "SMS sent successfully!", Toast.LENGTH_SHORT).show()
                }
                SmsManager.RESULT_ERROR_GENERIC_FAILURE -> {
                    Log.e(TAG, "❌ SMS failed: Generic failure")
                    Toast.makeText(context, "SMS failed to send", Toast.LENGTH_LONG).show()
                }
                SmsManager.RESULT_ERROR_NO_SERVICE -> {
                    Log.e(TAG, "❌ SMS failed: No service")
                    Toast.makeText(context, "No network service", Toast.LENGTH_LONG).show()
                }
                SmsManager.RESULT_ERROR_NULL_PDU -> {
                    Log.e(TAG, "❌ SMS failed: Null PDU")
                    Toast.makeText(context, "SMS failed: Null PDU", Toast.LENGTH_LONG).show()
                }
                SmsManager.RESULT_ERROR_RADIO_OFF -> {
                    Log.e(TAG, "❌ SMS failed: Radio off")
                    Toast.makeText(context, "Please turn on your radio/network", Toast.LENGTH_LONG).show()
                }
            }
        }
    }

    private val deliveredReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (resultCode) {
                RESULT_OK -> {
                    Log.d(TAG, "✅ SMS delivered to recipient!")
                    Toast.makeText(context, "SMS delivered!", Toast.LENGTH_SHORT).show()
                }
                else -> {
                    Log.e(TAG, "❌ SMS not delivered")
                    Toast.makeText(context, "SMS not delivered", Toast.LENGTH_LONG).show()
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register receivers
        registerReceiver(sentReceiver, IntentFilter(SMS_SENT), RECEIVER_NOT_EXPORTED)
        registerReceiver(deliveredReceiver, IntentFilter(SMS_DELIVERED), RECEIVER_NOT_EXPORTED)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openSMSApp" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")
                    
                    Log.d(TAG, "Opening SMS app for: $phoneNumber")
                    Log.d(TAG, "Message: $message")
                    
                    if (phoneNumber != null && message != null) {
                        try {
                            val intent = Intent(Intent.ACTION_SENDTO).apply {
                                data = Uri.parse("smsto:$phoneNumber")
                                putExtra("sms_body", message)
                            }
                            
                            if (intent.resolveActivity(packageManager) != null) {
                                startActivity(intent)
                                Log.d(TAG, "✅ SMS app opened successfully")
                                result.success("success")
                            } else {
                                Log.e(TAG, "❌ No SMS app found")
                                result.error("NO_SMS_APP", "No SMS app found on device", null)
                            }
                        } catch (e: Exception) {
                            Log.e(TAG, "❌ Error opening SMS app: ${e.message}", e)
                            result.error("SMS_ERROR", e.message, null)
                        }
                    } else {
                        Log.e(TAG, "❌ Invalid arguments: phoneNumber or message is null")
                        result.error("INVALID_ARGS", "Phone number or message is null", null)
                    }
                }
                "sendSMS" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")
                    
                    Log.d(TAG, "Attempting to send SMS to: $phoneNumber")
                    Log.d(TAG, "Message: $message")
                    
                    if (phoneNumber != null && message != null) {
                        try {
                            val sentPI = PendingIntent.getBroadcast(
                                this, 0, Intent(SMS_SENT), PendingIntent.FLAG_IMMUTABLE
                            )
                            val deliveredPI = PendingIntent.getBroadcast(
                                this, 0, Intent(SMS_DELIVERED), PendingIntent.FLAG_IMMUTABLE
                            )
                            
                            val smsManager = SmsManager.getDefault()
                            
                            // Split message if it's too long (>160 characters)
                            if (message.length > 160) {
                                Log.d(TAG, "Message is long (${message.length} chars), splitting into parts")
                                val parts = smsManager.divideMessage(message)
                                val sentIntents = ArrayList<PendingIntent>()
                                val deliveredIntents = ArrayList<PendingIntent>()
                                
                                for (i in parts.indices) {
                                    sentIntents.add(sentPI)
                                    deliveredIntents.add(deliveredPI)
                                }
                                
                                smsManager.sendMultipartTextMessage(
                                    phoneNumber,
                                    null,
                                    parts,
                                    sentIntents,
                                    deliveredIntents
                                )
                            } else {
                                smsManager.sendTextMessage(
                                    phoneNumber,
                                    null,
                                    message,
                                    sentPI,
                                    deliveredPI
                                )
                            }
                            
                            Log.d(TAG, "✅ SMS queued for sending")
                            result.success("success")
                        } catch (e: Exception) {
                            Log.e(TAG, "❌ SMS send failed: ${e.message}", e)
                            Toast.makeText(this, "Error: ${e.message}", Toast.LENGTH_LONG).show()
                            result.error("SMS_ERROR", e.message, null)
                        }
                    } else {
                        Log.e(TAG, "❌ Invalid arguments: phoneNumber or message is null")
                        result.error("INVALID_ARGS", "Phone number or message is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(sentReceiver)
            unregisterReceiver(deliveredReceiver)
        } catch (e: Exception) {
            Log.e(TAG, "Error unregistering receivers: ${e.message}")
        }
    }
}
