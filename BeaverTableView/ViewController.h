//
//  ViewController.h
//  BeaverTableView
//
//  Created by Chris Vanderschuere on 11/2/12.
//  Copyright (c) 2012 OSU iOS App Club. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

//View
@property (nonatomic, strong) IBOutlet UITableView *tableView;
//Model
@property (nonatomic, strong) NSMutableArray *tableInformation;

@end
