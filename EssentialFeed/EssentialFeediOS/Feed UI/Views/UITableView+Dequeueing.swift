//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 21/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import UIKit

extension UITableView{
    func dequeueReusableCell<T: UITableViewCell>() -> T{
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
