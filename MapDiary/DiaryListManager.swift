//
//  DiaryListManager.swift
//  MapDiary
//
//  Created by 이주혜 on 2021/12/18.
//

import Foundation
import UIKit
import RxSwift
import os

class DiaryListManager {
    
    static let shared = DiaryListManager()
    
    private let dbManager = DbManager.shared
    
    var lastId: Int = 0
   
    var diaryItemAddSubject = PublishSubject<DiaryItem>()
    var diaryItemRemoveSubject = PublishSubject<DiaryItem>()
    var diaryItemUpdateSubject = PublishSubject<DiaryItem>()
    var diaryItemChangedSubject = PublishSubject<Bool>()
    
    var diaryItems: [DiaryItem] = []
    
    private init() {
        load()
        
        lastId = diaryItems.last?.id ?? 0
    }
    
    func load() {
        diaryItems = dbManager.load()
    }
    
    func save(item: DiaryItem) {
        dbManager.save(item: item)
    }
    
    func add(_ item: DiaryItem) {
        diaryItems.append(item)
        
        var log = "Add Item. Id: \(item.id)"
        os_log("%@", type: .default, log)
        
        log = "Item count: \(self.diaryItems.count)"
        os_log("%@", type: .debug, log)
        
        save(item: item)
        
        diaryItemAddSubject.onNext(item)
        diaryItemChangedSubject.onNext(true)
    }
    
    func delete(_ item: DiaryItem) {
        if let index = diaryItems.firstIndex(of: item) {
            diaryItems.remove(at: index)
        }
        
        var log = "Delete Item. Id: \(item.id)"
        os_log("%@", type: .default, log)
        
        log = "Item count: \(self.diaryItems.count)"
        os_log("%@", type: .debug, log)
        
        dbManager.delete(id: item.id)
        
        diaryItemRemoveSubject.onNext(item)
    }
    
    func update(_ item: DiaryItem) {
        guard let index = diaryItems.firstIndex(of: item) else { return }
        diaryItems[index].update(title: item.title, contents: item.contents, image: item.image, metadata: item.imgMetadata)
        
        var log = "Updage Item. Id: \(item.id)"
        os_log("%@", type: .default, log)
        
        log = "Item count: \(self.diaryItems.count)"
        os_log("%@", type: .debug, log)
        
        dbManager.update(item: item)
        
        diaryItemUpdateSubject.onNext(item)
        diaryItemChangedSubject.onNext(true)
    }
    
    func createItem(image: UIImage,title: String, contents: String, metadata: ImageMetadata) -> DiaryItem {
        // image에서 메타데이터 파싱
        // DiaryItem 객체 생성
        let nextId = lastId + 1
        lastId = nextId
        
        var log = "Create Item. Id: \(nextId)"
        os_log("%@", type: .default, log)
        
        log = "Item count: \(self.diaryItems.count)"
        os_log("%@", type: .debug, log)
      
        return DiaryItem(id: nextId, title: title, date: Date.now, contents: contents, image: image, imgMetadata: metadata)
    }
   
}
