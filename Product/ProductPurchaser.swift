//
//  ProductPurchaser.swift
//  Product
//
//  Created by Christian Otkjær on 29/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import StoreKit

private var purchasersByProductIdentifier = Dictionary<String, ProductPurchaser>()

internal class ProductPurchaser: NSObject, PaymentQueueHandlerObserver
{
    // MARK: - Public
    
    /// returns: `false` if payments are disabled, `true` otherwise
    internal static func purchase(product: SKProduct, completion: (() -> ())?) -> Bool
    {
        guard SKPaymentQueue.canMakePayments() else { product.updatePurchaseStatus(SKPaymentTransactionState.Failed); completion?(); return false }
        
        if product.purchaseStatus == .Purchased
        {
            completion?()
        }
        else if
            let completion = completion,
            let purchaser = purchasersByProductIdentifier[product.productIdentifier]
        {
            purchaser.completions.append(completion)
        }
        else
        {
            let purchaser = ProductPurchaser(product: product)
                {
                    purchasersByProductIdentifier[product.productIdentifier] = nil
                    completion?()
            }
            
            purchasersByProductIdentifier[product.productIdentifier] = purchaser
            purchaser.start()
        }
        
        return true
    }
    
    internal func start()
    {
        if SKPaymentQueue.canMakePayments()
        {
            queueHandler.addObserver(self)
            queueHandler.queue.addPayment(SKPayment(product: product))
        }
        else
        {
            product.updatePurchaseStatus(SKPaymentTransactionState.Failed)
            
            completions.forEach { $0() }
        }
    }
    
    // MARK: - Private
    
    private let product : SKProduct
    
    private var completions = Array<()->()>()
    private let queueHandler = PaymentQueueHandler.defaultHandler()
    
    private var didUpdateTransaction = false
    
    private init(product: SKProduct, completion: () -> ())
    {
        self.product = product
        self.completions = [completion]
    }
    
    //MARK: - Transaction handling
    
    func handlerWillUpdateTransactions(handler: PaymentQueueHandler)
    {
        // NOOP
    }
    
    func handleTransaction(transaction: SKPaymentTransaction) -> Bool
    {
        guard transaction.payment.productIdentifier == product.productIdentifier else { return false }
        
        didUpdateTransaction = true
        
        return true
    }
    
    func handlerDidUpdateTransactions(handler: PaymentQueueHandler)
    {
        if didUpdateTransaction
        {
            completions.forEach { $0() }
        }
        else
        {
            debugPrint("transactions did not update \(product)!")
        }
    }
}
