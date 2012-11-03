//
//  OSUTableView.h
//  BeaverTableView
//
//  Created by Chris Vanderschuere on 11/2/12.
//  Copyright (c) 2012 OSU iOS App Club. All rights reserved.
//

#import <UIKit/UIKit.h>

//Subclass protocols with methods specfic to this class
@protocol OSUTableViewDataSource <UITableViewDataSource>
@required
//We need to make this required because we use it to add cells for gestures
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
@end

//This give us the flexibility to add methods to the normal UITableViewDelegate protocol; Thing subclassing for protocols
@protocol OSUTableViewDelegate <UITableViewDelegate>


@end

@interface OSUTableView : UITableView <UITableViewDataSource, UITableViewDelegate>

//Create two new delegate/datasource connections to intercept some of those calls
//Forward the rest to the actual dataSource/Delegate
@property (nonatomic, weak) IBOutlet id <OSUTableViewDataSource> osuDataSource;
@property (nonatomic, weak) IBOutlet id <OSUTableViewDelegate> osuDelegate;

@end
