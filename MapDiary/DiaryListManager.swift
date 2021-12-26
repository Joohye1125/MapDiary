//
//  DiaryListManager.swift
//  MapDiary
//
//  Created by 이주혜 on 2021/12/18.
//

import Foundation
import UIKit

class DiaryListManager {
    
    static let shared = DiaryListManager()
    
    static var lastId: Int = 0
    
    var diaryItems: [DiaryItem] = []
    
    func load() {
        
    }
    
    func save() {
        
    }
    
    func add(_ item: DiaryItem) {
        diaryItems.append(item)
        print("Remaining count after add: \(diaryItems.count)")
        save()
    }
    
    func delete(_ item: DiaryItem) {
        if let index = diaryItems.firstIndex(of: item) {
            diaryItems.remove(at: index)
        }
        
        print("Remaining count after deleting: \(diaryItems.count)")
        
        save()
    }
    
    func update(_ item: DiaryItem) {
        guard let index = diaryItems.firstIndex(of: item) else { return }
        diaryItems[index].update(title: item.title, contents: item.contents, image: item.image, metadata: item.imgMetadata)
        save()
    }
    
    func createItem(image: UIImage,title: String, contents: String, metadata: ImageMetadata) -> DiaryItem {
        
        // image에서 메타데이터 파싱
        // DiaryItem 객체 생성
        let nextId = DiaryListManager.lastId + 1
        DiaryListManager.lastId = nextId
        
        return DiaryItem(id: nextId, title: title, date: Date.now, contents: contents, image: image, imgMetadata: metadata)
    }
   
    
}
