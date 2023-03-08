//
//  ListViewController.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 13/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

public typealias CellController = UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching

final public class ListViewController: UITableViewController, UITableViewDataSourcePrefetching{
    
    @IBOutlet private(set) public var errorView: ErrorView?
    
    public var onRefresh: (() -> Void)?
    
    private var loadingControllers = [IndexPath: CellController]()
    
    private var tableModel: [CellController] = []{
        didSet{ tableView.reloadData() }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        refresh()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.sizeTableHeaderToFit()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let controller = cellController(forRowAt: indexPath)
        return controller.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let controller = removeLoadingControllers(forRowAt: indexPath)
        controller?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach{ indexPath in
            let controller = cellController(forRowAt: indexPath)
            controller.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach{ indexPath in
            let controller = removeLoadingControllers(forRowAt: indexPath)
            controller?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
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
        errorView?.message = viewModel.message
    }
}
