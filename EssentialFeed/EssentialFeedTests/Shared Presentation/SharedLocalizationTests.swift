//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Lorenzo Limoli on 04/03/23.
//  Copyright © 2023 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

final class SharedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let presentationBundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizedKeyAndValuesExists(in: presentationBundle, table)
    }
    
    
    
    // MARK: - Helpers
    private final class DummyView: ResourceView{
        typealias ResourceViewModel = String
        func display(_ viewModel: String) {
            
        }
    }
}
