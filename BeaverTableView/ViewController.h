//
//  ViewController.h
//  BeaverTableView
//
//  Created by Chris Vanderschuere on 11/2/12.
//  Copyright (c) 2012 OSU iOS App Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSUTableView.h" //Notice we had to import this file
@interface ViewController : UIViewController <OSUTableViewDataSource, OSUTableViewDelegate>

//View
@property (nonatomic, strong) IBOutlet OSUTableView *tableView;
//Model
@property (nonatomic, strong) NSMutableArray *tableInformation;

@end
