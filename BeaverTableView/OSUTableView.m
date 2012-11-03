//
//  OSUTableView.m
//  BeaverTableView
//
//  Created by Chris Vanderschuere on 11/2/12.
//  Copyright (c) 2012 OSU iOS App Club. All rights reserved.
//

#import "OSUTableView.h"
#define PULL_HEIGHT 60
@interface OSUTableView()

@property (nonatomic, strong) NSIndexPath *indexOfAddedCell;
@property CGFloat addedRowHeight;

@end

@implementation OSUTableView
@synthesize osuDataSource = _osuDataSource, osuDelegate = _osuDelegate;
@synthesize indexOfAddedCell = _indexOfAddedCell, addedRowHeight = _addedRowHeight;

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
       
    }
    return self;
}
-(void) setOsuDelegate:(id<OSUTableViewDelegate>)osuDelegate{
    //Get all delegate messages
    //We forward ones we don't implement with forwardInvocation
    _osuDelegate = osuDelegate;
    self.delegate = self;
}
-(void) setOsuDataSource:(id<OSUTableViewDataSource>)osuDataSource{
    //We connect these up directly because we don't need to intercept any datasource calls
    self.dataSource = osuDataSource;
}
#pragma mark - UIScrollViewDelegate
//This works because uitableview inherits from uiscrollview
-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    // Check if addingIndexPath not exists, we don't want to
    if (scrollView.contentOffset.y<0 && self.indexOfAddedCell == nil) {
        //Add new cell to datasource
        [self beginUpdates];
        //Add a new object to our model
        [self.dataSource tableView:self commitEditingStyle:UITableViewCellEditingStyleInsert forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        //Told table view to update at specific row
        [self insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        //Save indexpath and row height for later use
        self.indexOfAddedCell = [NSIndexPath indexPathForRow:0 inSection:0];
        self.addedRowHeight = fabsf(scrollView.contentOffset.y); //Floating absolute value
        
        [self endUpdates]; //All animations happen here
    }
    else if (self.indexOfAddedCell){
        // alter the contentOffset of our scrollView
        self.addedRowHeight += scrollView.contentOffset.y * -1;
        self.addedRowHeight = MAX(1,MIN(self.rowHeight, self.addedRowHeight)); //Make sure the row doesnt get bigger or smaller than it should 1<addedRowHeight<rowHeight
        [self reloadData];
        [scrollView setContentOffset:CGPointZero];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //When we lift our finger...we want to check whether we should add the cell or not
    //Add cell if has been fully created
    if ([self cellForRowAtIndexPath:self.indexOfAddedCell].bounds.size.height >= self.rowHeight) {
        //Keep cell but update cells
        self.indexOfAddedCell = nil;
        self.addedRowHeight = 0;
        
        [self reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if(self.indexOfAddedCell){
        //Discard cell
        [self beginUpdates];
        //Delete from our model
        [self.dataSource tableView:self commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        //Remove from table view
        [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.indexOfAddedCell] withRowAnimation:UITableViewRowAnimationNone];
        
        //No longer need to store added cell
        self.indexOfAddedCell = nil;
        self.addedRowHeight = 0;
        
        [self endUpdates]; //Animation happends here
    }
    
}
#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(OSUTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath isEqual:self.indexOfAddedCell]) {
        return self.addedRowHeight;
    }
    else if([self.osuDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]){
        [self.osuDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return self.rowHeight;
}
#pragma mark - Methods Forwarding
//These three methods are allow us to be our own delegate without taking away delegate calls for our osuDelegate
-(BOOL)respondsToSelector:(SEL)aSelector{
    //This makes sure that all delegate methods are supported by the osuDelegate are supported by us through message forwarding
    if ([self.osuDelegate respondsToSelector:aSelector]) {
        return YES;
    }
    return [super respondsToSelector:aSelector];
}
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([self.osuDelegate respondsToSelector:[anInvocation selector]])
        [anInvocation invokeWithTarget:self.osuDelegate];
    else
        [super forwardInvocation:anInvocation];
}
- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        signature = [[self.osuDelegate class] methodSignatureForSelector:selector];
    }
    return signature;
}

@end
