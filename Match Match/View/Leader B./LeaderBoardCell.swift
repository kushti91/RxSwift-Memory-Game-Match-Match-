//
//  LeaderBoardCell.swift
//  Match Match
//
//  Created by Ali on 8.12.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

import UIKit

class LeaderBoardCell: UITableViewCell {

    @IBOutlet weak var circularLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var user: User? {
        didSet{
            //circularLabel.text = String((user?.nickName?.dropFirst(2)) ?? "")
            nickNameLabel.text = user?.nickName ?? ""
            scoreLabel.text = "\(user?.highScore ?? 0)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        circularLabel.layer.cornerRadius = circularLabel.frame.size.height / 2
        circularLabel.backgroundColor = .lightGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
