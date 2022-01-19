//
//  MapViewModel.swift
//  MapDiary
//
//  Created by 이주혜 on 2021/12/18.
//

import Foundation

class DiaryListViewModel {
    
    private let manager = DiaryListManager.shared
    
    var diaryItems: [DiaryItem] {
        return manager.diaryItems
    }
    
    var sortedItems: [DiaryItem] {
        let sortedList = manager.diaryItems.sorted { prev, next  in
            return prev.date > next.date
        }
        
        return sortedList
    }
    
    var numOfDiaryItems: Int {
        return diaryItems.count
    }
    
    func diaryItem(at index:
                   Int) -> DiaryItem {
        return sortedItems[index]
    }
    
    func add(item: DiaryItem) {
        manager.add(item)
    }
    
    func delete(item: DiaryItem) {
        manager.delete(item)
    }
    
    func update(item: DiaryItem) {
        manager.update(item)
    }
}
