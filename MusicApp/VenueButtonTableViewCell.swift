//
//  VenueButtonTableViewCell.swift
//  MusicApp
//
//  Created by Nick Arcuri on 7/18/18.
//  Copyright © 2018 Nick Arcuri. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol VenueButtonCellDelegate {
    func venueButtonTouched(track: JSON)
}

class VenueButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var venueDetailLabel: UILabel!
    @IBOutlet weak var venueButton: AppButton!
    
    var delegate: VenueButtonCellDelegate?
    var track: JSON?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func venueButtonTouched(_ sender: Any) {
        guard let track = track else { return }
        
        delegate?.venueButtonTouched(track: track)
    }
    
}
