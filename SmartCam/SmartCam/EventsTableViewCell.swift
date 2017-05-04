//
//  EventsTableViewCell.swift
//  SmartCam
//
//  Created by Prathiba Lingappan on 5/4/17.
//  Copyright © 2017 Prathiba Lingappan. All rights reserved.
//

import UIKit

class EventsTableViewCell: UITableViewCell {

    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var videoName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
