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

//        let expectation = XCTestExpectation(description: "The async function never came back")
//        mockDatabase.removeSingleFolder(folderID: folderB.id) { expectation.fulfill() }
//        waitForExpectations(timeout: 1)


final class FolderListViewModelTest: XCTestCase {
    
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
        let viewModel = FolderListViewModel(currentFolder: nil, database: database, queue: queue)
        
        // When
        let loadFolderID: UUID? = nil
        viewModel.loadItems(atFolderID: loadFolderID)
        
        // Then
        let result =  viewModel.items.count
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
        let fileA1 = File(name: "File in Folder A", folder: folderA.id)
        let fileAA1 = File(name: "File in Folder AA1", folder: folderAA1.id)
        let fileAA2 = File(name: "File in Folder AA2", folder: folderAA2.id)
        let fileAAA1 = File(name: "File in Folder AAA1", folder: folderAAA1.id)
        let files = [file1, file2, file3, fileA1, fileAA1, fileAA2, fileAAA1]
        
        
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: folders, files: files)
        let viewModel = FolderListViewModel(currentFolder: nil, database: database, queue: queue)
        
        // When
        let loadFolder = folderA
        viewModel.loadItems(atFolderID: loadFolder.id)
        
        // Then
        let result =  viewModel.items.count
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
        let fileA1 = File(name: "File in Folder A", folder: folderA.id)
        let files = [file1, file2, file3, fileA1]
        
        
        let queue = DispatchQueue.main
        let database = MockDataManager(folders: folders, files: files)
        let viewModel = FolderListViewModel(currentFolder: nil, database: database, queue: queue)
        
        // When
        let loadFolder = folderB
        viewModel.loadItems(atFolderID: loadFolder.id)
        
        // Then
        let result =  viewModel.items.count
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
        let viewModel = FolderListViewModel(currentFolder: nil, database: database, queue: queue)
        
        // When
        viewModel.handleOnAppear()
        
        // Then
        let result =  viewModel.items.count
        let expected = 11
        let firstNonFolderIndex = viewModel.items.firstIndex(where: { !($0 is Folder) })
        let isSorted = (firstNonFolderIndex == nil) || !viewModel.items[firstNonFolderIndex!...].contains(where: {$0 is Folder})

        XCTAssertEqual(result, expected)
        XCTAssertTrue(isSorted)
    }
    
    func test_renameFolder_updateFolderName_givenFolderIDAndName() throws {
        // Given

        // When

        // Then
    }
    
    func test_renameFile_updateFileName_givenFileIDAndName() throws {
        // Given

        // When

        // Then
    }
    
//    func test_addFolder_updatesFolders_givenFolderNameAndParentFolderID() throws {
//        // Given
//        let folderA = Folder(name: "Folder A")
//        let folderB = Folder(name: "Folder B")
//        let folderC = Folder(name: "Folder C")
//        let folders = [folderA, folderB, folderC]
//        
//        let file1 = File(name: "File1 in Library")
//        let file2 = File(name: "File2 in Library")
//        let fileA1 = File(name: "File in Folder A", folder: folderA.id)
//        let files = [file1, file2, fileA1]
//        
//        let queue =
//        let database = MockDataManager(folders: folders, files: files)
//        let viewModel = FolderListViewModel(currentFolder: nil, database: database)
//        
//        // When
//        let beforeCount = viewModel.items.count
//        viewModel.addFolder(folderName: "My Favorite Folder")
//        
//        // Then
//        let result =  viewModel.items.count
//        let expected = beforeCount + 1
//        XCTAssertEqual(result, expected)
//    }
    
    
//    func test_removeSingleFolder_removesFolderWithoutContents_givenFolder() throws {
////        // given
////        let folderA = Folder(name: "Folder A")
////        let folderB = Folder(name: "Folder B")
////        let folderC = Folder(name: "Folder C")
////        let folders = [folderA, folderB, folderC]
////        let database = MockDataManager(folders: folders)
////        let viewModel = FolderListViewModel(currentFolder: nil, database: database)
////        
////        // when
////        let beforeCount = viewModel.items.count
//////        let expectation = XCTestExpectation(description: "The async function never came back")
////        viewModel.removeItem(item: folderA)
////        
////        // then
////        let result = viewModel.items.count
////        let expected = beforeCount - 1
////        XCTAssertEqual(result, expected)
//    }
    
//    func test_removeSingleFolder_removesFolderWhenFolderIsOnlyItem_givenFolder() throws {
//        // given
//        let folderA = Folder(name: "Folder A")
//        let folderB = Folder(name: "Folder B")
//        let folderC = Folder(name: "Folder C")
//        let folders = [folderA, folderB, folderC]
//        let database = MockDataManager(folders: folders)
//        let viewModel = FolderListViewModel(currentFolder: nil, database: database)
//        
//        // when
//        let beforeCount = viewModel.items.count
//        viewModel.removeItem(item: folderA)
//        
//        // then
//        let result = viewModel.items.count
//        let expected = beforeCount - 1
//        XCTAssertEqual(result, expected)
//    }
//    
//    func test_fetchFolders_returnsListOfFolders_givenParentFolderID() throws {
////        // TODO: Given
////        
////        // When
////        let expectation = XCTestExpectation(description: "The async function never came back")
////        var result = 0
////        mockDatabase.fetchFolders(parentID: nil) { folders in
////            result = folders.count
////            expectation.fulfill()
////        }
////        waitForExpectations(timeout: 1)
////        
////        // Then
////        let expected = 3
////        XCTAssertEqual(result, expected)
//    }
//    
//
//    
//    func test_removeFolder_removesAllNestedFoldersAndFiles_givenFolder() throws {
//        // Given
//        
//        // When
//        
//        // Then
//        
//    }
//    func test_moveFolder_updateParentFolderId_givenFolderIDAndParentFolderID() throws {
//        // Given
//        
//        // When
//        
//        // Then
//        
//    }
//
//    func test_fetchSingleFolder_returnFolder_givenFolderID() throws {
//        // Given
//        
//        // When
//        
//        // Then
//        
//    }
//    func test_addFile_updatesFiles_givenFileNameAndFolderID() throws {
//        // Given
//        
//        // When
//        
//        // Then
//        
//    }
//    func test_removeFile_updatesFiles_givenFileID() throws {
//        // Given
//        
//        // When
//        
//        // Then
//        
//    }
//    func test_moveFile_updatesFolderID_givenFileIDAndNewFolderID() throws {
//        // Given
//        
//        // When
//        
//        // Then
//        
//    }
//    func test_renameFile_updatesFileName_givenFileIDAndName() throws {
//        // Given
//        
//        // When
//        
//        // Then
//        
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
