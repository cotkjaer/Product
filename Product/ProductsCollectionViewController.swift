//
//  ProductsCollectionViewController.swift
//  Product
//
//  Created by Christian Otkjær on 29/03/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

import UIKit
import StoreKit

// MARK: - Products Collection View

// MARK: Cell

public class ProductsCollectionViewCell : UICollectionViewCell
{
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var detailLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView?
}

public class ProductsCollectionViewController: UICollectionViewController, ProductsViewController
{
    public var productIdentifiers = Set<String>() { didSet { updateData() } }
    
    public override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        refreshUI()
    }
    
    // MARK: - data
    
    var data = Array<Array<ProductInfo>>()
    
    func updateData()
    {
        data = [productIdentifiers.sort().flatMap{ SKProduct.localizedInfoForProdutWithIdentifier($0) }]
        collectionView?.reloadData()
    }
    
    func sectionForIndexPath(indexPath: NSIndexPath) -> [ProductInfo]?
    {
        return sectionForSection(indexPath.section)
    }
    
    func sectionForSection(section: Int) -> [ProductInfo]?
    {
        guard section < data.endIndex && section >= 0 else { return nil }
        
        let section = data[section]

        return section
    }
    
    func infoForIndexPath(indexPath: NSIndexPath) -> ProductInfo?
    {
        guard let section = sectionForIndexPath(indexPath) else { return nil }

        guard indexPath.item < section.endIndex && indexPath.item >= 0 else { return nil }

        return section[indexPath.item]
    }
    
    // MARK: UICollectionViewDataSource
    
    override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return data.count
    }
    
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return sectionForSection(section)?.count ?? 0
    }
    
    private let CellReuseIdentifier = "ProductCell"
    
    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        guard
            let info = infoForIndexPath(indexPath)
            
            else
        {
            fatalError("could not get product for indexPath \(indexPath)")
        }
        
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellReuseIdentifier, forIndexPath: indexPath) as? ProductsCollectionViewCell
            else
        {
            fatalError("could not get cell with identifier \(CellReuseIdentifier)")
        }
        
        cell.titleLabel?.text = info.title
        cell.detailLabel?.text = info.description
        
        var color = UIColor.darkTextColor()
        
        switch info.status
        {
        case .Deferred:
            cell.statusLabel?.text = nil//NSLocalizedString("Deferred", comment:"Purchase deferred")
            cell.activityIndicatorView?.startAnimating()
            
        case .Failed:
            cell.statusLabel?.text = NSLocalizedString("!", comment: "Purchase failed")
            color = UIColor(red: 0.7, green: 0, blue: 0, alpha: 1)
            cell.activityIndicatorView?.stopAnimating()
            
        case .Purchased:
            cell.statusLabel?.text = NSLocalizedString("✓", comment: "Purchased")
            color = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
            cell.activityIndicatorView?.stopAnimating()
            
            
        case .Purchasing:
            cell.statusLabel?.text = nil//NSLocalizedString("Purchasing", comment: "")
            cell.activityIndicatorView?.startAnimating()
            
            /*
            case .PendingFetch:
            cell.titleLabel?.text = nil
            cell.detailLabel?.text = nil
            cell.statusLabel?.text = nil //NSLocalizedString("Fetching", comment: "")
            cell.activityIndicatorView?.startAnimating()
            */
            
        case .None:
            cell.statusLabel?.text = info.price
            cell.activityIndicatorView?.stopAnimating()
            
            color = view.tintColor
        }
        
        cell.layer.borderColor = color.CGColor
        cell.titleLabel?.backgroundColor = color
        cell.titleLabel?.textColor = UIColor.whiteColor()
        cell.statusLabel?.backgroundColor = color
        cell.statusLabel?.textColor = UIColor.whiteColor()
        
        return cell
    }
    
    // MARK: - Purchase
    
    
    
    // MARK: UICollectionViewDelegate
    
    public override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        if let info = infoForIndexPath(indexPath)
        {
            if let product = SKProduct.productWithIdentifier(info.identifier)
            {
                if !product.purchase({ self.collectionView?.reloadData() })
                {
                    let alert = UIAlertController(title: "Payments Disabled", message: "Please enable payments in Settings", preferredStyle: .Alert)
                    
                    let action = UIAlertAction(title: "Done", style: .Default, handler: nil)
                    
                    alert.addAction(action)
                    
                    presentViewController(alert, animated: true, completion: nil)
                }
            }
            
        }
        
        return false
    }
    
    override public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        if let info = infoForIndexPath(indexPath),
            let product = SKProduct.productWithIdentifier(info.identifier)
        {
            if !product.purchase({ self.collectionView?.reloadData() })
            {
                let alert = UIAlertController(title: "Payments Disabled", message: "Please enable payments in Settings", preferredStyle: .Alert)
                
                let action = UIAlertAction(title: "Done", style: .Default, handler: nil)
                
                alert.addAction(action)
                
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - UI
    
    func refreshUI(animated animated: Bool = false)
    {
        refreshCollectionView(animated: animated)
        refreshRestorePurchasesButton(animated: animated)
    }
    
    // MARK: - Cancel Button
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem?
    @IBOutlet weak var cancelButton: UIButton?
    
    @IBAction func cancelButtonPressed()
    {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Restore Button
    
    @IBOutlet weak var restorePurchasesBarButton: UIBarButtonItem?
    @IBOutlet weak var restorePurchasesButton: UIButton?
    
    @IBAction func restorePurchasesButtonPressed()
    {
        SKProduct.restoreProducts { (error) -> () in
            if let error = error
            {
                self.productsDelegate?.productsController(self, didEncounterError: error)
            }
            self.refreshRestorePurchasesButton()
        }
    }
    
    func refreshRestorePurchasesButton(animated animated: Bool = false)
    {
        let enabled = productIdentifiers.contains({ SKProduct.localizedInfoForProdutWithIdentifier($0).status != .Purchased })
        
        restorePurchasesButton?.enabled = enabled
        restorePurchasesBarButton?.enabled = enabled
    }
    
    // TODO: update animated
    func refreshCollectionView(animated animated: Bool = false)
    {
        if let collectionView = collectionView
        {
            let paths = collectionView.indexPathsForVisibleItems()
            
            if paths.isEmpty
            {
                collectionView.reloadData()
            }
            else
            {
                collectionView.performBatchUpdates({ collectionView.reloadItemsAtIndexPaths(paths) }, completion: nil)
            }
        }
    }
    
    // MARK: - ProductsViewController
    
    public var productsDelegate: ProductsViewControllerDelegate?

    public func refreshProducts(animated animated: Bool = true)
    {
        refreshCollectionView(animated: animated)
    }
}