//
//  PagingTableView.swift
//  PagingTableView
//
//  Created by InJung Chung on 2017. 4. 16..
//  Copyright © 2017 InJung Chung. All rights reserved.
//

import UIKit

open class PagingTableView: UITableView {
    
    var indicator: UIActivityIndicatorView!
    private var _tempFooterView: UIView?
    internal var page: Int = 0
    internal var previousItemCount: Int = 0
    internal var previousPageCount = 0
    
    open var currentPage: Int {
        get {
            return page
        }
    }
    
    open weak var pagingDelegate: PagingTableViewDelegate? {
        didSet {
            pagingDelegate?.paginate(self, to: page)
        }
    }
    
    open private(set) var isLoading: Bool = false
    func startLoading() {
        showLoading()
        self.isLoading = true
    }
    func stopLoading(insertSectionWithRowCount count:Int, with rowAnimation: UITableView.RowAnimation = .none) {
        self.isLoading = false
        hideLoading()
        beginUpdates()
        insertSections(IndexSet(page...page), with: rowAnimation)
        insertRows(at: (0..<count).map{IndexPath(row: $0, section: page)}, with: rowAnimation)
        endUpdates()
    }
    
    open func reset() {
        page = 0
        previousItemCount = 0
        pagingDelegate?.paginate(self, to: page)
    }
    
    private func paginate(forIndexAt indexPath: IndexPath) {
        guard
            let totalSectionCount = dataSource?.numberOfSections?(in: self),
            let totalItemCount = dataSource?.tableView(self, numberOfRowsInSection: indexPath.section),
            indexPath.row == totalItemCount - 1,
            indexPath.section == totalSectionCount - 1 else { return }
        page += 1
        previousItemCount = totalItemCount
        pagingDelegate?.paginate(self, to: page)
    }
    
    private func showLoading() {
        _tempFooterView = tableFooterView
        tableFooterView = createLoadingView()
        indicator.startAnimating()
    }
    
    private func hideLoading() {
        indicator.stopAnimating()
        pagingDelegate?.didPaginate(self, to: page)
        self.tableFooterView = _tempFooterView
        _tempFooterView = nil
    }
    
    private func createLoadingView() -> UIView {
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50))
        indicator = UIActivityIndicatorView()
        indicator.color = UIColor.lightGray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        loadingView.addSubview(indicator)
        func centerIndicator() {
            let xCenterConstraint = NSLayoutConstraint(
                item: loadingView, attribute: .centerX, relatedBy: .equal,
                toItem: indicator, attribute: .centerX, multiplier: 1, constant: 0
            )
            loadingView.addConstraint(xCenterConstraint)
            
            let yCenterConstraint = NSLayoutConstraint(
                item: loadingView, attribute: .centerY, relatedBy: .equal,
                toItem: indicator, attribute: .centerY, multiplier: 1, constant: 0
            )
            loadingView.addConstraint(yCenterConstraint)
        }
        centerIndicator()
        return loadingView
    }
    
    
    override open func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell {
        paginate(forIndexAt: indexPath)
        return super.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
    
}
