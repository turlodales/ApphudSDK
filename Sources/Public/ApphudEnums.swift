//
//  ApphudEnums.swift
//  ApphudSDK
//
//  Created by Renat Kurbanov on 28.09.2023.
//

import Foundation

/**
 Public Callback object provide -> [String: Bool]
 */
public typealias ApphudEligibilityCallback = (([String: Bool]) -> Void)

/**
 Public Callback object provide -> Bool
 */
public typealias ApphudBoolCallback = ((Bool) -> Void)

/// List of available attribution providers
/// has to make Int in order to support Objective-C
@objc public enum ApphudAttributionProvider: Int {

    // supported values
    case appsFlyer
    case adjust
    case appleAdsAttribution
    case branch
    case firebase
    case facebook
    case singular
    case tenjin
    case tiktok
    case voluum
    /**
    Pass custom attribution data to Apphud. Contact your support manager for details.
     */
    case custom

    public func toString() -> String {
        switch self {
        case .appsFlyer:
            return "appsflyer"
        case .adjust:
            return "adjust"
        case .branch:
            return "branch"
        case .facebook:
            return "facebook"
        case .appleAdsAttribution:
            return "search_ads"
        case .firebase:
            return "firebase"
        case .custom:
            return "custom"
        case .singular:
            return "singular"
        case .tenjin:
            return "tenjin"
        case .tiktok:
            return "tiktok"
        case .voluum:
            return "voluum"
        default:
            return "Unavailable"
        }
    }
}

internal enum ApphudIAPCodingKeys: String, CodingKey {
    case id, expiresAt, productId, cancelledAt, startedAt, inRetryBilling, autorenewEnabled, introductoryActivated, environment, local, groupId, status, kind, originalTransactionId, transactionId, isConsumable
}

internal enum ApphudIAPKind: String {
    case autorenewable
    case nonrenewable
}

internal enum ApphudEnvironment: String {
    case sandbox
    case production
}
