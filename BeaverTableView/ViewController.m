//
//  ViewController.m
//  BeaverTableView
//
//  Created by Chris Vanderschuere on 11/2/12.
//  Copyright (c) 2012 OSU iOS App Club. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize tableView = _tableView;
@synthesize tableInformation = _tableInformation;

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
//This is a delegate method that gets called everytime a cell is redrawn...we can use this to change the background color by index

    //This is an arbritray constant...play with it to your liking
    //CGFloat hueOffset = 0.12 * indexPath.row / [self tableView:self.tableView numberOfRowsInSection:indexPath.section];
    
    
    //CGFloat hue, saturation, brightness, alpha;
    //Get properties of our base color (Color at top)

        // We wants the hue value to be between 0 - 1 after appending the offset..we can use % to get remainder
    
        //Create new color with this new hue and the same properties as before
    
        //Set new background color for cell...content view is the main cell view

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
    cell.textLabel.text = [self.tableInformation objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Index: %i",indexPath.row];

    
    return cell;
}

//We use this method for adding and removing cells from our model based on gestures
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (editingStyle) {
        case UITableViewCellEditingStyleInsert:
                [self.tableInformation insertObject:[NSString stringWithFormat:@"Object: %d",self.tableInformation.count] atIndex:indexPath.row];            
            break;
        case UITableViewCellEditingStyleDelete:
                [self.tableInformation removeObjectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    
}










@end
