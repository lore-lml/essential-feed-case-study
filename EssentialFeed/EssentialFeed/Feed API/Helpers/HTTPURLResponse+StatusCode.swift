//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Lorenzo Limoli on 13/01/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import Foundation

extension HTTPURLResponse{
    private static var ok200: Int{ return 200 }
    
    var isOk: Bool{
        return statusCode == Self.ok200
    }
}
