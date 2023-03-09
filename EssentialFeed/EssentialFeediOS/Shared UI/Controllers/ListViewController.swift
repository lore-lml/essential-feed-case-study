//
//  ListViewController.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 13/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

final public class ListViewController: UITableViewController, UITableViewDataSourcePrefetching{
    
    private(set) public var errorView = ErrorView()
    
    public var onRefresh: (() -> Void)?
    
    private var loadingControllers = [IndexPath: CellController]()
    
    private var tableModel: [CellController] = []{
        didSet{ tableView.reloadData() }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        configureErrorView()
        refresh()
    }
    
    private func configureErrorView(){
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(errorView)
        
        errorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: container.topAnchor),
            container.bottomAnchor.constraint(equalTo: errorView.bottomAnchor),
        ])
        
        tableView.tableHeaderView = container
        
        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.sizeTableHeaderToFit()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ds = cellController(forRowAt: indexPath).dataSource
        return ds.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let delegate = removeLoadingControllers(forRowAt: indexPath)?.delegate
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach{ indexPath in
            let dataSourcePrefetching = cellController(forRowAt: indexPath).dataSourcePrefetching
            dataSourcePrefetching?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach{ indexPath in
            let dataSourcePrefetching = removeLoadingControllers(forRowAt: indexPath)?.dataSourcePrefetching
            dataSourcePrefetching?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellController{
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }
    
    private func removeLoadingControllers(forRowAt indexPath: IndexPath) -> CellController?{
        let controller = loadingControllers[indexPath]
        loadingControllers[indexPath] = nil
        return controller
    }
}

extension ListViewController{
    public func display(_ cellControllers: [CellController]){
        loadingControllers = [:]
        tableModel = cellControllers
    }
}

extension ListViewController: ResourceLoadingView{
    @IBAction private func refresh(){
        onRefresh?()
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
}

extension ListViewController: ResourceErrorView{
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
}
