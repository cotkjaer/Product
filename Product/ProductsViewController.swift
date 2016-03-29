//
//  ProductsViewController.swift
//  Product
//
//  Created by Christian Otkjær on 29/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation
import StoreKit

// MARK: - Products View Controller

public protocol ProductsViewControllerDelegate
{
    func productsControllerCancelled(controller: ProductsViewController)
    
    func productsController(controller: ProductsViewController, didPurchase product: SKProduct)
    
    func productsController(controller: ProductsViewController, didEncounterError: ErrorType)
}

public protocol ProductsViewController : class
{
    var productsDelegate : ProductsViewControllerDelegate? { get set }
    
    func purchaseProduct(product: SKProduct)
    
    func refreshProducts(animated animated: Bool)
}

// MARK: - Defaults

public extension ProductsViewController where Self : UIViewController
{
    internal func tellDelegateAboutProduct(product: SKProduct)
    {
        switch product.purchaseStatus
        {
        case .Purchased:
            productsDelegate?.productsController(self, didPurchase: product)
        default:
            debugPrint("won't tell on \(product)")
        }
    }
    
    func purchaseProduct(product: SKProduct)
    {
        if !product.purchase({ self.refreshProducts(animated: true); self.tellDelegateAboutProduct(product) })
        {
            let alert = UIAlertController(title: "Payments Disabled", message: "Please enable payments in Settings", preferredStyle: .Alert)
            
            let action = UIAlertAction(title: "Done", style: .Default, handler: nil)
            
            alert.addAction(action)
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func purchaseProductWithIdentifier(productIdentifier: String)
    {
        if let product =  SKProduct.productWithIdentifier(productIdentifier)
        {
            purchaseProduct(product)
        }
        else
        {
            SKProduct.fetch([productIdentifier]) { (products, error) -> () in
                
                if let error = error
                {
                    self.productsDelegate?.productsController(self, didEncounterError: error)
                }
                
                if let product = products.first
                {
                    self.purchaseProduct(product)
                }
            }
        }
        
    }
}
