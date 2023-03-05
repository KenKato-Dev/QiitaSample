//
//  QiitaTableViewCell.swift
//  QiitaSample
//
//  Created by 加藤研太郎 on 2023/02/16.
//

import UIKit

class QiitaTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var createdDay: UILabel!
    @IBOutlet weak var title: UILabel!
    static let id = "QiitaTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    static func nib() -> UINib {
        return UINib(nibName: QiitaTableViewCell.id, bundle: nil)
        }
    
}
