//
//  ViewController.m
//  BeaverTableView
//
//  Created by Chris Vanderschuere on 11/2/12.
//  Copyright (c) 2012 OSU iOS App Club. All rights reserved.
//

#import "ViewController.h"

#define PULL_HEIGHT 60

@interface ViewController ()

@property (nonatomic, strong) NSIndexPath *indexOfAddedCell;
@property CGFloat addedRowHeight;

@end

@implementation ViewController
@synthesize tableView = _tableView;
@synthesize tableInformation = _tableInformation;
@synthesize indexOfAddedCell = _indexOfAddedCell;
@synthesize addedRowHeight = _addedRowHeight;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Prepare Model
    self.tableInformation = [NSMutableArray arrayWithObjects:@"Test", @"Example",@"Experiment",@"Done", nil];
    [self.tableView reloadData]; //Forces table view to make itself
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIScrollViewDelegate
//This works because uitableview inherits from uiscrollview
-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    // Check if addingIndexPath not exists, we don't want to
    if (scrollView.contentOffset.y<0 && self.indexOfAddedCell == nil) {
        //Add new cell to datasource
        [self.tableView beginUpdates];
        //Add a new object to our model
        [self.tableInformation insertObject:[NSString stringWithFormat:@"Object: %d",self.tableInformation.count] atIndex:0];
        //Told table view to update at specific row
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        //Save indexpath and row height for later use
        self.indexOfAddedCell = [NSIndexPath indexPathForRow:0 inSection:0];
        self.addedRowHeight = fabsf(scrollView.contentOffset.y); //Floating absolute value
        
        [self.tableView endUpdates]; //All animations happen here
    }
    else if (self.indexOfAddedCell){
        // alter the contentOffset of our scrollView
        self.addedRowHeight += scrollView.contentOffset.y * -1;
        [self.tableView reloadData];
        [scrollView setContentOffset:CGPointZero];
    }
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //When we lift our finger...we want to check whether we should add the cell or not
    if (scrollView.contentOffset.y <= PULL_HEIGHT*-1) {
        //Keep cell but update cells
        self.indexOfAddedCell = nil;
        self.addedRowHeight = 0;
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if(self.indexOfAddedCell){
        //Discard cell
        [self.tableView beginUpdates];
        //Delete from our model
        [self.tableInformation removeObjectAtIndex:0];
        //Remove from table view
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.indexOfAddedCell] withRowAnimation:UITableViewRowAnimationNone];
        
        //No longer need to store added cell
        self.indexOfAddedCell = nil;
        self.addedRowHeight = 0;
        
        [self.tableView endUpdates]; //Animation happends here
    }
    

}
#pragma mark - UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //Rows get highlighted when selected... deselect after that
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath isEqual:self.indexOfAddedCell]) {
        return self.addedRowHeight;
    }
    
    return 60;
}

#pragma mark - UITableViewDataSource
//Methods/Function
/*
-(RETURN-TYPE) fuctionName:(Type Of Paramater) nameOfParamater{
 }

 
 */
//Object
//NS,UI are object types generally- need * after them

//Properties
/*
 dot notation
 
 object.propertyName (This gets the value for property propertyName in object)
 
 */

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableInformation.count; //Fix this when we have a model
}
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"rightDetailCell"];
    
    //Modify cell according to our model
    
    //Example 1
    //cell.textLabel.text = [NSString stringWithFormat:@"Section: %i",indexPath.section];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"Index: %i",indexPath.row];
    
    //Example 2
    cell.textLabel.text = [self.tableInformation objectAtIndex:indexPath.row];
    
    
    return cell;
}












@end
