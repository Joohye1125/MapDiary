//
//  DbManager.swift
//  MapDiary
//
//  Created by DewBook on 2021/12/27.
//

import Foundation
import UIKit
import SQLite3

class DbManager {
    
    static let shared = DbManager()
    
    var db:OpaquePointer?
    
    private let TABLE_NAME = "Diary"
    private let ROW_ID = "row_id"
    private let ID = "id"
    private let TITLE = "title"
    private let CONTENTS = "contents"
    private let CREATE_TIME = "create_time"
    private let LATITUDE = "latitude"
    private let LONGITUDE = "longitude"
    private let IMAGE = "image"
    private let IMAGE_CREATE_TIME = "img_create_time"
    
    private init() {
        openDb()
    }
    
    private func openDb(){
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(TABLE_NAME).sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Failed to open db")
        }
        
        let CREATE_QUERY_TEXT : String = """
                                        CREATE TABLE IF NOT EXISTS \(TABLE_NAME)
                                        (\(ROW_ID) INTEGER PRIMARY KEY AUTOINCREMENT,
                                        \(ID) INTEGER,
                                        \(TITLE) TEXT,
                                        \(CONTENTS) TEXT,
                                        \(CREATE_TIME) DOUBLE,
                                        \(LATITUDE) DOUBLE,
                                        \(LONGITUDE) DOUBLE,
                                        \(IMAGE) TEXT,
                                        \(IMAGE_CREATE_TIME) DOUBLE);
                                        """

       if sqlite3_exec(db, CREATE_QUERY_TEXT, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
       }
    }
    
    func load() -> [DiaryItem]{
        var items: [DiaryItem] = []
        
        let SELECT_QUERY = "SELECT * FROM \(TABLE_NAME)"
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, SELECT_QUERY, -1, &stmt, nil) != SQLITE_OK{
            let errMsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: v1\(errMsg)")
            return items
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 1)
            let title = String(cString: sqlite3_column_text(stmt, 2))
            let contents = String(cString: sqlite3_column_text(stmt, 3))
            let date = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 4))
            let latitude = sqlite3_column_double(stmt, 5)
            let longitude = sqlite3_column_double(stmt, 6)
            let image = DecodeBase64ToImage(strBase64: String(cString: sqlite3_column_text(stmt, 7)))
            let imgDate = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 8))

            let item = DiaryItem(id: Int(id),
                                 title: title,
                                 date: date,
                                 contents: contents,
                                 image: image,
                                 imgMetadata: ImageMetadata(imageDate: imgDate, location: GPS(latitude: latitude, longitude: longitude)))
            
            items.append(item)
        }
        
        return items
    }
    
    func save(item: DiaryItem) {
        var date = Date()
        if let dateTime = item.imgMetadata.imageDateTime {
            date = dateTime
        }
        
        let INSERT_QUERY = """
        INSERT INTO \(TABLE_NAME)
        (\(ID), \(TITLE), \(CONTENTS) ,\(CREATE_TIME) ,\(LATITUDE) ,\(LONGITUDE) ,\(IMAGE) ,\(IMAGE_CREATE_TIME))
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """
        
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, INSERT_QUERY, -1, &stmt, nil) == SQLITE_OK{
            let id = Int32(item.id)
            let title = item.title as NSString
            let contents = item.contents as NSString
            let timestamp = item.date.timeIntervalSince1970
            let latitude = item.imgMetadata.location.latitude
            let longitude = item.imgMetadata.location.longitude
            let image = EncodeImageToBase64(image: item.image) as NSString
            let imgDate = item.imgMetadata.imageDateTime?.timeIntervalSince1970 ?? date.timeIntervalSince1970
            
            sqlite3_bind_int(stmt, 1, id)
            sqlite3_bind_text(stmt, 2, title.utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, contents.utf8String, -1, nil)
            sqlite3_bind_double(stmt, 4, timestamp)
            sqlite3_bind_double(stmt, 5, latitude)
            sqlite3_bind_double(stmt, 6, longitude)
            sqlite3_bind_text(stmt, 7, image.utf8String, -1, nil)
            sqlite3_bind_double(stmt, 8, imgDate)
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                 print("\nSuccessfully inserted row.")
            } else {
                 print("\nCould not insert row.")
            }
        } else {
            print("\nINSERT statement is not prepared.")
      }
        
      sqlite3_finalize(stmt)
    }
    
    func update(item: DiaryItem) {
       let UPDATE_QUERY = """
        UPDATE \(TABLE_NAME)
        SET \(TITLE) = ?, \(CONTENTS) = ?, \(LATITUDE) = ?, \(LONGITUDE) = ?, \(IMAGE) = ?, \(IMAGE_CREATE_TIME) = ?
        WHERE \(ID) = ?
        """
        
        var date = Date()
        if let dateTime = item.imgMetadata.imageDateTime {
            date = dateTime
        }
        
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, UPDATE_QUERY, -1, &stmt, nil) == SQLITE_OK{
           
            let title = item.title as NSString
            let contents = item.contents as NSString
            let latitude = item.imgMetadata.location.latitude
            let longitude = item.imgMetadata.location.longitude
            let image = EncodeImageToBase64(image: item.image) as NSString
            let imgDate = item.imgMetadata.imageDateTime?.timeIntervalSince1970 ?? date.timeIntervalSince1970
            let id = Int32(item.id)
            
            sqlite3_bind_text(stmt, 1, title.utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, contents.utf8String, -1, nil)
            sqlite3_bind_double(stmt, 3, latitude)
            sqlite3_bind_double(stmt, 4, longitude)
            sqlite3_bind_text(stmt, 5, image.utf8String, -1, nil)
            sqlite3_bind_double(stmt, 6, imgDate)
            sqlite3_bind_int(stmt, 7, id)
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                 print("\nSuccessfully update row.")
            } else {
                 print("\nCould not update row.")
            }
        } else {
            print("\nUPDATE statement is not prepared.")
      }
        
      sqlite3_finalize(stmt)
    }
 
    func delete(id: Int) {
        let DELETE_QUERY = """
        DELETE FROM \(TABLE_NAME) WHERE \(ID) = ?;
        """
        
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, DELETE_QUERY, -1, &stmt, nil) == SQLITE_OK{
            let id = Int32(id)
           
            sqlite3_bind_int(stmt, 1, id)
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                 print("\nSuccessfully delete row.")
            } else {
                 print("\nCould not delete row.")
            }
        } else {
            print("\n DELETE statement is not prepared.")
          }
        
      sqlite3_finalize(stmt)
    }
}

extension DbManager {
    
    func EncodeImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()! as NSData
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        
        return strBase64
    }
    
    func DecodeBase64ToImage(strBase64: String) -> UIImage {
        let decodedData = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)
        guard let data = decodedData else { return UIImage() }
        let decodedimage = UIImage(data: data)!
        
        return decodedimage
    }
}
