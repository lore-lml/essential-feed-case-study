//
//  UIControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Lorenzo Limoli on 19/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import UIKit

extension UIControl{
    func simulate(event: UIControl.Event){
        allTargets.forEach{ target in
            actions(forTarget: target, forControlEvent: event)?.forEach{
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
