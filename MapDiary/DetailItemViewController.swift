//
//  DetailItemViewController.swift
//  MapDiary
//
//  Created by 이주혜 on 2021/12/12.
//

import UIKit
import SQLite3

class DetailItemViewController: UIViewController {

    @IBOutlet var naviItem: UINavigationItem!
    @IBOutlet weak var contents: UITextView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var diaryItem: DiaryItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.topItem?.title = ""
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
      
        self.image.image = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let item = diaryItem else {return}
        
        self.image.image = item.image.downSample(scale: 0.8)
        self.contents.text = item.contents
        self.naviItem.title = item.date.toString(dateFormat: "yyyy-MM-dd")
        self.titleLabel.text = item.title
        
        self.naviItem.rightBarButtonItem?.tintColor = .black
  
        guard let date = item.imgMetadata.imageDateTime else {
            self.dateLabel.isHidden = true
            return
        }
        self.dateLabel.text = date.toString(dateFormat: "yyyy-MM-dd a hh:mm")
        self.dateLabel.isHidden = false
     
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailItemUpdateSegue" {
            let vc = segue.destination as! DetailItemUpdateViewController
            vc.diaryItem = diaryItem
        }
    }
    

}

