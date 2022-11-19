//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Lorenzo Limoli on 19/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension FeedImageCell{
    var isShowingLocation: Bool{ !locationContainer.isHidden }
    var locationText: String?{ locationLabel.text }
    var descriptionText: String?{ descriptionLabel.text }
    
    var isShowingImageLoadingIndicator: Bool{
        feedImageContainer.isShimmering
    }
    
    var renderedImage: Data? { feedImageView.image?.pngData() }
    
    var isShowingRetryAction: Bool{ !feedImageRetryButton.isHidden }
    
    func simulateRetryAction(){
        feedImageRetryButton.simulateTap()
    }
}
