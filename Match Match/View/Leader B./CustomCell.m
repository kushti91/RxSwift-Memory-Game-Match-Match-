//
//  TableViewCell.m
//  Match Match
//
//  Created by Ali on 8.12.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _circularLabel.layer.cornerRadius = _circularLabel.frame.size.height / 2 ;
    _circularLabel.backgroundColor = UIColor.lightGrayColor;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
