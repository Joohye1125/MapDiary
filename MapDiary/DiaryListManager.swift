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
    }
    
    func delete(_ item: DiaryItem) {
        
    }
    
    func update(_ item: DiaryItem) {
        
    }
    
    func createItem(image: UIImage,title: String, contents: String) -> DiaryItem {
        
        // image에서 메타데이터 파싱
        // DiaryItem 객체 생성
        let nextId = DiaryListManager.lastId + 1
        DiaryListManager.lastId = nextId
        
        return DiaryItem(id: nextId, title: title, date: Date.now, contents: contents, image: image, location: GPS(latitude: 37.5, longitude: 128.5))
    }
   
    
}
