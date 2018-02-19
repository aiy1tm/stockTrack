//
//  PositionTableViewController.m
//  stockTrack
//
//  Created by Scott Sullivan on 2/7/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import "PositionTableViewController.h"
#import "PositionEditorViewController.h"
#import "PositionModel.h"

@interface PositionTableViewController ()

@end

@implementation PositionTableViewController

- (void) viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    self.navigationController.navigationBar.topItem.title = @"Investments";
    [PositionModel dataHandler].delegate = self;
    [super viewWillAppear:animated];

}

- (void) viewWillDisappear:(BOOL)animated
{
    [PositionModel dataHandler].delegate = nil;
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(updatePositions)
                  forControlEvents:UIControlEventValueChanged];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) pingForUpdate
{
    [self.tableView reloadData];
}
-(void) pingForFailedTicker
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:@"Data unavailable. Check your connectivity and ticker symbol. Current database only supports 3,000 US publically-traded companies."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)updatePositions
{

    NSLog(@"update positions for table");
    [[PositionModel dataHandler] refreshAllPrices];
    [[PositionModel dataHandler] saveState];
    [self.tableView reloadData];

    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [[PositionModel dataHandler] positionDictionary].count+1;
    // +1 for "add new position".. should be on top or bottom? Bottom for now.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"posCell" forIndexPath:indexPath];
    
    NSString *tickLabel;
    if (indexPath.row<[[PositionModel dataHandler] positionDictionary].count) {
        tickLabel = [[[PositionModel dataHandler] tickerList] objectAtIndex:indexPath.row];
        double shareCount = [[PositionModel dataHandler].positionDictionary[tickLabel][@"shareBasisPoints"] doubleValue];
        double sharePrice = [[PositionModel dataHandler].positionDictionary[tickLabel][@"latestPrice"] doubleValue];
        double totalValue = sharePrice*shareCount;
        double costValue = [[PositionModel dataHandler].positionDictionary[tickLabel][@"costBasisPennies"] doubleValue];
        float performanceRatio = totalValue/costValue;
        NSString *detailText =[NSString stringWithFormat:@"%.02lf @ $%.02lf ($%.lf) [Cost $%.lf]",shareCount,sharePrice,totalValue,costValue];
        
        
       
            cell.detailTextLabel.text = detailText;
            if (performanceRatio>1) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ [+%.02lf %%]",tickLabel,-100*(1-totalValue/costValue)];
            }else{
                cell.textLabel.text = [NSString stringWithFormat:@"%@ [%.02lf %%]",tickLabel,-100*(1-totalValue/costValue)];
            }
           
        cell.imageView.image = nil;
        cell.tag = 0;
        
    }else{
        tickLabel = @"Add New Position";
        cell.imageView.image = [UIImage imageNamed:@"ic_add_circle_outline"];
        cell.detailTextLabel.text = @"";
        cell.textLabel.text = tickLabel;
        cell.tag = 69; // for (non-)editability
    }

   

    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  //  NSLog(@"touched row: %d",indexPath.row);
    
    [self performSegueWithIdentifier:@"showPositionEditor" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
  
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    PositionEditorViewController* destController = segue.destinationViewController;
    if(indexPath.row==[[PositionModel dataHandler] tickerList].count){
        destController.isNewPosition = YES;
    }else{
        destController.positionName = [[[PositionModel dataHandler] tickerList] objectAtIndex:indexPath.row];
    }
        
    
    
}



/*-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
   
    NSLog(@" accessory button tapped");
}*/

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    BOOL rowIsEditable = YES;
    
    if ([tableView cellForRowAtIndexPath:indexPath].tag == 69) {
        rowIsEditable = NO;
    }
    
    return rowIsEditable;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString *indexKey;
        indexKey = [NSString stringWithString:[[[PositionModel dataHandler] tickerList] objectAtIndex:indexPath.row]];
        [[[PositionModel dataHandler] positionDictionary] removeObjectForKey:indexKey];
        [[[PositionModel dataHandler] tickerList] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

@end
