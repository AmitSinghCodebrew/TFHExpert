//
//  UITableViewExtensions.swift
//  GenericTableDataSource
//
//  Created by Sandeep Kumar on 13/07/19.
//  Copyright © 2019 SandsHellCreations. All rights reserved.
//

import UIKit


extension UITableView {
    
    func isValid(indexPath: IndexPath, inDataSource: Bool = true) -> Bool {
        guard
            let numberOfSections = inDataSource
                ? dataSource?.numberOfSections?(in: self)
                : numberOfSections,
            let numberOfRows = inDataSource
                ? dataSource?.tableView(self, numberOfRowsInSection: indexPath.section)
                : numberOfRows(inSection: indexPath.section)
        else {
            preconditionFailure("There must be a datasource to validate an index path")
        }
        return indexPath.section < numberOfSections && indexPath.row < numberOfRows
    }
    
    func reloadData(success: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            success?()
        }
        reloadData()
        CATransaction.commit()
    }
    
    func registerXIB(_ nibName: String) {
        register(UINib.init(nibName: nibName, bundle: nil), forCellReuseIdentifier: nibName)
    }
    
    func registerXIBForHeaderFooter(_ nibName: String) {
        register(UINib.init(nibName: nibName, bundle: nil), forHeaderFooterViewReuseIdentifier: nibName)
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func scrollToTop() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            if /self.isValid(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        }
    }
}

