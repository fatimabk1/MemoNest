//
//  FolderListViewModelTest.swift
//  MemoNestTests
//
//  Created by Fatima Kahbi on 3/8/24.
//

import XCTest
import Combine
@testable import MemoNest

/*
 
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
 let fileA1 = File(name: "File in Folder A", folder: folderA.id)
 let fileAA1 = File(name: "File in Folder AA1", folder: folderAA1.id)
 let fileAA2 = File(name: "File in Folder AA2", folder: folderAA2.id)
 let fileAAA1 = File(name: "File in Folder AAA1", folder: folderAAA1.id)
 let files = [file1, file2, file3, fileA1, fileAA1, fileAA2, fileAAA1]
 
 */


/*
let queue = DispatchQueue.main
let database = MockDataManager(folders: [folderA], files: [file1])
let viewModel = FolderListViewModel(database: database, queue: queue)

// When
var c = Set<AnyCancellable>()
let expectation = XCTestExpectation(description: "async function did not return")
var result = ""
viewModel.$items
    .dropFirst()
    .sink { items in
        result = items.first(where: {$0.id == file1.id})?.name ?? "NO ITEMS"
        expectation.fulfill()
    }
    .store(in: &c)
let expected = "MyFile"
viewModel.renameItem(item: file1, name: expected)
wait(for: [expectation], timeout: 1)
*/

final class FolderListViewModelTest: XCTestCase {
    
    func test_setFolder_setsCurrentFolder_givenFolder() throws {
        let folderA = Folder(name: "folderA")
        let folderAA = Folder(name: "folderAA", parent: folderA.id)
        let fileAA = File(name: "fileAA", parent: folderA.id)
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA, folderAA], files: [fileAA])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When
        var c = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "async function did not return")
        var result = 0
        viewModel.$items
            .dropFirst()
            .sink { items in
                result = items.count
                expectation.fulfill()
            }
            .store(in: &c)
        
        viewModel.setFolder(item: folderA)
        wait(for: [expectation], timeout: 1)
        
        // Then
        let expected = 2
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0 is Folder) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0 is Folder})
 
        // verify correct number of items
        XCTAssertEqual(result, expected)
        // verify sorted file first
        XCTAssertTrue(isSorted)
    }
    
    func test_loadItems_loadItemsFoldersFirst_givenRootFolder() throws {
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
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When
        var c = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "async function did not return")
        var result = 0
        viewModel.$items
            .dropFirst()
            .sink { items in
                result = items.count
                expectation.fulfill()
            }
            .store(in: &c)
        
        let loadFolderID: UUID? = nil
        viewModel.loadItems(atFolderID: loadFolderID)
        wait(for: [expectation], timeout: 1)
        
        // Then
        let expected = 11
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0 is Folder) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0 is Folder})
 
        // verify correct number of items
        XCTAssertEqual(result, expected)
        // verify sorted file first
        XCTAssertTrue(isSorted)
    }
    
    func test_loadItems_loadItemsFoldersFirst_givenNestedFolder() throws {
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
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When
        var c = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "async function did not return")
        var result = 0
        viewModel.$items
            .dropFirst()
            .sink { items in
                result = items.count
                expectation.fulfill()
            }
            .store(in: &c)
        let loadFolder = folderA
        viewModel.loadItems(atFolderID: loadFolder.id)
        wait(for: [expectation], timeout: 1)
        
        // Then
        let expected = 3
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0 is Folder) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0 is Folder})
        
        // verify correct number of items
        XCTAssertEqual(result, expected)
        // verify sorted file first
        XCTAssertTrue(isSorted)
    }
    
    func test_loadItems_loadItemsFoldersFirst_givenEmptyFolder() throws {
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
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When
        var c = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "async function did not return")
        var result = 0
        viewModel.$items
            .dropFirst()
            .sink { items in
                result = items.count
                expectation.fulfill()
            }
            .store(in: &c)
        let loadFolder = folderB
        viewModel.loadItems(atFolderID: loadFolder.id)
        wait(for: [expectation], timeout: 1)
        
        // Then
        let expected = 0
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0 is Folder) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0 is Folder})
        
        // verify correct number of items
        XCTAssertEqual(result, expected)
        // verify sorted file first
        XCTAssertTrue(isSorted)
    }
    
    func test_handleOnAppear_loadRootFolder() throws {
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
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When
        var c = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "async function did not return")
        var result = 0
        viewModel.$items
            .dropFirst()
            .sink { items in
                result = items.count
                expectation.fulfill()
            }
            .store(in: &c)
        viewModel.handleOnAppear()
        wait(for: [expectation], timeout: 1)
        
        // Then
        let expected = 11
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0 is Folder) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0 is Folder})

        XCTAssertEqual(result, expected)
        XCTAssertTrue(isSorted)
    }
    
    func test_renameFolder_updateFolderName_givenFolder() throws {
        // Given
        let folderA = Folder(name: "Folder A")
        let folders = [folderA]
        
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: folders, files: [])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When
        var c = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "async function did not return")
        var result = ""
        viewModel.$items
            .dropFirst()
            .sink { items in
                result = items.first?.name ?? "NO ITEMS"
                expectation.fulfill()
            }
            .store(in: &c)
        let expected = "MyFolder"
        viewModel.renameItem(item: folderA, name: expected)
        wait(for: [expectation], timeout: 1)

        // Then
        XCTAssertEqual(result, expected)
    }
    
    func test_renameFile_updateFileName_givenFile() throws {
        // Given
        let folderA = Folder(name: "Folder A")
        let file1 = File(name: "File1")
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA], files: [file1])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When
        var c = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "async function did not return")
        var result = ""
        viewModel.$items
            .dropFirst()
            .sink { items in
                result = items.first(where: {$0.id == file1.id})?.name ?? "NO ITEMS"
                expectation.fulfill()
            }
            .store(in: &c)
        let expected = "MyFile"
        viewModel.renameItem(item: file1, name: expected)
        wait(for: [expectation], timeout: 1)
        
        // Then
        XCTAssertEqual(result, expected)
    }
    
    func test_moveFile_updatesFolderID_givenFileIDAndNewFolderID() throws {
        // Given
        let folderA = Folder(name: "folderA")
        let file1 = File(name: "file1")
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA], files: [file1])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When
        var c = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "async function did not return")
        viewModel.$items
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &c)
        viewModel.moveItem(item: file1, destinationFolderID: folderA.id)
        wait(for: [expectation], timeout: 1)
        
        // Then
        let expected = 1
        let result = viewModel.items.count
        XCTAssertEqual(result, expected)
    }
    
    func test_moveFolder_updateParentFolderId_givenFolderIDAndParentFolderID() throws {
        // Given
        let folderA = Folder(name: "folderA")
        let folderB = Folder(name: "folderB")
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA, folderB], files: [])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When - move folderA into folderB
        var c = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "async function did not return")
        viewModel.$items
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &c)
        viewModel.moveItem(item: folderA, destinationFolderID: folderB.id)
        wait(for: [expectation], timeout: 1)
        
        // Then
        let expected = 1
        let result = viewModel.items.count
        XCTAssertEqual(result, expected)
    }
    
    func test_addFolder_updatesFolders_givenFolderNameAndParentFolderID() throws {
        // Given
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [], files: [])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When - move folderA into folderB
        var c = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "async function did not return")
        viewModel.$items
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &c)
        viewModel.addFolder(folderName: "NewFolder")
        wait(for: [expectation], timeout: 1)
        
        // Then
        let expected = 1
        let result = viewModel.items.count
        XCTAssertEqual(result, expected)
    }
    
    func test_addFile_updatesFiles_givenFileNameAndParentFolderID() throws {
        // Given
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [], files: [])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When - move folderA into folderB
        var c = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "async function did not return")
        viewModel.$items
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &c)
        viewModel.addFile(fileName: "NewFile")
        wait(for: [expectation], timeout: 1)
        
        // Then
        let expected = 1
        let result = viewModel.items.count
        XCTAssertEqual(result, expected)
    }
    
    func test_removeItem_removesFile_givenFileID() throws {
        // Given
        let folderA = Folder(name: "folderA")
        let file1 = File(name: "file1")
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA], files: [file1])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When
        var c = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "async function did not return")
        viewModel.$items
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &c)
        viewModel.removeItem(item: file1)
        wait(for: [expectation], timeout: 1)
        
        // Then
        let expected = 1
        let result = viewModel.items.count
        XCTAssertEqual(result, expected)
    }
    
    func test_removeItem_removesEmptyFolder_givenFolderID() throws {
        // Given
        let folderA = Folder(name: "folderA")
        let file1 = File(name: "file1")
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA], files: [file1])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When
        var c = Set<AnyCancellable>()
        let expectation = XCTestExpectation(description: "async function did not return")
        viewModel.$items
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &c)
        viewModel.removeItem(item: folderA)
        wait(for: [expectation], timeout: 1)
        
        // Then
        let expected = 1
        let result = viewModel.items.count
        XCTAssertEqual(result, expected)
    }
    
    func test_removeItem_removesFolderWithNestedContent_givenFolderID() throws {
        // Given
        let folderA = Folder(name: "folderA")
        let folderAA = Folder(name: "folderAA", parent: folderA.id)
        let folderAAA = Folder(name: "folderAAA", parent: folderAA.id)
        let file1 = File(name: "file1")
        let fileA = File(name: "child file in A", parent: folderA.id)
        let fileAA = File(name: "child file in AA", parent: folderAA.id)
        let fileAAA = File(name: "child file in AAAA", parent: folderAAA.id)
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA, folderAA, folderAAA],
                                       files: [file1, fileA, fileAA, fileAAA])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When
        var c = Set<AnyCancellable>()
        let expectation1 = XCTestExpectation(description: "async function did not return")
        viewModel.$items
            .dropFirst()
            .sink { _ in
                expectation1.fulfill()
            }
            .store(in: &c)
        viewModel.removeItem(item: folderA)
        wait(for: [expectation1], timeout: 1)
        
        
        // Then
        // PASS CONDITION 1: root has one less item
        var expected = 1
        var result = viewModel.items.count
        XCTAssertEqual(result, expected)
        
        // PASS CONDITION 2: no items with folder A as parent
        expected = 0
        result = database.files.filter({ $0.parent == folderA.id}).count + database.folders.filter({ $0.parent == folderA.id}).count
        XCTAssertEqual(result, expected)
        
        // PASS CONDITION 3: no items with folder AA as parent
        expected = 0
        result = database.files.filter({ $0.parent == folderAA.id}).count + database.folders.filter({ $0.parent == folderAA.id}).count
        XCTAssertEqual(result, expected)
        
        // PASS CONDITION 4: no items with folder AAA as parent
        expected = 0
        result = database.files.filter({ $0.parent == folderAAA.id}).count + database.folders.filter({ $0.parent == folderAAA.id}).count
        XCTAssertEqual(result, expected)
    }
}
