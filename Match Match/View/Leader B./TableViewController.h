//
//  TableViewController.h
//  Match Match
//
//  Created by Ali on 8.12.2019.
//  Copyright © 2019 Ali. All rights reserved.
//

#import <UIKit/UIKit.h>
@import FirebaseCore;
@import FirebaseFirestore;

NS_ASSUME_NONNULL_BEGIN

@interface TableViewController : UITableViewController
@property (nonatomic, readwrite) FIRFirestore *db;
@end

NS_ASSUME_NONNULL_END
