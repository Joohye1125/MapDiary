//
//  DateExtension.swift
//  MapDiary
//
//  Created by 이주혜 on 2021/12/19.
//

import Foundation

extension Date {
    
    func toString(dateFormat format: String ) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            dateFormatter.timeZone = TimeZone.autoupdatingCurrent
            dateFormatter.locale = Locale.current
            return dateFormatter.string(from: self)
        }
        
    func toStringKST(dateFormat format: String ) -> String {
        return self.toString(dateFormat: format)
    }
    
}
