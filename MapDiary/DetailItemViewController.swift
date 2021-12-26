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
    @IBOutlet var titleLabel: UILabel!
    
    var diaryItem: DiaryItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let item = diaryItem else {return}
        
        self.image.image = item.image
        self.contents.text = item.contents
        self.naviItem.title = item.date.toString(dateFormat: "yyyy-MM-dd")
        self.titleLabel.text = item.title
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailItemUpdateSegue" {
            let vc = segue.destination as! DetailItemUpdateViewController
            vc.diaryItem = diaryItem
        }
    }
    

}

