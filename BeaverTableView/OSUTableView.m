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
@property CGPoint upperPointOfPinch;

//Hold private references to delegate/datasource passed to us
//We will use calls to this osuDelegate/osuDataSource combo rather than the UITableView delegate/dataSource throughout this class
@property (nonatomic, assign) id <UITableViewDataSource> osuDataSource;
@property (nonatomic, assign) id <UITableViewDelegate> osuDelegate;

//Private Methods
-(void) _customInit;
-(void) _passSelector:(SEL)aSelector to:(id)aReciever;
-(void) _commitDisgardCell;
@end

@implementation OSUTableView
@synthesize osuDataSource = _osuDataSource, osuDelegate = _osuDelegate, state = _state;
@synthesize indexOfAddedCell = _indexOfAddedCell, addedRowHeight = _addedRowHeight, upperPointOfPinch = _upperPointOfPinch;

//The following two methods are what get written by @synthesize: We are overwritting the setter method so we can save a copy for internal use
-(void) setDelegate:(id<OSUTableViewDelegate>)delegate{
    //Get all delegate messages
    //We forward ones we don't implement with forwardInvocation
    self.osuDelegate = delegate; //Save a reference for internal use..must set this first because the next line will trigger action
    [super setDelegate:self]; //Set delegate as you would would in UITableView
}
-(void) setDataSource:(id<OSUTableViewDataSource>)dataSource{
    //We connect these up directly because we don't need to intercept any datasource calls
    self.osuDataSource = dataSource; //Might as well store reference to this too for use in this class
    [super setDataSource:dataSource];
}
#pragma mark - UIScrollViewDelegate
//This works because uitableview inherits from uiscrollview
-(void) scrollViewDidScroll:(UIScrollView *)scrollView{    
    // Check if addingIndexPath doesn't exist and we are scrolling down from top
    if (scrollView.contentOffset.y<0 && self.indexOfAddedCell == nil && !scrollView.isDecelerating) {
        //Set state
        self.state = OSUTableViewStateDragging;
    
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
    //Only do something here if DRAGGING
    else if (self.indexOfAddedCell && self.state == OSUTableViewStateDragging){
        // alter the contentOffset of our scrollView
        self.addedRowHeight += scrollView.contentOffset.y * -1;
        self.addedRowHeight = MAX(1,MIN(self.rowHeight, self.addedRowHeight)); //Make sure the row doesnt get bigger or smaller than it should 1<addedRowHeight<rowHeight
        [self reloadData];
    }
    //Pass method to delegate if necessary
    [self _passSelector:_cmd to:self.osuDelegate];
}
//This is called when we lift our finger off the tableView
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //Add cell if has been fully created
    [self _commitDisgardCell];
    
    //Change our state
    self.state = OSUTableViewStateNone;
    
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
    //Check if for failing condition
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled || sender.numberOfTouches < 2) {
        //Commit/disgard cell if index has been added
        if (self.indexOfAddedCell) {
            //Add/Disgard Cell
            [self _commitDisgardCell];
        }
        //Reset contentInset
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        //Reset State
        self.state = OSUTableViewStateNone;
        return;
    }
    //Extract touch points from gesture relative to self
    CGPoint touch1 = [sender locationOfTouch:0 inView:self];
    CGPoint touch2 = [sender locationOfTouch:1 inView:self];
    //Determine Upper Point
    CGPoint currentUpperPoint = touch1.y < touch2.y ? touch1 : touch2;
    
    //Get Y Height
    CGFloat height = fabsf(touch2.y - touch1.y);
    //Determine change in height since last time
    CGFloat heightDelta = height - (height/(sender.scale)); //The change from the inital pinch pinch location; Pinch scale goes from 1 to larger as you pinch open->thus height delta goes from 0 to larger but at a faster rate
    
    //Switch on state of gesture recongnizer
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            //Determine Index Path by making rect with points
            NSArray *indexPaths = [self indexPathsForRowsInRect:CGRectMake(touch1.x, touch1.y,self.bounds.size.width,fabsf(touch2.y - touch1.y))];
            if (indexPaths.count < 1)
                return; //Not pinching on valid cell
            
            //Set State
            self.state = OSUTableViewStatePinching;
            
            //Find the correct index between fingers and set to added index
            NSIndexPath *firstIndexPath = [indexPaths objectAtIndex:0];
            NSIndexPath *lastIndexPath  = [indexPaths lastObject];
            NSInteger    midIndex = ((float)(firstIndexPath.row + lastIndexPath.row) / 2) + 0.5;
            self.indexOfAddedCell = [NSIndexPath indexPathForRow:midIndex inSection:firstIndexPath.section];

            //Save Reference to upper point
            self.upperPointOfPinch = currentUpperPoint;
                        
            // Creating contentInset to fulfill the whole screen, so our tableview won't occasionaly
            // bounds back to the top while we don't have enough cells on the screen
            self.contentInset = UIEdgeInsetsMake(self.frame.size.height, 0, self.frame.size.height, 0);
            
            //Start making updates
            [self beginUpdates];
            //Create new cell in data source
            [self.osuDataSource tableView:self commitEditingStyle:UITableViewCellEditingStyleInsert forRowAtIndexPath:self.indexOfAddedCell];
            //Insert new cell with animation
            [self insertRowsAtIndexPaths:[NSArray arrayWithObject:self.indexOfAddedCell] withRowAnimation:UITableViewRowAnimationMiddle];
            //End update...this is when this whole block executes
            [self endUpdates];
            break;
        }
        case UIGestureRecognizerStateChanged:
            //If self.addedRowHeight - height delta is greater than 1...set height
            if (self.addedRowHeight - heightDelta >= 1 || self.addedRowHeight - heightDelta <= -1) {
                //MAX of heightdelta and 1
                self.addedRowHeight = MAX(heightDelta, 1);
                //Reload data so new height gets added
                [self reloadData];
            }
            // Scrolls tableview according to the upper touch point to mimic a realistic
            // dragging gesture
            //CGFloat diffOffsetY = self.upperPointOfPinch.y - currentUpperPoint.y;
            //self.contentOffset = CGPointMake(self.contentOffset.x,self.contentOffset.y+diffOffsetY);

        default:
            break;
    }
}
#pragma mark - Utility
-(void) _commitDisgardCell{
    if ([self cellForRowAtIndexPath:self.indexOfAddedCell].bounds.size.height >= self.rowHeight) {
        //Keep cell but update cells
        [self beginUpdates];
        [self reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.indexOfAddedCell] withRowAnimation:UITableViewRowAnimationNone];
        self.indexOfAddedCell = nil;
        self.addedRowHeight = 0;
        [self endUpdates];
    }
    else if(self.indexOfAddedCell){
        //Discard cell
        [self beginUpdates];
        //Delete from our model
        [self.dataSource tableView:self commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:self.indexOfAddedCell];
        //Remove from table view
        [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.indexOfAddedCell] withRowAnimation:UITableViewRowAnimationNone];
        
        //No longer need to store added cell
        self.indexOfAddedCell = nil;
        self.addedRowHeight = 0;
        [self endUpdates]; //Animation happends here
    }
}


#pragma mark - Methods Forwarding
//These three methods are allow us to be our own delegate without taking away delegate calls for our osuDelegate
-(BOOL)respondsToSelector:(SEL)aSelector{
    //This makes sure that all delegate methods are supported by the osuDelegate are supported by us through message forwarding
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    else{
        NSLog(@"Selector(%@): %@",self.osuDelegate,NSStringFromSelector(aSelector));
        return [self.osuDelegate respondsToSelector:aSelector];
    }
}
//This methods gets called any time this object recieves a message it doesn't have a corresponding method for
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"Forward: %@",NSStringFromSelector(anInvocation.selector));
    if ([self.osuDelegate respondsToSelector:[anInvocation selector]])
        [anInvocation invokeWithTarget:self.osuDelegate];
    else
        [super forwardInvocation:anInvocation];
}
- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        return [[self.osuDelegate class] methodSignatureForSelector:selector];
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
    //Add Gesture Recognizers to current view
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    //Set self as delegate to recieve gesture calls
    pinch.delegate = self;
    [self addGestureRecognizer:pinch];
}
@end
