//
//  FolderListViewModelTest.swift
//  MemoNestTests
//
//  Created by Fatima Kahbi on 3/8/24.
//

import XCTest
@testable import MemoNest

final class FolderListViewModelTest: XCTestCase {
    var mockDatabase: DataManager!
    var viewModel: FolderListViewModel!

    override func setUpWithError() throws {
        mockDatabase = MockDataManager()
        viewModel = FolderListViewModel(currentFolder: nil, database: mockDatabase)
    }

    override func tearDownWithError() throws {
        mockDatabase = nil
        viewModel = nil
    }

    func test_() throws {
        
        // given
        
        
        // when
        
        // then
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
