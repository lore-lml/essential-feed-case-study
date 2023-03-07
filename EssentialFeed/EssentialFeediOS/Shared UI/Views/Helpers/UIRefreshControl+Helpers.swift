//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 12/12/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import UIKit

extension UIRefreshControl{
    func update(isRefreshing: Bool){
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
