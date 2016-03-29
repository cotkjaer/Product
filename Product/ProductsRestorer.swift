//
//  ProductsRestorer.swift
//  Product
//
//  Created by Christian Otkjær on 18/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import Foundation
import StoreKit

internal class ProductsRestorer: NSObject, PaymentQueueHandlerRestoreObserver
{
    // MARK: - Internal

    internal init(completion: (NSError? -> ())?)
    {
        completionHandler = { if let e = $0 { debugPrint(e) }; completion?($0) }
        super.init()
    }

    internal func start()
    {
        ProductsRestorer.restorers.insert(self)
        
        queueHandler.addObserver(self)
        
        queueHandler.queue.restoreCompletedTransactions()
    }

    // MARK: - Private
    
    private static var restorers = Set<ProductsRestorer>()
    
    private var completionHandler : (NSError? -> ())
    
    private var queueHandler = PaymentQueueHandler.defaultHandler()
    
    private func stop(error: NSError? = nil)
    {
        ProductsRestorer.restorers.remove(self)

        queueHandler.removeObserver(self)
        
        completionHandler(error)
    }
    
    //MARK: - Observer
    
    func handlerDidRestoreCompletedTransactions(error: NSError?)
    {
        stop(error)
    }
}
