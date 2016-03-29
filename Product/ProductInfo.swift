//
//  ProductInfo.swift
//  Product
//
//  Created by Christian Otkjær on 29/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation
import StoreKit

public typealias ProductInfo = (identifier: String, title: String?, description: String?, price: String?, status: SKProduct.PurchaseStatus)

// MARK: - Localization

extension SKProduct
{
    public static func localizedTitleForProductWithIdentifier(identifier: String?) -> String?
    {
        guard let identifier = identifier else { return nil }
        
        if let product = productWithIdentifier(identifier)
        {
            return product.localizedTitle
        }
        
        return NSLocalizedString("\(identifier)-title", comment: "\(identifier)-title")
    }
    
    public static func localizedDescriptionForProductWithIdentifier(identifier: String?) -> String?
    {
        guard let identifier = identifier else { return nil }
        
        if let product = productWithIdentifier(identifier)
        {
            return product.localizedDescription
        }
        
        return NSLocalizedString("\(identifier)-description", comment: "\(identifier)-description")
    }
    
    public static func localizedPriceForProductWithIdentifier(identifier: String?) -> String?
    {
        guard let identifier = identifier else { return nil }
        
        if let product = productWithIdentifier(identifier)
        {
            return product.localizedPrice
        }
        
        return NSLocalizedString("\(identifier)-price", comment: "\(identifier)-price")
    }
    
    public func localizedInfo() -> ProductInfo
    {
        return (productIdentifier, localizedTitle, localizedDescription, localizedPrice, purchaseStatus)
    }
    
    public static func localizedInfoForProdutWithIdentifier(identifier: String?) -> ProductInfo
    {
        if let identifier = identifier
        {
            return (
                identifier,
                localizedTitleForProductWithIdentifier(identifier),
                localizedDescriptionForProductWithIdentifier(identifier),
                localizedPriceForProductWithIdentifier(identifier),
                purchaseStatusForProductWithIdentifier(identifier)
            )
        }
        
        return ("",nil,nil,nil,.None)
    }
}
