//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 17/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import UIKit

public final class FeedImageCell: UITableViewCell{
    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var feedImageContainer: UIView!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var feedImageRetryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction private func retryButtonTapped(){
        onRetry?()
    }
}
