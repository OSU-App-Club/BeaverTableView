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
//This is actually an OSUTableViewDelegate
#pragma mark - UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //Rows get highlighted when selected... deselect after that
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - UITableViewDataSource
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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Index: %i",indexPath.row];

    
    return cell;
}
//We use this method for adding and removing cells from our model based on gestures
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (editingStyle) {
        case UITableViewCellEditingStyleInsert:
            if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:0]]) {
                [self.tableInformation insertObject:[NSString stringWithFormat:@"Object: %d",self.tableInformation.count] atIndex:indexPath.row];
            }
            
            break;
        case UITableViewCellEditingStyleDelete:
            if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:0]]) {
                [self.tableInformation removeObjectAtIndex:indexPath.row];
            }
            break;
        default:
            break;
    }
    
}











@end
