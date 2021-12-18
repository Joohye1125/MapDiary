//
//  DiaryItem.swift
//  MapDiary
//
//  Created by 이주혜 on 2021/12/18.
//

import Foundation
import UIKit

struct DiaryItem {
    let id: Int
    var title: String
    var date: Date
    var contents: String
    var image: UIImage
    var location: GPS
}

struct GPS {
    let latitude: Double // 위도
    let longitude: Double // 경도
}
