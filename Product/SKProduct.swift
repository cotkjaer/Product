//
//  SKProduct.swift
//  Product
//
//  Created by Christian Otkjær on 18/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation
import StoreKit

// MARK: - Defaults

internal let defaults = NSUserDefaults.standardUserDefaults()

// MARK: - Price

extension SKProduct
{
    public var localizedPrice : String?
        {
            let numberFormatter = NSNumberFormatter()
            
            numberFormatter.formatterBehavior = .Behavior10_4
            numberFormatter.numberStyle = .CurrencyStyle
            numberFormatter.locale = priceLocale
            
            return numberFormatter.stringFromNumber(price)
    }
}

// MARK: - Fetch

extension SKProduct
{
    public static func fetch<S: SequenceType where S.Generator.Element == String>(productIdentifiers: S, completion: ((Set<SKProduct>, NSError?) -> ())? = nil)
    {
        ProductsFetcher(productIdentifiers: productIdentifiers, completion: completion).start()
    }
}

// MARK: - Restore

extension SKProduct
{
    public static func restoreProducts(completion: (NSError?->())? = nil)
    {
        ProductsRestorer(completion: completion).start()
    }
}

// MARK: - Purchase

extension SKProduct
{
    public func purchase(completion: (()->())? = nil) -> Bool
    {
        return ProductPurchaser.purchase(self, completion: completion)
    }
}
