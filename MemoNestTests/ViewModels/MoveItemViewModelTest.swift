//
//  MoveItemViewModelTest.swift
//  MemoNestTests
//
//  Created by Fatima Kahbi on 3/28/24.
//

import XCTest
import Combine
@testable import MemoNest

final class MoveItemViewModelTest: XCTestCase {
    
    func test_itemIsMoveItem_returnsTrue_givenMoveItem() {
        // given
        let folderA = Item(name: "folderA", type: .folder)
        let folderAA = Item(name: "folderAA", parent: folderA.id, type: .folder)
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA, folderAA], files: [])
        let viewModel = MoveItemViewModel(moveItem: folderA, database: database, queue: queue)
        
        // when
        let isMoveItem = viewModel.itemIsMoveItem(item: folderA)
        
        // then
        XCTAssertTrue(isMoveItem)
    }
    
    func test_itemIsMoveItem_returnsTrue_givenOtherItem() {
        // given
        let folderA = Item(name: "folderA", type: .folder)
        let folderAA = Item(name: "folderAA", parent: folderA.id, type: .folder)
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA, folderAA], files: [])
        let viewModel = MoveItemViewModel(moveItem: folderA, database: database, queue: queue)
        
        // when
        let isMoveItem = viewModel.itemIsMoveItem(item: folderAA)
        
        // then
        XCTAssertFalse(isMoveItem)
    }
    
    func test_setFolder_setsCurrentFolder_givenFolder()  {
        let folderA = Item(name: "folderA", type: .folder)
        let folderAA = Item(name: "folderAA", parent: folderA.id, type: .folder)
        let fileAA = Item(name: "fileAA", parent: folderA.id, type: .recording, audioInfo: Item.sampleAudioInfo)
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA, folderAA], files: [fileAA])
        let viewModel = MoveItemViewModel(moveItem: folderA, database: database, queue: queue)
        
        // When
        let expectation = XCTestExpectation(description: "async function did not return")
        var result = 0
        let cancellable = viewModel.$items
            .dropFirst()
            .sink { items in
                result = items.count
                for item in items {
                    print(item.name)
                }
                expectation.fulfill()
            }
        
        viewModel.setFolder(item: folderA)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        XCTAssertEqual(viewModel.currentFolderTitle, "folderA")
        let expected = 1
 
        // verify correct number of items
        XCTAssertEqual(result, expected)
    }
    
    func test_loadFolders_loadFolders_givenRootFolder()  {
        // Given
        let folderA = Item(name: "Folder A", type: .folder)
        let folderB = Item(name: "Folder B", type: .folder)
        let folderC = Item(name: "Folder C", type: .folder)
        let folders = [folderA, folderB, folderC]
        
        let file1 = Item(name: "File1 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file2 = Item(name: "File2 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file3 = Item(name: "File3 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file4 = Item(name: "File4 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file5 = Item(name: "File5 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file6 = Item(name: "File6 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file7 = Item(name: "File7 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file8 = Item(name: "File8 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let files = [file1, file2, file3, file4, file5, file6, file7, file8]
        
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: folders, files: files)
        let viewModel = MoveItemViewModel(moveItem: folderA, database: database, queue: queue)
        
        // When
        let expectation = XCTestExpectation(description: "async function did not return")
        var result = 0
        let cancellable = viewModel.$items
            .dropFirst()
            .sink { items in
                result = items.count
                expectation.fulfill()
            }
        
        let loadFolderID: UUID? = nil
        viewModel.loadFolders(atFolderID: loadFolderID)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        let expected = 3
 
        // verify correct number of items
        XCTAssertEqual(result, expected)
        // verify sorted file first
        
    }
    
    func test_loadFolders_loadFolders_givenNestedFolder()  {
        // Given
        let folderA = Item(name: "Folder A", type: .folder)
        let folderB = Item(name: "Folder B", type: .folder)
        let folderC = Item(name: "Folder C", type: .folder)
        let folderAA1 = Item(name: "Folder AA1", parent: folderA.id, type: .folder)
        let folderAA2 = Item(name: "Folder AA2", parent: folderA.id, type: .folder)
        let folderAAA1 = Item(name: "Folder AAA1", parent: folderAA1.id, type: .folder)
        let folders = [folderA, folderB, folderC, folderAA1, folderAA2, folderAAA1]
        
        let file1 = Item(name: "File1 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file2 = Item(name: "File2 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file3 = Item(name: "File3 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let fileA1 = Item(name: "File in Folder A", parent: folderA.id, type: .recording, audioInfo: Item.sampleAudioInfo)
        let fileAA1 = Item(name: "File in Folder AA1", parent: folderAA1.id, type: .recording, audioInfo: Item.sampleAudioInfo)
        let fileAA2 = Item(name: "File in Folder AA2", parent: folderAA2.id, type: .recording, audioInfo: Item.sampleAudioInfo)
        let fileAAA1 = Item(name: "File in Folder AAA1", parent: folderAAA1.id, type: .recording, audioInfo: Item.sampleAudioInfo)
        let files = [file1, file2, file3, fileA1, fileAA1, fileAA2, fileAAA1]
        
        
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: folders, files: files)
        let viewModel = MoveItemViewModel(moveItem: folderA, database: database, queue: queue)
        
        // When
        let expectation = XCTestExpectation(description: "async function did not return")
        var result = 0
        let cancellable = viewModel.$items
            .dropFirst()
            .sink { items in
                result = items.count
                expectation.fulfill()
            }
        let loadFolder = folderA
        viewModel.loadFolders(atFolderID: loadFolder.id)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        let expected = 2
        
        // verify correct number of items
        XCTAssertEqual(result, expected)
        // verify sorted file first
        
    }
    
    func test_loadFolders_loadFolders_givenEmptyFolder()  {
        // Given
        let folderA = Item(name: "Folder A", type: .folder)
        let folderB = Item(name: "Folder B", type: .folder)
        let folderC = Item(name: "Folder C", type: .folder)
        let folders = [folderA, folderB, folderC]
        
        let file1 = Item(name: "File1 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file2 = Item(name: "File2 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file3 = Item(name: "File3 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let fileA1 = Item(name: "File in Folder A", parent: folderA.id, type: .recording, audioInfo: Item.sampleAudioInfo)
        let files = [file1, file2, file3, fileA1]
        
        
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: folders, files: files)
        let viewModel = MoveItemViewModel(moveItem: folderA, database: database, queue: queue)
        
        // When
        let expectation = XCTestExpectation(description: "async function did not return")
        var result = 0
        let cancellable = viewModel.$items
            .dropFirst()
            .sink { items in
                result = items.count
                expectation.fulfill()
            }
        let loadFolder = folderB
        viewModel.loadFolders(atFolderID: loadFolder.id)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        let expected = 0
        
        // verify correct number of items
        XCTAssertEqual(result, expected)
        // verify sorted file first
        
    }
    
    func test_handleOnAppear_loadRootFolder()  {
        // Given
        let folderA = Item(name: "Folder A", type: .folder)
        let folderB = Item(name: "Folder B", type: .folder)
        let folderC = Item(name: "Folder C", type: .folder)
        let folders = [folderA, folderB, folderC]
        
        let file1 = Item(name: "File1 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file2 = Item(name: "File2 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file3 = Item(name: "File3 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file4 = Item(name: "File4 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file5 = Item(name: "File5 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file6 = Item(name: "File6 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file7 = Item(name: "File7 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let file8 = Item(name: "File8 in Library", type: .recording, audioInfo: Item.sampleAudioInfo)
        let files = [file1, file2, file3, file4, file5, file6, file7, file8]
        
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: folders, files: files)
        let viewModel = MoveItemViewModel(moveItem: folderA, database: database, queue: queue)
        
        // When
        let expectation = XCTestExpectation(description: "async function did not return")
        var result = 0
        let cancellable = viewModel.$items
            .dropFirst()
            .sink { items in
                result = items.count
                expectation.fulfill()
            }
        viewModel.handleOnAppear()
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        let expected = 3
        XCTAssertEqual(result, expected)
    }
}
