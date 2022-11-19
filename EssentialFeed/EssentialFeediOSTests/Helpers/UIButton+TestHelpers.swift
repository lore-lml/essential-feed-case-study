//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Lorenzo Limoli on 19/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import UIKit

extension UIButton{
    func simulateTap(){
        simulate(event: .touchUpInside)
    }
}
