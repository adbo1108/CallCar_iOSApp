//
//  DriverTableViewCell.swift
//  Uber_clone
//
//  Created by USI on 2018/10/9.
//  Copyright © 2018年 USI. All rights reserved.
//

import UIKit

class DriverTableViewCell: UITableViewCell {

   
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    func configureCell(profileImg:UIImage,email:String,description:String){
     self.profileImgView.image = profileImg
        self.emailLabel.text = email
        self.descriptionLabel.text = description
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
