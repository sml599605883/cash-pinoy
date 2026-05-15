import AdSupport
import AppTrackingTransparency
import CFNetwork
import CoreLocation
import CoreTelephony
import Flutter
import MachO
import NetworkExtension
import StoreKit
import SystemConfiguration.CaptiveNetwork
import UIKit
import UserNotifications
import Foundation

@main
@objc
class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, CLLocationManagerDelegate {
    private let channelName = "cash_pinoy/proxy"
    private var flutterChannel: FlutterMethodChannel?
    private var pendingPushRoutes: [String] = []
    private var locationManager: CLLocationManager?
    private var locationResults: [FlutterResult] = []
    private var requestingLocation = false
    private let geocoder = CLGeocoder()
    private var pushTokenResult: FlutterResult?
    private let pushTokenKey = "apns_token"
//    private var pushActiveObserver: NSObjectProtocol?
    private var requestingPushAuth = false
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
        self.requestPushTokenWhenActive()
        let channel = FlutterMethodChannel(
            name: channelName, binaryMessenger: engineBridge.applicationRegistrar.messenger())
        self.flutterChannel = channel
        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "getSystemProxy":
                let settings =
                CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any]
                let enabled = settings?[kCFNetworkProxiesHTTPEnable as String] as? Int ?? 0
                if enabled == 1 {
                    let host = settings?[kCFNetworkProxiesHTTPProxy as String] as? String ?? ""
                    let port = settings?[kCFNetworkProxiesHTTPPort as String] as? Int ?? 0
                    if !host.isEmpty && port > 0 {
                        result(["host": host, "port": port])
                        return
                    }
                }
                result(nil)
            case "getProxyEnabled":
                guard let proxySettingsUnmanaged = CFNetworkCopySystemProxySettings(),
                      let myUrl = URL(string: "http://www.google.com")
                else {
                    result(0)
                    return
                }
                let proxySettings = proxySettingsUnmanaged.takeRetainedValue()
                let proxiesUnmanaged = CFNetworkCopyProxiesForURL(myUrl as CFURL, proxySettings)
                guard
                    let proxies = proxiesUnmanaged.takeRetainedValue() as? [Any],
                    let settings = proxies.first as? [String: Any],
                    let proxyType = settings[kCFProxyTypeKey as String] as? String
                else {
                    result(0)
                    return
                }
                if proxyType == (kCFProxyTypeNone as String) {
                    result(0)
                    return
                } else {
                    result(1)
                    return
                }
            case "getVpnEnabled":
                guard let proxySettingsUnmanaged = CFNetworkCopySystemProxySettings() else {
                    result(0)
                    return
                }
                let proxySettings = proxySettingsUnmanaged.takeRetainedValue() as NSDictionary
                guard
                    let dict = proxySettings["__SCOPED__"] as? NSDictionary,
                    let keys = dict.allKeys as? [String]
                else {
                    result(0)
                    return
                }
                for key in keys {
                    if ["tap", "tun", "ipsec", "ppp"].contains(where: { key.contains($0) }) {
                        result(1)
                        return
                    }
                }
                result(0)
                return
            case "getRooted":
                result(self.isJailbroken() ? 1 : 0)
            case "getIsEmulator":
#if targetEnvironment(simulator)
                result(1)
#else
                result(0)
#endif
            case "getDeviceLanguage":
                let langCode = Locale.preferredLanguages.first ?? ""
                let lang = langCode.components(separatedBy: "-").first ?? ""
                result(lang)
            case "getCarrierName":
                let networkInfo = CTTelephonyNetworkInfo()
                var carrierName = ""
                if #available(iOS 12.0, *) {
                    if let carriers = networkInfo.serviceSubscriberCellularProviders {
                        if carriers.values.first?.isoCountryCode == nil {
                            carrierName = ""
                        } else {
                            carrierName = carriers.values.first?.carrierName ?? ""
                        }
                    }
                } else {
                    if networkInfo.subscriberCellularProvider?.isoCountryCode == nil {
                        carrierName = ""
                    } else {
                        carrierName = networkInfo.subscriberCellularProvider?.carrierName ?? ""
                    }
                }
                result(carrierName)
            case "getNetworkType":
                let type = self.currentNetworkType()
                result(type)
            case "getTimeZoneId":
                result(TimeZone.current.abbreviation() ?? "")
            case "getCpuCores":
                result(ProcessInfo.processInfo.processorCount)
            case "getDeviceName":
                result(UIDevice.current.name)
            case "getScreenInches":
                result(self.currentScreenInches())
            case "getWifiInfo":
                let ip = self.wifiIPv4Address()
                var count = self.wifiCount()
                self.fetchCurrentSSIDBSSID { ssid, bssid in
                    result([
                        "ip": ip,
                        "ssid": ssid,
                        "bssid": bssid,
                        "wifiCount": count != 0 ? count: ssid.isEmpty ? 0 : 1,
                    ])
                }
            case "getDeviceStorageInfo":
                result(self.getStorageInfo())
            case "requestAppReview":
                if #available(iOS 14.0, *) {
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    {
                        SKStoreReviewController.requestReview(in: scene)
                        result(true)
                    } else {
                        SKStoreReviewController.requestReview()
                        result(true)
                    }
                } else {
                    SKStoreReviewController.requestReview()
                    result(true)
                }
                case "getIosIdentifiers":
                    let idfv = PinoyTools.shared.getIdfv()
                    let idfa = PinoyTools.shared.getIdfa()
                    result(["idfv": idfv, "idfa": idfa])
                case "requestTrackingPermission":
                    PinoyTools.shared.requestIdfa { idfa in
                        result(idfa)
                    }
            case "openLocationSettings":
                let urls = [
                    URL(string: "App-Prefs:root=Privacy&path=LOCATION")
                ].compactMap { $0 }
                var opened = false
                for url in urls {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        opened = true
                        break
                    }
                }
                result(opened)
            case "isLocationPermissionNotDetermined":
                result(self.locationStatusString() == "notDetermined")
            case "getPushToken":
                if let token = self.getStoredPushToken(), !token.isEmpty {
                    result(token)
                    return
                }
                self.pushTokenResult = result
            case "getCurrentLocation":
                if !CLLocationManager.locationServicesEnabled() {
                    result(nil)
                    return
                }
                if self.locationStatusString() != "granted" {
                    result(nil)
                    return
                }
                self.locationResults.append(result)
                if self.locationManager == nil {
                    let manager = CLLocationManager()
                    manager.delegate = self
                    manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                    self.locationManager = manager
                }
                if self.requestingLocation { return }
                self.requestingLocation = true
                self.locationManager?.requestLocation()
            case "getBatteryInfo":
                UIDevice.current.isBatteryMonitoringEnabled = true
                let level = UIDevice.current.batteryLevel
                let percent = level < 0 ? 0 : Int(level * 100)
                let state = UIDevice.current.batteryState
                let charging = (state == .charging || state == .full) ? 1 : 0
                result([
                    "dayroom": percent,
                    "furazolidones": charging,
                ])
            case "getDeviceUptime":
                let uptime = ProcessInfo.processInfo.systemUptime
                let ms = Int64(uptime * 1000)
                result(ms)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        flushPendingPushRoutes()
    }
    
//    override func applicationDidBecomeActive(_ application: UIApplication) {
//        switch ATTrackingManager.trackingAuthorizationStatus {
//        case .notDetermined:
//            ATTrackingManager.requestTrackingAuthorization { _ in
//            }
//        default:
//            break
//        }
//        UIApplication.shared.applicationIconBadgeNumber = 0
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            completeLocationResults(nil)
            return
        }
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self else { return }
            if error != nil {
                self.completeLocationResults([
                    "latitude": "\(location.coordinate.latitude)",
                    "longitude": "\(location.coordinate.longitude)",
                ])
                return
            }
            let place = placemarks?.first
            let payload: [String: Any] = [
                "adminArea": place?.administrativeArea ?? "",
                "countryCode": place?.isoCountryCode ?? "",
                "countryName": place?.country ?? "",
                "featureName": place?.name ?? "",
                "latitude": "\(location.coordinate.latitude)",
                "longitude": "\(location.coordinate.longitude)",
                "locality": place?.locality ?? "",
                "juxtaposition": place?.subLocality ?? "",
                "extemporaneous": place?.subAdministrativeArea ?? "",
            ]
            self.completeLocationResults(payload)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completeLocationResults(nil)
    }

    private func completeLocationResults(_ payload: Any?) {
        requestingLocation = false
        guard !locationResults.isEmpty else { return }
        let pending = locationResults
        locationResults.removeAll()
        for callback in pending {
            callback(payload)
        }
    }
    
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        UserDefaults.standard.set(token, forKey: pushTokenKey)
        if let pending = pushTokenResult {
            pushTokenResult = nil
            pending(token)
        }
    }
    
    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        if let pending = pushTokenResult {
            pushTokenResult = nil
            pending("")
        }
    }
    
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        
        let content = response.notification.request.content
        let userInfo = content.userInfo
        if let url = extractPushUrl(userInfo) {
            pushToViewControllerByNotification(url)
        }
        completionHandler()
    }
    
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        
        if UIApplication.shared.applicationState == .active {
            let userInfo = notification.request.content.userInfo
            if let url = extractPushUrl(userInfo) {
                pushToViewControllerByNotification(url)
            }
        }
        completionHandler([.badge, .sound, .banner, .list])
    }
    
    func pushToViewControllerByNotification(_ message: String) {
        guard !message.isEmpty else { return }
        sendPushRouteToFlutter(message)
    }

    private func sendPushRouteToFlutter(_ route: String) {
        guard let channel = flutterChannel else {
            pendingPushRoutes.append(route)
            return
        }
        DispatchQueue.main.async {
            channel.invokeMethod("onPushRoute", arguments: ["url": route])
        }
    }

    private func flushPendingPushRoutes() {
        guard !pendingPushRoutes.isEmpty else { return }
        let routes = pendingPushRoutes
        pendingPushRoutes.removeAll()
        for route in routes {
            sendPushRouteToFlutter(route)
        }
    }

    private func extractPushUrl(_ userInfo: [AnyHashable: Any]) -> String? {
        if let directUrl = userInfo["url"] as? String, !directUrl.isEmpty {
            return directUrl
        }

        if let params = userInfo["params"] as? [String: Any],
           let url = params["url"] as? String,
           !url.isEmpty {
            return url
        }

        if let paramsString = userInfo["params"] as? String,
           let data = paramsString.data(using: .utf8),
           let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let url = object["url"] as? String,
           !url.isEmpty {
            return url
        }

        return nil
    }
    
    private func getStoredPushToken() -> String? {
        return UserDefaults.standard.string(forKey: pushTokenKey)
    }
    
    private func requestPushTokenWhenActive() {
//        if requestingPushAuth { return }
//        requestingPushAuth = true
        let notification = UNUserNotificationCenter.current()
        notification.delegate = self
        notification.requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
//            self.requestingPushAuth = false
            if success {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let pending = self.pushTokenResult {
                self.pushTokenResult = nil
                pending("")
            }
        }
//        let requestAction = { [weak self] in
//            guard let self else { return }
//        }
//        
//        if UIApplication.shared.applicationState == .active {
//            requestAction()
//            return
//        }
//        
//        if let observer = pushActiveObserver {
//            NotificationCenter.default.removeObserver(observer)
//            pushActiveObserver = nil
//        }
//        pushActiveObserver = NotificationCenter.default.addObserver(
//            forName: UIApplication.didBecomeActiveNotification,
//            object: nil,
//            queue: .main
//        ) { [weak self] _ in
//            guard let self else { return }
//            if let observer = self.pushActiveObserver {
//                NotificationCenter.default.removeObserver(observer)
//                self.pushActiveObserver = nil
//            }
//            requestAction()
//        }
    }
    
    private func isJailbroken() -> Bool {
#if targetEnvironment(simulator)
        return false
#else
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
        ]
        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        if let url = URL(string: "cydia://package/com.example.package") {
            if UIApplication.shared.canOpenURL(url) {
                return true
            }
        }
        let testPath = "/private/jb_test.txt"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
        }
        return false
#endif
    }
    
    private func currentNetworkType() -> String {
        if #available(iOS 12.0, *) {
            let info = CTTelephonyNetworkInfo()
            if let radioTech = info.serviceCurrentRadioAccessTechnology?.values.first {
                return mapRadioTech(radioTech)
            }
        } else {
            let info = CTTelephonyNetworkInfo()
            if let radioTech = info.currentRadioAccessTechnology {
                return mapRadioTech(radioTech)
            }
        }
        // Fallback: treat as WIFI if no radio tech detected and Wi-Fi reachable
        if isOnWiFi() {
            return "WIFI"
        }
        return "OTHER"
    }
    
    private func fetchCurrentSSIDBSSID(completion: @escaping (String, String) -> Void) {
        if #available(iOS 26.0, *) {
            NEHotspotNetwork.fetchCurrent { [weak self] network in
                let ssid = network?.ssid ?? ""
                let bssid = network?.bssid ?? ""
                if !ssid.isEmpty || !bssid.isEmpty {
                    completion(ssid, bssid)
                    return
                }
                let fallback = self?.legacySSIDBSSID() ?? ("", "")
                completion(fallback.0, fallback.1)
            }
            return
        }
        let fallback = legacySSIDBSSID()
        completion(fallback.0, fallback.1)
    }
    
    private func legacySSIDBSSID() -> (String, String) {
        var ssid = ""
        var bssid = ""
        if let interfaces = CNCopySupportedInterfaces() as? [String] {
            for interface in interfaces {
                if let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any] {
                    ssid = info[kCNNetworkInfoKeySSID as String] as? String ?? ""
                    bssid = info[kCNNetworkInfoKeyBSSID as String] as? String ?? ""
                    if !ssid.isEmpty || !bssid.isEmpty {
                        break
                    }
                }
            }
        }
        return (ssid, bssid)
    }
    
    private func wifiIPv4Address() -> String {
        var address = ""
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr {
            var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
            while ptr != nil {
                let interface = ptr!.pointee
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) {
                    let name = String(cString: interface.ifa_name)
                    if name == "en0" {
                        var addr = interface.ifa_addr.pointee
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if getnameinfo(
                            &addr,
                            socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname,
                            socklen_t(hostname.count),
                            nil,
                            0,
                            NI_NUMERICHOST
                        ) == 0 {
                            address = String(cString: hostname)
                            break
                        }
                    }
                }
                ptr = interface.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
    
    private func getStorageInfo() -> [String: String] {
        func chondriosome() -> UInt64 {
            var totalSize: UInt64 = 0
            guard
                let path = NSSearchPathForDirectoriesInDomains(
                    .documentDirectory, .userDomainMask, true
                ).first
            else {
                return totalSize
            }
            do {
                let dict = try FileManager.default.attributesOfFileSystem(forPath: path)
                totalSize = dict[.systemFreeSize] as? UInt64 ?? 0
            } catch {
            }
            return totalSize
        }
        
        func blatted() -> UInt64 {
            var totalSize: UInt64 = 0
            guard
                let path = NSSearchPathForDirectoriesInDomains(
                    .documentDirectory, .userDomainMask, true
                ).first
            else {
                return totalSize
            }
            do {
                let dict = try FileManager.default.attributesOfFileSystem(forPath: path)
                totalSize = dict[.systemSize] as? UInt64 ?? 0
            } catch {
            }
            return totalSize
        }
        
        func bouncers() -> UInt64 {
            ProcessInfo.processInfo.physicalMemory
        }
        
        func towrope() -> UInt64 {
            var vmStats = vm_statistics_data_t()
            var infoCount = mach_msg_type_number_t(
                MemoryLayout<vm_statistics>.size / MemoryLayout<integer_t>.size)
            let err: kern_return_t = withUnsafeMutableBytes(of: &vmStats) {
                let boundBuffer = $0.bindMemory(to: Int32.self)
                return host_statistics(
                    mach_host_self(), HOST_VM_INFO, boundBuffer.baseAddress, &infoCount)
            }
            if err != KERN_SUCCESS {
                return 0
            }
            return UInt64(vm_page_size) * UInt64(vmStats.free_count) + UInt64(vm_page_size)
            * UInt64(vmStats.inactive_count)
        }
        
        return [
            "chondriosome": "\(chondriosome())",
            "blatted": "\(blatted())",
            "bouncers": "\(bouncers())",
            "towrope": "\(towrope())",
        ]
    }
    
    private func diskSpaceInfo() -> (totalKB: String, freeKB: String) {
        do {
            let attrs = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            let total = (attrs[.systemSize] as? NSNumber)?.int64Value ?? 0
            let free = (attrs[.systemFreeSize] as? NSNumber)?.int64Value ?? 0
            return (String(total / 1024), String(free / 1024))
        } catch {
            return ("", "")
        }
    }
    
    private func memoryInfo() -> (totalKB: String, freeKB: String) {
        let total = Int64(ProcessInfo.processInfo.physicalMemory / 1024)
        var free: Int64 = 0
        var size = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        var vmStat = vm_statistics64()
        let result = withUnsafeMutablePointer(to: &vmStat) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &size)
            }
        }
        if result == KERN_SUCCESS {
            let pageSize = vm_kernel_page_size
            free = Int64(vmStat.free_count) * Int64(pageSize) / 1024
        }
        return (String(total), free > 0 ? String(free) : "")
    }
    
    private func mapRadioTech(_ tech: String) -> String {
        switch tech {
        case CTRadioAccessTechnologyGPRS,
            CTRadioAccessTechnologyEdge,
        CTRadioAccessTechnologyCDMA1x:
            return "2G"
        case CTRadioAccessTechnologyWCDMA,
            CTRadioAccessTechnologyHSDPA,
            CTRadioAccessTechnologyHSUPA,
            CTRadioAccessTechnologyCDMAEVDORev0,
            CTRadioAccessTechnologyCDMAEVDORevA,
            CTRadioAccessTechnologyCDMAEVDORevB,
        CTRadioAccessTechnologyeHRPD:
            return "3G"
        case CTRadioAccessTechnologyLTE:
            return "4G"
        default:
            break
        }
        if #available(iOS 14.1, *) {
            if tech == CTRadioAccessTechnologyNR || tech == CTRadioAccessTechnologyNRNSA {
                return "5G"
            }
        }
        return "OTHER"
    }
    
    private func isOnWiFi() -> Bool {
        // Simple Wi-Fi detection: if radio is nil, assume WIFI is possible.
        // More accurate detection requires Reachability; keep lightweight.
        return true
    }
    
    private func locationStatusString() -> String {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = locationManager?.authorizationStatus ?? CLLocationManager.authorizationStatus()
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return "granted"
        case .denied:
            return "denied"
        case .restricted:
            return "restricted"
        case .notDetermined:
            return "notDetermined"
        @unknown default:
            return "denied"
        }
    }
    
    private func wifiCount() -> Int {
        if let wifis = CNCopySupportedInterfaces() as NSArray? {
            var count = 0
            for wifi in wifis {
                if let wifiName = wifi as? String,
                   let info = CNCopyCurrentNetworkInfo(wifiName as CFString) as NSDictionary?,
                   let ssid = info[kCNNetworkInfoKeySSID as String] as? String
                {
                    count += 1
                }
            }
            return count
        }
        return 0
    }
    
    private func currentScreenInches() -> String {
        let nativeBounds = UIScreen.main.nativeBounds
        let width = min(nativeBounds.width, nativeBounds.height)
        let height = max(nativeBounds.width, nativeBounds.height)
        let ppi = screenPPI(width: width, height: height)
        if ppi <= 0 { return "" }
        let diagonal = sqrt(width * width + height * height)
        let inches = diagonal / ppi
        return String(format: "%.1f", inches)
    }
    
    private func screenPPI(width: CGFloat, height: CGFloat) -> CGFloat {
        let w = Int(width.rounded())
        let h = Int(height.rounded())
        switch (w, h) {
        case (640, 960), (640, 1136), (750, 1334), (828, 1792):
            return 326
        case (1080, 1920):
            return 401
        case (1125, 2436), (1242, 2688), (1284, 2778):
            return 458
        case (1170, 2532), (1179, 2556), (1290, 2796), (1320, 2868):
            return 460
        case (1488, 2266):
            return 326
        case (1536, 2048), (1620, 2160), (1668, 2224), (1668, 2388), (2048, 2732):
            return 264
        default:
            if UIDevice.current.userInterfaceIdiom == .pad {
                return UIScreen.main.nativeScale >= 2.0 ? 264 : 132
            }
            let scale = UIScreen.main.nativeScale
            if scale >= 3.0 {
                if w <= 1080 { return 401 }
                if w >= 1179 { return 460 }
                return 458
            }
            return scale >= 2.0 ? 326 : 163
        }
    }
    
}
