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
    
    // MARK: setAction
    func test_setAction_setRenamePopup_givenItemAndAction(){
        // given
        let folderA = Folder(name: "folderA")
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
        let folderA = Folder(name: "folderA")
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA], files: [])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // when
        viewModel.setAction(action: .add, item: nil)
        
        //then
        XCTAssertEqual(viewModel.popup.popupTitle, "Add Folder")
        XCTAssertEqual(viewModel.popup.prompt, "Enter folder name")
        XCTAssertEqual(viewModel.popup.placeholder, "New Folder")
    }
    
    // MARK: set folder
    func test_setFolder_setsCurrentFolder_givenFolder()  {
        let folderA = Folder(name: "folderA")
        let folderAA = Folder(name: "folderAA", parent: folderA.id)
        let fileAA = File(name: "fileAA", parent: folderA.id)
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
        
        viewModel.setFolder(item: folderA)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        XCTAssertEqual(viewModel.currentFolderTitle, "folderA")
        
        let expected = 2
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0 is Folder) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0 is Folder})
 
        // verify correct number of items
        XCTAssertEqual(result, expected)
        // verify sorted file first
        XCTAssertTrue(isSorted)
    }
    
    // MARK: load
    func test_loadItems_loadItemsFoldersFirst_givenRootFolder()  {
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
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0 is Folder) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0 is Folder})
 
        // verify correct number of items
        XCTAssertEqual(result, expected)
        // verify sorted file first
        XCTAssertTrue(isSorted)
    }
    
    func test_loadItems_loadItemsFoldersFirst_givenNestedFolder()  {
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
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0 is Folder) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0 is Folder})
        
        // verify correct number of items
        XCTAssertEqual(result, expected)
        // verify sorted file first
        XCTAssertTrue(isSorted)
    }
    
    func test_loadItems_loadItemsFoldersFirst_givenEmptyFolder()  {
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
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0 is Folder) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0 is Folder})
        
        // verify correct number of items
        XCTAssertEqual(result, expected)
        // verify sorted file first
        XCTAssertTrue(isSorted)
    }
    
    // MARK: on appear
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
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0 is Folder) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0 is Folder})

        XCTAssertEqual(result, expected)
        XCTAssertTrue(isSorted)
    }
        
    // MARK: sort
    func test_sortItems_givenItemsAndSortByName() {
        let AfolderEarliestDate = Folder(name: "AfolderEarliestDate", date: Date())
        let BfolderMiddleDate = Folder(name: "BfolderMiddleDate", date: Date() + 1)
        let CfolderLatestDate = Folder(name: "CfolderLatestDate", date: Date() + 2)
        
        let ALatestDateFile = File(name: "ALatestDateFile", date: Date() + 2)
        let BMiddleDateFile = File(name: "BMiddleDateFile", date: Date() + 1)
        let CEarliestDateFile = File(name: "CEarliestDateFile", date: Date())
        
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
        let AfolderEarliestDate = Folder(name: "AfolderEarliestDate", date: Date())
        let BfolderMiddleDate = Folder(name: "BfolderMiddleDate", date: Date() + 1)
        let CfolderLatestDate = Folder(name: "CfolderLatestDate", date: Date() + 2)
        
        let ALatestDateFile = File(name: "ALatestDateFile", date: Date() + 2)
        let BMiddleDateFile = File(name: "BMiddleDateFile", date: Date() + 1)
        let CEarliestDateFile = File(name: "CEarliestDateFile", date: Date())
        
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
            print(item.name)
        }
        XCTAssertEqual(viewModel.items[0].name, AfolderEarliestDate.name)
        XCTAssertEqual(viewModel.items[1].name, BfolderMiddleDate.name)
        XCTAssertEqual(viewModel.items[2].name, CfolderLatestDate.name)
        XCTAssertEqual(viewModel.items[3].name, CEarliestDateFile.name)
        XCTAssertEqual(viewModel.items[4].name, BMiddleDateFile.name)
        XCTAssertEqual(viewModel.items[5].name, ALatestDateFile.name)
    }
    
    func test_sortItems_givenItemsAndSortByDateDesc() {
        let AfolderEarliestDate = Folder(name: "AfolderEarliestDate", date: Date())
        let BfolderMiddleDate = Folder(name: "BfolderMiddleDate", date: Date() + 1)
        let CfolderLatestDate = Folder(name: "CfolderLatestDate", date: Date() + 2)
        
        let ALatestDateFile = File(name: "ALatestDateFile", date: Date() + 2)
        let BMiddleDateFile = File(name: "BMiddleDateFile", date: Date() + 1)
        let CEarliestDateFile = File(name: "CEarliestDateFile", date: Date())
        
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
    func test_renameItem_updateFolderName_givenFolder()  {
        // Given
        let folderA = Folder(name: "Folder A")
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
    
    func test_renameItem_updateFileName_givenFile()  {
        // Given
        let folderA = Folder(name: "Folder A")
        let file1 = File(name: "File1")
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [folderA], files: [file1])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When
        let expectation = XCTestExpectation(description: "async function did not return")
        var result = ""
        let cancellable = viewModel.$items
            .dropFirst()
            .sink { items in
                result = items.first(where: {$0.id == file1.id})?.name ?? "NO ITEMS"
                expectation.fulfill()
            }
        let expected = "MyFile"
        viewModel.renameItem(item: file1, name: expected)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        XCTAssertEqual(result, expected)
    }
    
    // MARK: remove
    func test_removeItem_removesEmptyFolder_givenFolderID()  {
        // Given
        let folderA = Folder(name: "folderA")
        let file1 = File(name: "file1")
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
        let expectation = XCTestExpectation(description: "async function did not return")
        let cancellable = viewModel.$items // make a disposable cancellable for testing
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }

        viewModel.removeItem(item: folderA)
        wait(for: [expectation], timeout: 1)
        cancellable.cancel() // removes from combine's dispose bag
        
        // Then
        // PASS CONDITION 1: root has one less item
        var expected = 1
        var result = viewModel.items.count
        XCTAssertEqual(result, expected)
        
        // PASS CONDITION 2: no items with folder A as parent
        expected = 0
        result = database.files.filterByParent(folderA.id).count + database.folders.filterByParent(folderA.id).count
        XCTAssertEqual(result, expected)
        
        // PASS CONDITION 3: no items with folder AA as parent
        expected = 0
        result = database.files.filterByParent(folderAA.id).count + database.folders.filterByParent(folderAA.id).count
        XCTAssertEqual(result, expected)
        
        // PASS CONDITION 4: no items with folder AAA as parent
        expected = 0
        result = database.files.filterByParent(folderAAA.id).count + database.folders.filterByParent(folderAAA.id).count
        XCTAssertEqual(result, expected)
    }
    
    func test_removeItem_removesFile_givenFileID()  {
        // Given
        let folderA = Folder(name: "folderA")
        let file1 = File(name: "file1")
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
    
    // MARK: add
    func test_addFile_updatesFiles_givenFileNameAndParentFolderID()  {
        // Given
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [], files: [])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When - move folderA into folderB
        let expectation = XCTestExpectation(description: "async function did not return")
        let cancellable = viewModel.$items
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
        viewModel.addFile(fileName: "NewFile")
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        
        // Then
        let expected = 1
        let result = viewModel.items.count
        XCTAssertEqual(result, expected)
    }
    
    func test_addFolder_updatesFolders_givenFolderNameAndParentFolderID()  {
        // Given
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: [], files: [])
        let viewModel = FolderListViewModel(database: database, queue: queue)
        
        // When - move folderA into folderB
        let expectation = XCTestExpectation(description: "async function did not return")
        let cancellable = viewModel.$items
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
    
    // TODO: setPlaybackFile
//    func test_setPlaybackFile_setFileAndFlag_givenItem() {}

}

// TODO: Item struct for all, nil struct for recording metadata
extension Array where Element: Item {
    func filterByParent(_ folderID: UUID?) -> [Element] {
        return self.filter({ $0.parent == folderID})
    }
}

