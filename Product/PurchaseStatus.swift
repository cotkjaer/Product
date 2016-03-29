//
//  PurchaseStatus.swift
//  Product
//
//  Created by Christian Otkjær on 29/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation
import StoreKit

// MARK: - Purchase status

extension SKProduct
{
    public enum PurchaseStatus : Int, Comparable
    {
        // NO 1 for backwards compatability
        case None = 0, Purchasing = 2, Deferred = 3, Failed = 4, Purchased = 5
        
        init(transactionState: SKPaymentTransactionState?)
        {
            switch transactionState
            {
            case .Deferred? :
                self = .Deferred
                
            case .Failed? :
                self = .Failed
                
            case .Purchased?, .Restored? :
                self = .Purchased
                
            case .Purchasing? :
                self = .Purchasing
                
            default:
                self = .None
            }
        }
    }
    
    public var purchaseStatus : PurchaseStatus
        {
        get
        {
            return SKProduct.purchaseStatusForProductWithIdentifier(productIdentifier)
        }
        set
        {
            SKProduct.setPurchaseStatus(newValue, forProductWithIdentifier: productIdentifier)
        }
    }
    
    public func updatePurchaseStatus(status: PurchaseStatus)
    {
        if purchaseStatus < status
        {
            purchaseStatus = status
        }
    }
    
    public func updatePurchaseStatus(transactionState: SKPaymentTransactionState)
    {
        updatePurchaseStatus(PurchaseStatus(transactionState: transactionState))
    }
    
    // MARK: - Static
    
    public static func purchaseStatusForProductWithIdentifier(productIdentifier: String?) -> PurchaseStatus
    {
        if let productIdentifier = productIdentifier
        {
            return PurchaseStatus(rawValue: defaults.integerForKey(productIdentifier)) ?? .None
        }
        
        return .None
    }
    
    public static func setPurchaseStatus(status: PurchaseStatus, forProductWithIdentifier productIdentifier: String?)
    {
        if let productIdentifier = productIdentifier
        {
            defaults.setInteger(status.rawValue, forKey: productIdentifier)
            defaults.synchronize()
        }
    }
}


// MARK: - Comparable

public func < (lhs: SKProduct.PurchaseStatus, rhs: SKProduct.PurchaseStatus) -> Bool
{
    return lhs.rawValue < rhs.rawValue
}
