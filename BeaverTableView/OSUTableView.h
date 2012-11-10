//
//  OSUTableView.h
//  BeaverTableView
//
//  Created by Chris Vanderschuere on 11/2/12.
//  Copyright (c) 2012 OSU iOS App Club. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum OSUTableViewState {
    OSUTableViewStateNone = 0,
    OSUTableViewStateDragging = 1,
    OSUTableViewStatePinching = 2
    } OSUTableViewState;


//Subclass protocols with methods specfic to this class
@protocol OSUTableViewDataSource <UITableViewDataSource>
@required
//We need to make this required because we use it to add cells for gestures
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
@end

//This give us the flexibility to add methods to the normal UITableViewDelegate protocol; Think subclassing for protocols
@protocol OSUTableViewDelegate <UITableViewDelegate>

@end

@interface OSUTableView : UITableView <UITableViewDelegate, UIGestureRecognizerDelegate> //We don't intercept any dataSource calls at this point

//Override the delegate/datasource of UITableView to use our custom protocols
@property (nonatomic, weak) IBOutlet id <OSUTableViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id <OSUTableViewDelegate> delegate;
@property OSUTableViewState state;

@end
