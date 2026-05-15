package com.example.cash_pinoy

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.core.content.ContextCompat
import android.location.LocationManager
import android.content.Context
import android.location.Location
import android.location.LocationListener
import android.location.Geocoder
import android.os.Bundle
import android.os.Looper
import java.util.Locale
import android.telephony.TelephonyManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiManager
import androidx.core.app.ActivityCompat
import kotlin.math.sqrt

class MainActivity : FlutterActivity() {
  private val channelName = "cash_pinoy/proxy"
  private var pendingGeoResult: MethodChannel.Result? = null
  private var locationListener: LocationListener? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "getSystemProxy" -> {
            val host = System.getProperty("http.proxyHost") ?: ""
            val port = System.getProperty("http.proxyPort") ?: ""
            val httpsHost = System.getProperty("https.proxyHost") ?: ""
            val httpsPort = System.getProperty("https.proxyPort") ?: ""

            val finalHost = if (host.isNotBlank()) host else httpsHost
            val finalPort = if (port.isNotBlank()) port else httpsPort

            if (finalHost.isBlank() || finalPort.isBlank()) {
              result.success(null)
            } else {
              result.success(mapOf("host" to finalHost, "port" to finalPort))
            }
          }
          "getProxyEnabled" -> {
            val host = System.getProperty("http.proxyHost") ?: ""
            val port = System.getProperty("http.proxyPort") ?: ""
            val httpsHost = System.getProperty("https.proxyHost") ?: ""
            val httpsPort = System.getProperty("https.proxyPort") ?: ""

            val finalHost = if (host.isNotBlank()) host else httpsHost
            val finalPort = if (port.isNotBlank()) port else httpsPort
            result.success(if (finalHost.isBlank() || finalPort.isBlank()) 0 else 1)
          }
          "getVpnEnabled" -> {
            result.success(0)
          }
          "getRooted" -> {
            result.success(if (isRooted()) 1 else 0)
          }
          "getIsEmulator" -> {
            result.success(if (isEmulator()) 1 else 0)
          }
          "getDeviceLanguage" -> {
            result.success(java.util.Locale.getDefault().toLanguageTag())
          }
          "getCarrierName" -> {
            try {
              val tm = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
              val name = tm.networkOperatorName ?: ""
              result.success(name)
            } catch (e: Exception) {
              result.success("")
            }
          }
          "getNetworkType" -> {
            result.success(getNetworkType())
          }
          "getTimeZoneId" -> {
            val tz = java.util.TimeZone.getDefault()
            val daylight = tz.inDaylightTime(java.util.Date())
            val value = tz.getDisplayName(daylight, java.util.TimeZone.SHORT, java.util.Locale.getDefault())
            result.success(value)
          }
          "getCpuCores" -> {
            result.success(Runtime.getRuntime().availableProcessors())
          }
          "getDeviceName" -> {
            result.success("")
          }
          "getScreenInches" -> {
            result.success(getScreenInches())
          }
          "requestAppReview" -> {
            result.success(false)
          }
          "getWifiInfo" -> {
            result.success(getWifiInfo())
          }
          "getDeviceStorageInfo" -> {
            result.success(mapOf(
              "chondriosome" to "",
              "blatted" to "",
              "bouncers" to "",
              "towrope" to ""
            ))
          }
          "getIosIdentifiers" -> result.success(null)
          "openLocationSettings" -> {
            try {
              val intent = android.content.Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS)
              intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
              startActivity(intent)
              result.success(true)
            } catch (e: Exception) {
              result.success(false)
            }
          }
          "isLocationPermissionNotDetermined" -> {
            val granted = ContextCompat.checkSelfPermission(
              this,
              android.Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
            if (granted) {
              result.success(false)
            } else {
              val canShowRationale = ActivityCompat.shouldShowRequestPermissionRationale(
                this,
                android.Manifest.permission.ACCESS_FINE_LOCATION
              )
              // Android has no strict "notDetermined" state, this is the closest signal.
              result.success(!canShowRationale)
            }
          }
          "getCurrentLocation" -> {
            val granted = ContextCompat.checkSelfPermission(
              this,
              android.Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
            if (!granted) {
              result.success(null)
              return@setMethodCallHandler
            }
            val lm = getSystemService(Context.LOCATION_SERVICE) as LocationManager
            val providers = listOf(
              LocationManager.GPS_PROVIDER,
              LocationManager.NETWORK_PROVIDER
            )
            var location: Location? = null
            for (provider in providers) {
              if (lm.isProviderEnabled(provider)) {
                try {
                  location = lm.getLastKnownLocation(provider)
                  if (location != null) break
                } catch (_: Exception) {}
              }
            }
            if (location != null) {
              result.success(buildLocationMap(location))
              return@setMethodCallHandler
            }
            pendingGeoResult = result
            val listener = object : LocationListener {
              override fun onLocationChanged(loc: Location) {
                locationListener?.let { lm.removeUpdates(it) }
                locationListener = null
                pendingGeoResult?.success(buildLocationMap(loc))
                pendingGeoResult = null
              }

              override fun onProviderEnabled(provider: String) {}
              override fun onProviderDisabled(provider: String) {}
              override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
            }
            locationListener = listener
            val provider = providers.firstOrNull { lm.isProviderEnabled(it) }
            if (provider == null) {
              pendingGeoResult?.success(null)
              pendingGeoResult = null
              return@setMethodCallHandler
            }
            try {
              lm.requestSingleUpdate(provider, listener, Looper.getMainLooper())
            } catch (_: Exception) {
              pendingGeoResult?.success(null)
              pendingGeoResult = null
            }
          }
          "getPushToken" -> {
            result.success("")
          }
          "getBatteryInfo" -> {
            try {
              val bm = getSystemService(Context.BATTERY_SERVICE) as android.os.BatteryManager
              val level = bm.getIntProperty(android.os.BatteryManager.BATTERY_PROPERTY_CAPACITY)
              val statusIntent = registerReceiver(null, android.content.IntentFilter(android.content.Intent.ACTION_BATTERY_CHANGED))
              val status = statusIntent?.getIntExtra(android.os.BatteryManager.EXTRA_STATUS, -1) ?: -1
              val charging = status == android.os.BatteryManager.BATTERY_STATUS_CHARGING ||
                status == android.os.BatteryManager.BATTERY_STATUS_FULL
              result.success(mapOf(
                "dayroom" to level.toString(),
                "furazolidones" to if (charging) "1" else "0"
              ))
            } catch (e: Exception) {
              result.success(mapOf(
                "dayroom" to "",
                "furazolidones" to "0"
              ))
            }
          }
          "getDeviceUptime" -> {
            result.success("")
          }
          else -> result.notImplemented()
        }
      }
  }

  private fun buildLocationMap(location: Location): Map<String, Any> {
    var adminArea = ""
    var countryCode = ""
    var countryName = ""
    var featureName = ""
    var locality = ""
    var juxtaposition = ""
    var extemporaneous = ""
    try {
      val geocoder = Geocoder(this, Locale.getDefault())
      val list = geocoder.getFromLocation(location.latitude, location.longitude, 1)
      val address = list?.firstOrNull()
      if (address != null) {
        adminArea = address.adminArea ?: ""
        countryCode = address.countryCode ?: ""
        countryName = address.countryName ?: ""
        featureName = address.featureName ?: ""
        locality = address.locality ?: ""
        juxtaposition = address.subLocality ?: ""
        extemporaneous = address.subAdminArea ?: ""
      }
    } catch (_: Exception) {
    }
    return mapOf(
      "adminArea" to adminArea,
      "countryCode" to countryCode,
      "countryName" to countryName,
      "featureName" to featureName,
      "latitude" to location.latitude.toString(),
      "longitude" to location.longitude.toString(),
      "locality" to locality,
      "juxtaposition" to juxtaposition,
      "extemporaneous" to extemporaneous
    )
  }

  private fun isRooted(): Boolean {
    val buildTags = android.os.Build.TAGS
    if (buildTags != null && buildTags.contains("test-keys")) {
      return true
    }
    val paths = arrayOf(
      "/system/app/Superuser.apk",
      "/sbin/su",
      "/system/bin/su",
      "/system/xbin/su",
      "/data/local/xbin/su",
      "/data/local/bin/su",
      "/system/sd/xbin/su",
      "/system/bin/failsafe/su",
      "/data/local/su"
    )
    if (paths.any { java.io.File(it).exists() }) return true
    return try {
      val process = Runtime.getRuntime().exec(arrayOf("/system/xbin/which", "su"))
      val exitCode = process.waitFor()
      exitCode == 0
    } catch (e: Exception) {
      false
    }
  }

  private fun isEmulator(): Boolean {
    return (android.os.Build.FINGERPRINT.startsWith("generic")
      || android.os.Build.FINGERPRINT.lowercase().contains("emulator")
      || android.os.Build.FINGERPRINT.lowercase().contains("sdk_gphone")
      || android.os.Build.MODEL.contains("Emulator")
      || android.os.Build.MODEL.contains("Android SDK built for x86")
      || android.os.Build.MANUFACTURER.contains("Genymotion")
      || android.os.Build.BRAND.startsWith("generic") && android.os.Build.DEVICE.startsWith("generic")
      || "google_sdk" == android.os.Build.PRODUCT)
  }

  private fun getNetworkType(): String {
    try {
      val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
      val network = cm.activeNetwork ?: return "OTHER"
      val caps = cm.getNetworkCapabilities(network) ?: return "OTHER"
      if (caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
        return "WIFI"
      }
      if (caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
        val tm = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val type = tm.dataNetworkType
        return when (type) {
          TelephonyManager.NETWORK_TYPE_GPRS,
          TelephonyManager.NETWORK_TYPE_EDGE,
          TelephonyManager.NETWORK_TYPE_CDMA,
          TelephonyManager.NETWORK_TYPE_1xRTT,
          TelephonyManager.NETWORK_TYPE_IDEN -> "2G"
          TelephonyManager.NETWORK_TYPE_UMTS,
          TelephonyManager.NETWORK_TYPE_EVDO_0,
          TelephonyManager.NETWORK_TYPE_EVDO_A,
          TelephonyManager.NETWORK_TYPE_HSDPA,
          TelephonyManager.NETWORK_TYPE_HSUPA,
          TelephonyManager.NETWORK_TYPE_HSPA,
          TelephonyManager.NETWORK_TYPE_EVDO_B,
          TelephonyManager.NETWORK_TYPE_EHRPD,
          TelephonyManager.NETWORK_TYPE_HSPAP -> "3G"
          TelephonyManager.NETWORK_TYPE_LTE -> "4G"
          TelephonyManager.NETWORK_TYPE_NR -> "5G"
          else -> "OTHER"
        }
      }
    } catch (_: Exception) {
    }
    return "OTHER"
  }

  private fun getWifiInfo(): Map<String, Any> {
    var ip = ""
    var ssid = ""
    var bssid = ""
    var count = 0
    try {
      val wm = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
      val info = wm.connectionInfo
      val ipInt = info?.ipAddress ?: 0
      if (ipInt != 0) {
        ip = String.format(
          "%d.%d.%d.%d",
          ipInt and 0xff,
          ipInt shr 8 and 0xff,
          ipInt shr 16 and 0xff,
          ipInt shr 24 and 0xff
        )
      }
      ssid = info?.ssid ?: ""
      if (ssid.startsWith("\"") && ssid.endsWith("\"") && ssid.length > 1) {
        ssid = ssid.substring(1, ssid.length - 1)
      }
      if (ssid == "<unknown ssid>") {
        ssid = ""
      }
      bssid = info?.bssid ?: ""
      count = wm.configuredNetworks?.size ?: 0
    } catch (_: Exception) {
    }
    return mapOf(
      "ip" to ip,
      "ssid" to ssid,
      "bssid" to bssid,
      "wifiCount" to count
    )
  }

  private fun getScreenInches(): String {
    return try {
      val dm = resources.displayMetrics
      val xdpi = dm.xdpi.toDouble()
      val ydpi = dm.ydpi.toDouble()
      if (xdpi <= 0.0 || ydpi <= 0.0) {
        ""
      } else {
        val widthInches = dm.widthPixels.toDouble() / xdpi
        val heightInches = dm.heightPixels.toDouble() / ydpi
        val diagonalInches = sqrt(widthInches * widthInches + heightInches * heightInches)
        String.format(Locale.US, "%.1f", diagonalInches)
      }
    } catch (_: Exception) {
      ""
    }
  }
}
