//
//  SettingsButtonCell.swift
//  DockTracker
//
//  Created by Андрей Бабков on 04/11/2018.
//  Copyright © 2018 Андрей Бабков. All rights reserved.
//

import UIKit

class SettingsButtonCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func fillCell(with text: String) {
        button!.setTitle(text, for: .normal)
    }

}
