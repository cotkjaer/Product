//
//  ProductsCache.swift
//  Product
//
//  Created by Christian Otkjær on 18/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation
import StoreKit

public class ProductsCache
{
    private static var DefaultProductsCache = ProductsCache()
    
    public static func defaultCache() -> ProductsCache
    {
        return DefaultProductsCache
    }
    
    private init() { }
    
    private var products = Dictionary<String, SKProduct>()
    
    public func addProduct(product: SKProduct) -> Bool
    {
        guard products[product.productIdentifier] == nil else { return false }
        
        products[product.productIdentifier] = product
        
        return true
    }
    
    public func productWithIdentifier(identifier: String?) -> SKProduct?
    {
        if let i = identifier
        {
            return products[i]
        }
        
        return nil
    }
    
    public func hasProductWithIdentifier(identifier: String?) -> Bool
    {
        return productWithIdentifier(identifier) != nil
    }
}

// MARK: - SKProduct

extension SKProduct
{
    public static func productWithIdentifier(identifier: String?) -> SKProduct?
    {
        return ProductsCache.DefaultProductsCache.productWithIdentifier(identifier)
    }
}
