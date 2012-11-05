//
//  OSUTableView.m
//  BeaverTableView
//
//  Created by Chris Vanderschuere on 11/2/12.
//  Copyright (c) 2012 OSU iOS App Club. All rights reserved.
//

#import "OSUTableView.h"
#define PULL_HEIGHT self.rowHeight //This way the pull height can be changed as you change your row height

//This is a private interface
@interface OSUTableView()
//Properties that are contained in here can only be used within this file
@property (nonatomic, strong) NSIndexPath *indexOfAddedCell;
@property CGFloat addedRowHeight;

//Hold references to delegate/datasource passed to us
//We will use calls to this osuDelegate/osuDataSource combo rather than the UITableView delegate/dataSource throughout this class
@property (nonatomic, weak) id <UITableViewDataSource> osuDataSource;
@property (nonatomic, weak) id <UITableViewDelegate> osuDelegate;

//Private Methods
-(void) _customInit;
-(void) _passSelector:(SEL)aSelector to:(id)aReciever;
@end

@implementation OSUTableView
@synthesize osuDataSource = _osuDataSource, osuDelegate = _osuDelegate;
@synthesize indexOfAddedCell = _indexOfAddedCell, addedRowHeight = _addedRowHeight;

//The following two methods are what get written by @synthesize: We are overwritting the setter method so we can save a copy for internal use
-(void) setDelegate:(id<OSUTableViewDelegate>)delegate{
    //Get all delegate messages
    //We forward ones we don't implement with forwardInvocation
    [super setDelegate:self]; //Set delegate as you would would in UITableView
    self.osuDelegate = delegate; //Save a reference for internal use
}
-(void) setDataSource:(id<OSUTableViewDataSource>)dataSource{
    //We connect these up directly because we don't need to intercept any datasource calls
    [super setDataSource:dataSource];
    self.osuDataSource = dataSource; //Might as well store reference to this too for use in this class
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
    //Pass method to delegate if necessary
    [self _passSelector:_cmd to:self.osuDelegate];
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
    
    //Pass method to delegate if necessary
    [self _passSelector:_cmd to:self.osuDelegate];
}
#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(OSUTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //We need to use our custom height if this is the cell we are adding
    if ([indexPath isEqual:self.indexOfAddedCell]) {
        return self.addedRowHeight;
    }
    //Otherwise ask the delegate for a height to use. Optional method
    else if([self.osuDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]){
        return [self.osuDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    else
        return self.rowHeight; //Lastly use our rowHeight property; This is a default in UITableView
}
//This method disables the use of standard editing because we implement our own editing methods
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellAccessoryNone;
}
#pragma mark - UIGestureRecognizer Delegate Methods
//With this method we can stop gestures from functioning when they shouldn't
-(BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    //We can filter gestureRecognizer for any type of gesture we have by its class
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        NSLog(@"Pinching");
    }
    return YES;
}

#pragma mark - UIGestureRecognizer Selectors
//This method will get called very frequently from beginnng..through changes...and after the gesture ends/cancels
-(void) handlePinch:(UIPinchGestureRecognizer*)sender{
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
//This methods gets called any time this object recieves a message it doesn't have a corresponding method for
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
-(void) _passSelector:(SEL)aSelector to:(id)aReciever{
    if ([aReciever respondsToSelector:aSelector]) {
        //The following is to supress a warning you get by using performSelector: with ARC. Comment it out to try for yourself
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [aReciever performSelector:aSelector]; //Forward selector
        #pragma clang diagnostic pop 
    }
}
#pragma mark - Initilize Methods
//This is the init method that Interface Builder uses
-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder]; //Use UITableView Init methods
    if (self) {
        [self _customInit];
    }
    return self;
}
//This is the programatic init method
-(id) initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style]; //Use UITableView Init methods
    if (self) {
        [self _customInit];
    }
    return self;
}
//Now both paths for init will route through this methods...we will use it to add our custom gestures
-(void) _customInit{
    //Add Gesture Recognizers
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [self addGestureRecognizer:pinch];
}
@end
