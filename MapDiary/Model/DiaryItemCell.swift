//
//  DetailItemTableViewCell.swift
//  MapDiary
//
//  Created by 이주혜 on 2021/12/16.
//

import UIKit

class DiaryItemCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
