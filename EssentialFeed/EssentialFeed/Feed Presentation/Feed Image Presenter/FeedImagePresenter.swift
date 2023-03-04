//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Lorenzo Limoli on 21/11/22.
//  Copyright © 2022 Essential Developer. All rights reserved.
//

import Foundation

public final class FeedImagePresenter {
    
    private init(){}

    public static func map(_ image: FeedImage) -> FeedImageViewModel{
        FeedImageViewModel(
            description: image.description,
            location: image.location
        )
    }
}
