//
//  PinoyTools.swift
//  Runner
//
//  Created by xios on 23/03/26.
//

import Foundation
import Security
import UIKit
import AdSupport
import AppTrackingTransparency

final class PinoyTools {
    static let shared = PinoyTools()
    
    private init() {}
    
    private let keychainService = "com.cash_pinoy.device"
    private let idfvAccount = "pinoy.idfv"
    private var trackingActiveObserver: NSObjectProtocol?
    
    func getIdfv() -> String {
        if let stored = keychainRead(account: idfvAccount), !stored.isEmpty {
            return stored
        }
        let idfv = UIDevice.current.identifierForVendor?.uuidString ?? ""
        if !idfv.isEmpty {
            keychainSave(account: idfvAccount, value: idfv)
        }
        return idfv
    }
    
    func getIdfa() -> String {
        #if targetEnvironment(simulator)
        return ""
        #else
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus == .authorized {
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            }
            return ""
        } else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            }
            return ""
        }
        #endif
    }

    func requestIdfa(completion: @escaping (String) -> Void) {
        #if targetEnvironment(simulator)
        DispatchQueue.main.async { completion("") }
        #else
        DispatchQueue.main.async {
            if #available(iOS 14, *) {
                let status = ATTrackingManager.trackingAuthorizationStatus
                if status != .notDetermined {
                    completion(self.getIdfa())
                    return
                }
                self.requestTrackingWhenAppActive {
                    ATTrackingManager.requestTrackingAuthorization { _ in
                        DispatchQueue.main.async { completion(self.getIdfa()) }
                    }
                }
                return
            }
            completion(self.getIdfa())
        }
        #endif
    }

    @available(iOS 14, *)
    private func requestTrackingWhenAppActive(_ action: @escaping () -> Void) {
        if UIApplication.shared.applicationState == .active {
            action()
            return
        }
        if let observer = trackingActiveObserver {
            NotificationCenter.default.removeObserver(observer)
            trackingActiveObserver = nil
        }
        trackingActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            if let observer = self.trackingActiveObserver {
                NotificationCenter.default.removeObserver(observer)
                self.trackingActiveObserver = nil
            }
            action()
        }
    }
    
    private func keychainSave(account: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
        let attributes: [String: Any] = query.merging(
            [kSecValueData as String: data],
            uniquingKeysWith: { $1 }
        )
        SecItemAdd(attributes as CFDictionary, nil)
    }
    
    private func keychainRead(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
