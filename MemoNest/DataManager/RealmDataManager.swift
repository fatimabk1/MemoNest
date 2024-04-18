////
////  RealmDataManager.swift
////  MemoNest
////
////  Created by Fatima Kahbi on 3/6/24.
////
//
//import Foundation
//import Combine
//import RealmSwift
//
//
//final class RealmDataManager: DataManager {
//    private let realm: Realm?
//    
//    init(_ realm: Realm?) {
//        self.realm = realm
//    }
//
//    var cancellables = Set<AnyCancellable>()
//    
//    func fetchFolderInfo(folderID: UUID?) -> AnyPublisher<Folder?, Never> {
//        return Just<Folder?>(nil)
//            .eraseToAnyPublisher()
//    }
//    
//    func fetchFiles(parentID: UUID?) -> AnyPublisher<[AudioRecording], Never> {
//        return Just<[AudioRecording]>([])
//            .eraseToAnyPublisher()
//    }
//    
//    func fetchFolders(parentID: UUID?) -> AnyPublisher<[Folder], Never> {
//        return Just<[Folder]>([])
//            .eraseToAnyPublisher()
//    }
//    
//    func removeFolder(folderID: UUID) -> AnyPublisher<Void, Never> {
//        return Just<Void>(())
//            .eraseToAnyPublisher()
//    }
//    
//    func removeSingleFolder(folderID: UUID) -> AnyPublisher<Void, Never> {
//        return Just<Void>(())
//            .eraseToAnyPublisher()
//    }
//    
//    func removeFile(fileID: UUID) -> AnyPublisher<Void, Never> {
//        return Just<Void>(())
//            .eraseToAnyPublisher()
//    }
//    
//    func removeAll(ids: [UUID]) -> AnyPublisher<Void, Never> {
//        return Just<Void>(())
//            .eraseToAnyPublisher()
//    }
//    
//    func renameFolder(folderID: UUID, name: String) -> AnyPublisher<Void, Never> {
//        return Just<Void>(())
//            .eraseToAnyPublisher()
//    }
//    
//    func renameFile(fileID: UUID, name: String) -> AnyPublisher<Void, Never> {
//        return Just<Void>(())
//            .eraseToAnyPublisher()
//    }
//    
//    func moveFolder(folderID: UUID, newParentID: UUID?) -> AnyPublisher<Void, Never> {
//        return Just<Void>(())
//            .eraseToAnyPublisher()
//    }
//    
//    func moveFile(fileID: UUID, newParentID: UUID?) -> AnyPublisher<Void, Never> {
//        return Just<Void>(())
//            .eraseToAnyPublisher()
//    }
//    
//    func addFolder(folderName: String, parentID: UUID?) -> AnyPublisher<Void, Never> {
//        return Just<Void>(())
//            .eraseToAnyPublisher()
//    }
//    
//    func addFile(fileName: String, date: Date, parentID: UUID?, duration: TimeInterval, recordingURL: URL) -> AnyPublisher<Void, Never> {
//        return Just<Void>(())
//            .eraseToAnyPublisher()
//    }
//    
//    
//}
