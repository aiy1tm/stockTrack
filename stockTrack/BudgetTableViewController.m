//
//  BudgetTableViewController.m
//  stockTrack
//
//  Created by Scott Sullivan on 2/29/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import "BudgetTableViewController.h"
#import "BudgetModel.h"
#import "BudgetEntryViewController.h"

@interface BudgetTableViewController ()

@end

@implementation BudgetTableViewController

- (void) viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    self.navigationController.navigationBar.topItem.title = @"Budget";
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
    

}

-(void)updatePositions
{
    
    NSLog(@"update table");
   // [[PositionModel dataHandler] refreshAllPrices];
   // [[PositionModel dataHandler] saveState];
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int rowCount;
    
    if (section==0) {
        rowCount = [BudgetModel dataHandler].expenseList.count;
    }else rowCount = [BudgetModel dataHandler].savingsList.count+1;
    return rowCount;
    // +1 for "add new position".. should be on top or bottom? Bottom for now.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"budgCell" forIndexPath:indexPath];
    
    
    NSString *entryLabel,*typeString;
    NSArray *nameArray;
    
    if (indexPath.section==1) {
        nameArray = [NSArray arrayWithArray:[BudgetModel dataHandler].savingsList];
        typeString = @"Savings";
    }else {
        nameArray = [NSArray arrayWithArray:[BudgetModel dataHandler].expenseList];
        typeString = @"Expense";
        
    }
 
    if (indexPath.row<nameArray.count) {
        entryLabel = [nameArray objectAtIndex:indexPath.row];
        
        NSString *detailText =[NSString stringWithFormat:@"$%.02lf %@", fabs([[BudgetModel dataHandler].budgetDictionary[entryLabel][@"budgetedPennies"] floatValue])/100.0,[BudgetModel dataHandler].budgetDictionary[entryLabel][@"budgetFrequency"]];
        cell.detailTextLabel.text = detailText;
        cell.imageView.image = nil;
        cell.tag = 0;
    }else{
  
        entryLabel = @"New Budget Item...";
        cell.imageView.image = [UIImage imageNamed:@"ic_add_circle_outline"];
        cell.detailTextLabel.text = nil;
        cell.tag = 69; // for detecting editability
        
    }
    cell.textLabel.text = entryLabel;
    
    
    
    return cell;
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
    
        BudgetEntryViewController* destController = segue.destinationViewController;
    
    NSArray *nameArray;
    
    if (indexPath.section==1) {
        nameArray = [NSArray arrayWithArray:[BudgetModel dataHandler].savingsList];
        if (indexPath.row==nameArray.count) {
            // this is the add new savings cell
        }else{
            //pass pre-populate the fields
            NSString *budgName = [nameArray objectAtIndex:indexPath.row];
            NSDictionary *budgetItem = [NSDictionary dictionaryWithDictionary:[BudgetModel dataHandler].budgetDictionary[budgName]];
            destController.budgetAmount = [NSNumber numberWithInt:[budgetItem[@"budgetedPennies"] intValue]];
            destController.entryFrequency = [NSString stringWithString:budgetItem[@"budgetFrequency"]];
            destController.entryName= [NSString stringWithString:budgName];
        }
    }else {
        nameArray = [NSArray arrayWithArray:[BudgetModel dataHandler].expenseList];
        if (indexPath.row==nameArray.count) {
            // this is the add new expense cell
        }else{
            //pass pre-populate the fields
            NSString *budgName = [nameArray objectAtIndex:indexPath.row];
            NSDictionary *budgetItem = [NSDictionary dictionaryWithDictionary:[BudgetModel dataHandler].budgetDictionary[budgName]];
            destController.budgetAmount = [NSNumber numberWithInt:[budgetItem[@"budgetedPennies"] intValue]];
            destController.entryFrequency = [NSString stringWithString:budgetItem[@"budgetFrequency"]];
            destController.entryName= [NSString stringWithString:budgName];
        }
    }
    

    
}

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
 
 }*/



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
        if (indexPath.section == 1) {
            indexKey = [NSString stringWithString:[[[BudgetModel dataHandler] savingsList] objectAtIndex:indexPath.row]];
            [[[BudgetModel dataHandler] savingsList] removeObjectAtIndex:indexPath.row];
        }else{
            indexKey = [NSString stringWithString:[[[BudgetModel dataHandler] expenseList] objectAtIndex:indexPath.row]];
            [[[BudgetModel dataHandler] expenseList] removeObjectAtIndex:indexPath.row];
        }
        
        [[[BudgetModel dataHandler] budgetDictionary] removeObjectForKey:indexKey];
        
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
