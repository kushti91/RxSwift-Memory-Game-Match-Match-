//
//  TableViewCell.h
//  Match Match
//
//  Created by Ali on 8.12.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *circularLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@end

NS_ASSUME_NONNULL_END
