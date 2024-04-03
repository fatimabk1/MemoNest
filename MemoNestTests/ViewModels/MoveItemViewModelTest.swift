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
    
    func test_setFolder_setsCurrentFolder_givenFolder()  {
        let folderA = Folder(name: "folderA")
        let folderAA = Folder(name: "folderAA", parent: folderA.id)
        let fileAA = File(name: "fileAA", parent: folderA.id)
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA, folderAA], files: [fileAA])
        let viewModel = MoveItemViewModel(database: database, queue: queue)
        
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
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0 is Folder) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0 is Folder})
 
        // verify correct number of items
        XCTAssertEqual(result, expected)
        // verify sorted file first
        
    }
    
    func test_loadFolders_loadFolders_givenRootFolder()  {
        // Given
        let folderA = Folder(name: "Folder A")
        let folderB = Folder(name: "Folder B")
        let folderC = Folder(name: "Folder C")
        let folders = [folderA, folderB, folderC]
        
        let file1 = File(name: "File1 in Library")
        let file2 = File(name: "File2 in Library")
        let file3 = File(name: "File3 in Library")
        let file4 = File(name: "File4 in Library")
        let file5 = File(name: "File5 in Library")
        let file6 = File(name: "File6 in Library")
        let file7 = File(name: "File7 in Library")
        let file8 = File(name: "File8 in Library")
        let files = [file1, file2, file3, file4, file5, file6, file7, file8]
        
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: folders, files: files)
        let viewModel = MoveItemViewModel(database: database, queue: queue)
        
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
        let folderA = Folder(name: "Folder A")
        let folderB = Folder(name: "Folder B")
        let folderC = Folder(name: "Folder C")
        let folderAA1 = Folder(name: "Folder AA1", parent: folderA.id)
        let folderAA2 = Folder(name: "Folder AA2", parent: folderA.id)
        let folderAAA1 = Folder(name: "Folder AAA1", parent: folderAA1.id)
        let folders = [folderA, folderB, folderC, folderAA1, folderAA2, folderAAA1]
        
        let file1 = File(name: "File1 in Library")
        let file2 = File(name: "File2 in Library")
        let file3 = File(name: "File3 in Library")
        let fileA1 = File(name: "File in Folder A", parent: folderA.id)
        let fileAA1 = File(name: "File in Folder AA1", parent: folderAA1.id)
        let fileAA2 = File(name: "File in Folder AA2", parent: folderAA2.id)
        let fileAAA1 = File(name: "File in Folder AAA1", parent: folderAAA1.id)
        let files = [file1, file2, file3, fileA1, fileAA1, fileAA2, fileAAA1]
        
        
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: folders, files: files)
        let viewModel = MoveItemViewModel(database: database, queue: queue)
        
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
        let folderA = Folder(name: "Folder A")
        let folderB = Folder(name: "Folder B")
        let folderC = Folder(name: "Folder C")
        let folders = [folderA, folderB, folderC]
        
        let file1 = File(name: "File1 in Library")
        let file2 = File(name: "File2 in Library")
        let file3 = File(name: "File3 in Library")
        let fileA1 = File(name: "File in Folder A", parent: folderA.id)
        let files = [file1, file2, file3, fileA1]
        
        
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: folders, files: files)
        let viewModel = MoveItemViewModel(database: database, queue: queue)
        
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
        let folderA = Folder(name: "Folder A")
        let folderB = Folder(name: "Folder B")
        let folderC = Folder(name: "Folder C")
        let folders = [folderA, folderB, folderC]
        
        let file1 = File(name: "File1 in Library")
        let file2 = File(name: "File2 in Library")
        let file3 = File(name: "File3 in Library")
        let file4 = File(name: "File4 in Library")
        let file5 = File(name: "File5 in Library")
        let file6 = File(name: "File6 in Library")
        let file7 = File(name: "File7 in Library")
        let file8 = File(name: "File8 in Library")
        let files = [file1, file2, file3, file4, file5, file6, file7, file8]
        
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: folders, files: files)
        let viewModel = MoveItemViewModel(database: database, queue: queue)
        
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
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0 is Folder) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0 is Folder})

        XCTAssertEqual(result, expected)
        
    }
    
    func test_moveFile_updatesFolderID_givenFileIDAndNewFolderID()  {
        // Given
        let folderA = Folder(name: "folderA")
        let file1 = File(name: "file1")
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA], files: [file1])
        let viewModel = MoveItemViewModel(database: database, queue: queue)
        
        // When
        // TEST: move file1 into folder A
        // setFolder to folder A
        // call moveItem(item: FolderA)
        
        // ----------------------------------------------------------------------------------
        // Set currentFolder to Folder A
        let setFolderExpectation = XCTestExpectation(description: "async function did not return")
        let setFolderCancellable = viewModel.$currentFolder
            .sink { _ in
                setFolderExpectation.fulfill()
            }
        viewModel.setFolder(item: folderA)
        wait(for: [setFolderExpectation], timeout: 1)
        setFolderCancellable.cancel()
        XCTAssertEqual(viewModel.currentFolderTitle, "folderA")
        
        // Move Folder B into Folder A
        let expectation = XCTestExpectation(description: "async function did not return")
        let cancellable = viewModel.$items
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
        viewModel.moveItem(item: file1)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        let expected = 1
        let result = viewModel.items.count
        XCTAssertEqual(result, expected)
    }
    
    func test_moveFolder_updateParentFolderId_givenFolderIDAndParentFolderID()  {
        // Given
        let folderA = Folder(name: "folderA")
        let folderB = Folder(name: "folderB")
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA, folderB], files: [])
        let viewModel = MoveItemViewModel(database: database, queue: queue)
        
        // When - move folderA into folderB
        // TEST: move folderA into folderB
        // setFolder to folder B
        // call moveItem(item: FolderA)
        
        // ----------------------------------------------------------------------------------
        // Set currentFolder to Folder A
        let setFolderExpectation = XCTestExpectation(description: "async function did not return")
        let setFolderCancellable = viewModel.$currentFolder
            .sink { _ in
                setFolderExpectation.fulfill()
            }
        viewModel.setFolder(item: folderB)
        wait(for: [setFolderExpectation], timeout: 1)
        XCTAssertEqual(viewModel.currentFolderTitle, "folderB")
        setFolderCancellable.cancel()
        
        
        let expectation = XCTestExpectation(description: "async function did not return")
        let cancellable = viewModel.$items
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
        viewModel.moveItem(item: folderA)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        let expected = 1
        let result = viewModel.items.count
        XCTAssertEqual(result, expected)
    }
}
