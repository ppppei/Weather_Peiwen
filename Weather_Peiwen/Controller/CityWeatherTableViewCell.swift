//
//  CityWeatherTableViewCell.swift
//  Weather_Peiwen
//
//  Created by PPEI on 10/29/21.
//

import UIKit

class CityWeatherTableViewCell: UITableViewCell {
    
    @IBOutlet var lblTemp : UILabel!
    @IBOutlet var lblWeather : UILabel!
    @IBOutlet var lblCity : UILabel!
    @IBOutlet var weatherImage : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
