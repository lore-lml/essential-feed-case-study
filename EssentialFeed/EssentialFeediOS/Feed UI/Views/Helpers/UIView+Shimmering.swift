//
//  UIView+Shimmering.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 17/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import UIKit

extension UIView{
    private var shimmerAnimationKey: String{ "shimmer" }
    
    public var isShimmering: Bool{
        get{
            layer.mask?.animation(forKey: shimmerAnimationKey) != nil
        }
        set{
            let action = newValue ? startShimmering : stopShimmering
            action()
        }
    }
    
    func startShimmering(){
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
        let width = bounds.width
        let height = bounds.height
        
        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1, y: 0.6)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
        layer.mask = gradient
        
        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmerAnimationKey)
    }
    
    func stopShimmering(){
        layer.mask = nil
    }
}
