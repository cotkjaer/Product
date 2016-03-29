//
//  PaymentQueueHandler.swift
//  Product
//
//  Created by Christian Otkjær on 18/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation
import StoreKit

internal protocol PaymentQueueHandlerObserver : class
{
}

internal protocol PaymentQueueHandlerTransactionObserver : PaymentQueueHandlerObserver
{
    func handlerWillUpdateTransactions(handler: PaymentQueueHandler)
    
    func handlerDidUpdateTransactions(handler: PaymentQueueHandler)
    
    func handleTransaction(transaction: SKPaymentTransaction) -> Bool
}

internal protocol PaymentQueueHandlerRestoreObserver : PaymentQueueHandlerObserver
{
    func handlerDidRestoreCompletedTransactions(error: NSError?)
}

private var DefaultPaymentQueueHandler : PaymentQueueHandler?

internal class PaymentQueueHandler: NSObject, SKPaymentTransactionObserver
{
    static func defaultHandler() -> PaymentQueueHandler
    {
        if DefaultPaymentQueueHandler == nil
        {
            DefaultPaymentQueueHandler = PaymentQueueHandler()
        }
        
        if let d = DefaultPaymentQueueHandler
        {
            return d
        }
        else
        {
            fatalError("Could not set up default Payment Queue Handler")
        }
    }
    
    var queue: SKPaymentQueue = SKPaymentQueue.defaultQueue()
    
    required init(queue: SKPaymentQueue? = nil)
    {
        super.init()
        
        if let queue = queue
        {
            self.queue = queue
        }
        
        self.queue.addTransactionObserver(self)
    }
    
    deinit
    {
        queue.removeTransactionObserver(self)
    }
    
    // MARK: - observers
    
    var observers = Array<PaymentQueueHandlerObserver>()
    
    func addObserver(observer: PaymentQueueHandlerObserver) -> Bool
    {
        guard !observers.contains({ $0 === observer }) else { return false }
        
        observers.append(observer)
        
        return true
    }
    
    func removeObserver(observer: PaymentQueueHandlerObserver) -> Bool
    {
        guard let index = observers.indexOf({ $0 === observer }) else { return false }
        
        observers.removeAtIndex(index)
        
        return true
    }
    
    //MARK: - SKPaymentTransactionObserver (restore)
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue)
    {
        observers.flatMap{ $0 as? PaymentQueueHandlerRestoreObserver}.forEach{ $0.handlerDidRestoreCompletedTransactions(nil) }
    }
    
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError)
    {
        observers.flatMap{ $0 as?PaymentQueueHandlerRestoreObserver}.forEach{ $0.handlerDidRestoreCompletedTransactions(error) }
    }
    
    func productWithIdentifier(id: String?) -> SKProduct?
    {
        return ProductsCache.defaultCache().productWithIdentifier(id)
    }
    
    //MARK: - SKPaymentTransactionObserver (transactions)
    
    func transactionHandlers() -> [PaymentQueueHandlerTransactionObserver]
    {
        return observers.flatMap({ $0 as? PaymentQueueHandlerTransactionObserver })
    }
    
    internal func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        transactionHandlers().forEach { $0.handlerWillUpdateTransactions(self) }
        
        for transaction in transactions
        {
            let id = transaction.payment.productIdentifier
            
            if let product = productWithIdentifier(id)
            {
                product.updatePurchaseStatus(transaction.transactionState)
            }
            
            let handled = transactionHandlers().map { $0.handleTransaction(transaction) }.contains(true)
            
            if handled && transaction.transactionState != .Purchasing
            {
                queue.finishTransaction(transaction)
            }
            
            debugPrint("Got transaction state \(transaction.transactionState) for product \(transaction.payment.productIdentifier)")
        }
        
        transactionHandlers().forEach { $0.handlerDidUpdateTransactions(self) }
    }
}