//
//  FolderListViewModelTest.swift
//  MemoNestTests
//
//  Created by Fatima Kahbi on 3/8/24.
//

import XCTest
import Combine
@testable import MemoNest

final class FolderListViewModelTest: XCTestCase {
    
    // MARK: setAction
    func test_setAction_setRenamePopup_givenItemAndAction(){
        // given
        let folderA = Item(name: "folderA", type: .folder)
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA], files: [])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // when
        viewModel.setAction(action: .rename, item: folderA)
        
        //then
        XCTAssertEqual(viewModel.popup.popupTitle, "Rename")
        XCTAssertEqual(viewModel.popup.prompt, "Enter folder name")
        XCTAssertEqual(viewModel.popup.placeholder, folderA.name)
    }
    
    func test_setAction_setAddPopup_givenItemAndAction(){
        // given
        let folderA = Item(name: "folderA", type: .folder)
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA], files: [])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // when
        viewModel.setAction(action: .add, item: nil)
        
        //then
        XCTAssertEqual(viewModel.popup.popupTitle, "Add Folder")
        XCTAssertEqual(viewModel.popup.prompt, "New Folder")
        XCTAssertEqual(viewModel.popup.placeholder, "")
    }
    
    // MARK: set folder
    func test_setFolder_setsCurrentFolder_givenItem()  {
        let folderA = Item(name: "folderA", type: .folder)
        let folderAA = Item(name: "folderAA", parent: folderA.id, type: .folder)
        let fileAA = Item(name: "fileAA", parent: folderA.id, type: .recording, audioInfo: Item.sampleAudioInfo)
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA, folderAA], files: [fileAA])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When
        let expectation = XCTestExpectation(description: "async function did not return")
        var result = 0
        let cancellable = viewModel.$items
            .dropFirst()
            .sink { items in
                result = items.count
                expectation.fulfill()
            }
        
        viewModel.changeFolder(item: folderA)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        let expected = 2
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0.isFolder()) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0.isFolder()})
 
        // verify correct number of items
        XCTAssertEqual(result, expected)
        // verify sorted file first
        XCTAssertTrue(isSorted)
    }
    
    // MARK: load
    func test_loadItems_loadItemsFoldersFirst_givenRootItem()  {
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
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
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
        viewModel.loadItems(atFolderID: loadFolderID)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        let expected = 11
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0.isFolder()) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0.isFolder()})
 
        // verify correct number of items
        XCTAssertEqual(result, expected)
        // verify sorted file first
        XCTAssertTrue(isSorted)
    }
    
    func test_loadItems_loadItemsFoldersFirst_givenNestedItem()  {
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
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
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
        viewModel.loadItems(atFolderID: loadFolder.id)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        let expected = 3
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0.isFolder()) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0.isFolder()})
        
        // verify correct number of items
        XCTAssertEqual(result, expected)
        // verify sorted file first
        XCTAssertTrue(isSorted)
    }
    
    func test_loadItems_loadItemsFoldersFirst_givenEmptyItem()  {
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
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
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
        viewModel.loadItems(atFolderID: loadFolder.id)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        let expected = 0
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0.isFolder()) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0.isFolder()})
        
        // verify correct number of items
        XCTAssertEqual(result, expected)
        // verify sorted file first
        XCTAssertTrue(isSorted)
    }
    
    // MARK: on appear
    func test_handleOnAppear_loadRootItem()  {
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
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
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
        let expected = 11
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0.isFolder()) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0.isFolder()})

        XCTAssertEqual(result, expected)
        XCTAssertTrue(isSorted)
    }
        
    // MARK: sort
    func test_sortItems_givenItemsAndSortByName() {
        let AfolderEarliestDate = Item(name: "AfolderEarliestDate", date: Date(), type: .folder)
        let BfolderMiddleDate = Item(name: "BfolderMiddleDate", date: Date() + 1, type: .folder)
        let CfolderLatestDate = Item(name: "CfolderLatestDate", date: Date() + 2, type: .folder)
        
        let ALatestDateFile = Item(name: "ALatestDateFile", date: Date() + 2, type: .recording, audioInfo: Item.sampleAudioInfo)
        let BMiddleDateFile = Item(name: "BMiddleDateFile", date: Date() + 1, type: .recording, audioInfo: Item.sampleAudioInfo)
        let CEarliestDateFile = Item(name: "CEarliestDateFile", date: Date(), type: .recording, audioInfo: Item.sampleAudioInfo)
        
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [AfolderEarliestDate, BfolderMiddleDate, CfolderLatestDate],
                                       files: [ALatestDateFile, BMiddleDateFile, CEarliestDateFile])
        let viewModel = FolderListViewModel(database: database, queue: queue)

        // when
        let expectation = XCTestExpectation(description: "async function did not return")
        let cancellable = viewModel.$items
            .dropFirst()
            .sink { items in
                expectation.fulfill()
            }
        let loadFolderID: UUID? = nil
        viewModel.loadItems(atFolderID: loadFolderID)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()

        viewModel.sortType = .name
        
        // then
        for item in viewModel.items {
            print(item.name)
        }
        XCTAssertEqual(viewModel.items[0].name, AfolderEarliestDate.name)
        XCTAssertEqual(viewModel.items[1].name, BfolderMiddleDate.name)
        XCTAssertEqual(viewModel.items[2].name, CfolderLatestDate.name)
        XCTAssertEqual(viewModel.items[3].name, ALatestDateFile.name)
        XCTAssertEqual(viewModel.items[4].name, BMiddleDateFile.name)
        XCTAssertEqual(viewModel.items[5].name, CEarliestDateFile.name)
    }
    
    func test_sortItems_givenItemsAndSortByDateAsc() {
        let AfolderEarliestDate = Item(name: "AfolderEarliestDate", date: Date(), type: .folder)
        let BfolderMiddleDate = Item(name: "BfolderMiddleDate", date:Calendar.current.date(byAdding: .day, value: 1, to: Date())!, type: .folder)
        let CfolderLatestDate = Item(name: "CfolderLatestDate", date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, type: .folder)
        
        let ALatestDateFile = Item(name: "ALatestDateFile", date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, type: .recording, audioInfo: Item.sampleAudioInfo)
        let BMiddleDateFile = Item(name: "BMiddleDateFile", date:Calendar.current.date(byAdding: .day, value: 1, to: Date())!, type: .recording, audioInfo: Item.sampleAudioInfo)
        let CEarliestDateFile = Item(name: "CEarliestDateFile", date: Date(), type: .recording, audioInfo: Item.sampleAudioInfo)
        
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [AfolderEarliestDate, BfolderMiddleDate, CfolderLatestDate],
                                       files: [ALatestDateFile, BMiddleDateFile, CEarliestDateFile])
        let viewModel = FolderListViewModel(database: database, queue: queue)

        // when
        let expectation = XCTestExpectation(description: "async function did not return")
        let cancellable = viewModel.$items
            .dropFirst()
            .sink { items in
                expectation.fulfill()
            }
        let loadFolderID: UUID? = nil
        viewModel.loadItems(atFolderID: loadFolderID)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        viewModel.sortType = .dateAsc
        
        //then
        for item in viewModel.items {
            print(item.name, item.date)
        }
        XCTAssertEqual(viewModel.items[0].name, AfolderEarliestDate.name)
        XCTAssertEqual(viewModel.items[1].name, BfolderMiddleDate.name)
        XCTAssertEqual(viewModel.items[2].name, CfolderLatestDate.name)
        XCTAssertEqual(viewModel.items[3].name, CEarliestDateFile.name)
        XCTAssertEqual(viewModel.items[4].name, BMiddleDateFile.name)
        XCTAssertEqual(viewModel.items[5].name, ALatestDateFile.name)
    }
    
    func test_sortItems_givenItemsAndSortByDateDesc() {
        let AfolderEarliestDate = Item(name: "AfolderEarliestDate", date: Date(), type: .folder)
        let BfolderMiddleDate = Item(name: "BfolderMiddleDate", date: Date() + 1, type: .folder)
        let CfolderLatestDate = Item(name: "CfolderLatestDate", date: Date() + 2, type: .folder)
        
        let ALatestDateFile = Item(name: "ALatestDateFile", date: Date() + 2, type: .recording, audioInfo: Item.sampleAudioInfo)
        let BMiddleDateFile = Item(name: "BMiddleDateFile", date: Date() + 1, type: .recording, audioInfo: Item.sampleAudioInfo)
        let CEarliestDateFile = Item(name: "CEarliestDateFile", date: Date(), type: .recording, audioInfo: Item.sampleAudioInfo)
        
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [AfolderEarliestDate, BfolderMiddleDate, CfolderLatestDate],
                                       files: [ALatestDateFile, BMiddleDateFile, CEarliestDateFile])
        let viewModel = FolderListViewModel(database: database, queue: queue)

        // when
        let expectation = XCTestExpectation(description: "async function did not return")
        let cancellable = viewModel.$items
            .dropFirst()
            .sink { items in
                expectation.fulfill()
            }
        let loadFolderID: UUID? = nil
        viewModel.loadItems(atFolderID: loadFolderID)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        viewModel.sortType = .dateDesc
        
        //then
        for item in viewModel.items {
            print(item.name)
        }
        XCTAssertEqual(viewModel.items[0].name, CfolderLatestDate.name)
        XCTAssertEqual(viewModel.items[1].name, BfolderMiddleDate.name)
        XCTAssertEqual(viewModel.items[2].name, AfolderEarliestDate.name)
        XCTAssertEqual(viewModel.items[3].name, ALatestDateFile.name)
        XCTAssertEqual(viewModel.items[4].name, BMiddleDateFile.name)
        XCTAssertEqual(viewModel.items[5].name, CEarliestDateFile.name)
    }
    
    // MARK: rename
    func test_renameItem_updateItemName_givenItem()  {
        // Given
        let folderA = Item(name: "Folder A", type: .folder)
        let folders = [folderA]
        
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: folders, files: [])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When
        let expectation = XCTestExpectation(description: "async function did not return")
        var result = ""
        let cancellable = viewModel.$items
            .dropFirst()
            .sink { items in
                result = items.first?.name ?? "NO ITEMS"
                expectation.fulfill()
            }
        let expected = "MyFolder"
        viewModel.renameItem(item: folderA, name: expected)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        XCTAssertEqual(result, expected)
    }
        
    // MARK: remove
    func test_removeItem_removesEmptyFolder_givenFolderID()  {
        // Given
        let folderA = Item(name: "folderA", type: .folder)
        let file1 = Item(name: "file1", type: .recording, audioInfo: Item.sampleAudioInfo)
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA], files: [file1])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When
        let expectation = XCTestExpectation(description: "async function did not return")
        let cancellable = viewModel.$items
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
        viewModel.removeItem(item: folderA)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        let expected = 1
        let result = viewModel.items.count
        XCTAssertEqual(result, expected)
    }
    
    func test_removeItem_removesFolderWithNestedContent_givenFolderID() throws {
        // Given
        let folderA = Item(name: "folderA", type: .folder)
        let folderAA = Item(name: "folderAA", parent: folderA.id, type: .folder)
        let folderAAA = Item(name: "folderAAA", parent: folderAA.id, type: .folder)
        let file1 = Item(name: "file1", type: .recording, audioInfo: Item.sampleAudioInfo)
        let fileA = Item(name: "child file in A", parent: folderA.id, type: .recording, audioInfo: Item.sampleAudioInfo)
        let fileAA = Item(name: "child file in AA", parent: folderAA.id, type: .recording, audioInfo: Item.sampleAudioInfo)
        let fileAAA = Item(name: "child file in AAAA", parent: folderAAA.id, type: .recording, audioInfo: Item.sampleAudioInfo)
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA, folderAA, folderAAA],
                                       files: [file1, fileA, fileAA, fileAAA])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        for item in database.items {
            print(item.name)
        }
        
        // When
        let expectation = XCTestExpectation(description: "async function did not return")
        let cancellable = viewModel.$items // make a disposable cancellable for testing
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }

        viewModel.removeItem(item: folderA)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel() // removes from combine's dispose bag
        
        for item in database.items {
            print(item.name)
        }
        
        // Then
        // PASS CONDITION 1: root has one less item
        var expected = 1
        var result = viewModel.items.count
        XCTAssertEqual(result, expected)
        
        // PASS CONDITION 2: no items with folder A as parent
        expected = 0
        result = database.items.filterByParent(folderA.id).count
        XCTAssertEqual(result, expected)
        
        // PASS CONDITION 3: no items with folder AA as parent
        expected = 0
        result = database.items.filterByParent(folderAA.id).count
        XCTAssertEqual(result, expected)
        
        // PASS CONDITION 4: no items with folder AAA as parent
        expected = 0
        result = database.items.filterByParent(folderAAA.id).count
        XCTAssertEqual(result, expected)
    }
    
    func test_removeItem_removesItem_givenItemID()  {
        // Given
        let folderA = Item(name: "folderA", type: .folder)
        let file1 = Item(name: "file1", type: .recording, audioInfo: Item.sampleAudioInfo)
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA], files: [file1])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When
        let expectation = XCTestExpectation(description: "async function did not return")
        let cancellable = viewModel.$items
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
        viewModel.removeItem(item: file1)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        let expected = 1
        let result = viewModel.items.count
        XCTAssertEqual(result, expected)
    }
    
    func test_addFolder_updatesItems_givenFolderNameAndParentFolderID()  {
        // Given
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [], files: [])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When - move folderA into folderB
        let expectation = XCTestExpectation(description: "async function did not return")
        let cancellable = viewModel.$items
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
        viewModel.addFolder(folderName: "NewFolder")
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        let expected = 1
        let result = viewModel.items.count
        XCTAssertEqual(result, expected)
    }
}

extension Array where Element == Item {
    func filterByParent(_ folderID: UUID?) -> [Element] {
        return self.filter({ $0.parent == folderID})
    }
}

