//
//  MockDataManagerTest.swift
//  MemoNestTests
//
//  Created by Fatima Kahbi on 3/8/24.
//

import XCTest
@testable import MemoNest

final class MockDataManagerTest: XCTestCase {
    var mockDatabase: DataManager!

    override func setUpWithError() throws {
        mockDatabase = MockDataManager()
    }

    override func tearDownWithError() throws {
        mockDatabase = nil
    }
    
    func test_removeSingleFolder_removesFolder_givenFolder() throws {
        // TODO: how to init with mockData when files/folders property should be read-only or private?
        // TODO: also, it seems like protocols don't allow for private properties?
        // Given -- mock data set in init
        let folderA = Folder(name: "Folder A")
        let folderB = Folder(name: "Folder B")
        let folderC = Folder(name: "Folder C")
        let folderAA1 = Folder(name: "Folder AA1", parent: folderA.id)
        let folderAA2 = Folder(name: "Folder AA2", parent: folderA.id)
        let folderAAA1 = Folder(name: "Folder AAA1", parent: folderAA1.id)
//        mockDatabase.folders = [folderA, folderB, folderC, folderAA1, folderAA2, folderAAA1]
        let file1 = File(name: "File1 in Library")
        let file2 = File(name: "File2 in Library")
        let file3 = File(name: "File3 in Library")
        let fileA1 = File(name: "File in Folder A", folder: folderA.id)
        let fileAA1 = File(name: "File in Folder AA1", folder: folderAA1.id)
        let fileAA2 = File(name: "File in Folder AA2", folder: folderAA2.id)
        let fileAAA1 = File(name: "File in Folder AAA1", folder: folderAAA1.id)
//        mockDatabase.files = [file1, file2, file3, fileA1, fileAA1, fileAA2, fileAAA1]
        
        let folderCount = mockDatabase.folders.count
        
        // When
        let expectation = XCTestExpectation(description: "The async function never came back")
        mockDatabase.removeSingleFolder(folderID: folderB.id) {}
        waitForExpectations(timeout: 1)
        
        // Then
        let result = mockDatabase.folders.count
        let expected = folderCount - 1
        XCTAssertEqual(result, expected)
    }
    
    func test_fetchFolders_returnsListOfFolders_givenParentFolderID() throws {
        // TODO: Given
        
        // When
        let expectation = XCTestExpectation(description: "The async function never came back")
        var fetchedFolders = [Folder]()
        mockDatabase.fetchFolders(parentID: nil) { folders in
            fetchedFolders = folders
        }
        waitForExpectations(timeout: 1)
        
        // Then
        let result = fetchedFolders.count
        let expected = 3
        XCTAssertEqual(result, expected)
        
        // TODO: lets say I want to test with a non-nil parentFolderID. Write a new test or continue here?
        // TODO: do I need to reset expectations at all?
        
    }
    
    func test_addFolder_updatesFolders_givenFolderNameAndParentFolderID() throws {
        // Given
        
        // When
        
        // Then
        
    }
    
    func test_removeFolder_removesAllNestedFoldersAndFiles_givenFolder() throws {
        // Given
        
        // When
        
        // Then
        
    }
    func test_moveFolder_updateParentFolderId_givenFolderIDAndParentFolderID() throws {
        // Given
        
        // When
        
        // Then
        
    }
    func test_renameFolder_updateFolderName_givenFolderIDAndName() throws {
        // Given
        
        // When
        
        // Then
        
    }
    func test_fetchSingleFolder_returnFolder_givenFolderID() throws {
        // Given
        
        // When
        
        // Then
        
    }
    func test_addFile_updatesFiles_givenFileNameAndFolderID() throws {
        // Given
        
        // When
        
        // Then
        
    }
    func test_removeFile_updatesFiles_givenFileID() throws {
        // Given
        
        // When
        
        // Then
        
    }
    func test_moveFile_updatesFolderID_givenFileIDAndNewFolderID() throws {
        // Given
        
        // When
        
        // Then
        
    }
    func test_renameFile_updatesFileName_givenFileIDAndName() throws {
        // Given
        
        // When
        
        // Then
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
