//
//  AllocationTableViewController.m
//  
//
//  Created by Scott Sullivan on 5/6/16.
//
//

#import "AllocationTableViewController.h"
#import "AllocSelectorTableViewController.h"

@interface AllocationTableViewController ()

@end

@implementation AllocationTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
   
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
    if(editing)
    {
        NSLog(@"editMode on");
    }
    else
    {
        NSLog(@"Done leave editmode");
    }
    
    [super setEditing:editing animated:animate];
    
}


- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"Asset Allocation";
  //   self.parentViewController.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationController.navigationBarHidden = NO;
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
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

    return [[[[PositionModel dataHandler] assetTypeDictionary] allKeys] count]+2;
}

- (void) settingsTapped: (id) sender
{
       NSArray *allKeys = [[[[PositionModel dataHandler] assetTypeDictionary] allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    UIButton *buttonPressed = (UIButton*) sender;
  //  NSLog(@"%d",buttonPressed.tag);
    float touchedAlloc;
    float targetedAlloc;
    NSString *touchedTicker;
    //show UIAlertController with option to set target percentage, or edit constituents.
    if (buttonPressed.tag<allKeys.count) {
        touchedTicker =[allKeys objectAtIndex:buttonPressed.tag];
        touchedAlloc = [[[PositionModel dataHandler] assetTypeDictionary][touchedTicker][@"actualAlloc"] floatValue];
        targetedAlloc = [[[PositionModel dataHandler] assetTypeDictionary][touchedTicker][@"targetAlloc"] floatValue];
    }

    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ : Currently %.01f%% of Portfolio",touchedTicker,touchedAlloc]
                                                                   message:@"Edit target allocation percentage:"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.textAlignment = NSTextAlignmentCenter;
        textField.placeholder = [NSString stringWithFormat:@"%.01f",targetedAlloc];
        textField.keyboardType = UIKeyboardTypeNumberPad;}];
   
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              NSCharacterSet * amountSet = [[NSCharacterSet characterSetWithCharactersInString:@".,0123456789"] invertedSet];
                                                              NSString* amountField = alert.textFields[0].text;
                                                              NSLog(@" amount field %@",amountField);
                                                           
                                                              BOOL shouldUpdate=  ([amountField rangeOfCharacterFromSet:amountSet].location == NSNotFound);
                                                              if (shouldUpdate&&![amountField isEqualToString:@""]) {
                                                            
                                                                  [[[PositionModel dataHandler] assetTypeDictionary][touchedTicker] setObject:[NSNumber numberWithFloat:[amountField floatValue]] forKey:@"targetAlloc"];
                                                              }else{
#warning implement an error for ridiculous inputs here.
                                                              }
                                                          }];
    [alert addAction:defaultAction];

    [self presentViewController:alert animated:YES completion:^(){}];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"allocCell" forIndexPath:indexPath];
    
   NSArray *allKeys = [[[[PositionModel dataHandler] assetTypeDictionary] allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    
    // Configure the cell..
    if (indexPath.row==[allKeys count]) {
        // the unallocated stuff
        cell.textLabel.text = @"Unspecified";
        cell.imageView.image = nil;

        __block NSMutableArray *unspecifiedPositions = [NSMutableArray arrayWithCapacity:3];
        
        [[[PositionModel dataHandler] positionDictionary] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
           // NSLog(@"%@->%@",key,obj);
            if ([obj[@"allocType"] isEqualToString:@"None"]) {
              //  NSLog(@"position in %@ is not specified",key);
                [unspecifiedPositions addObject:key];
            }
        }];
        cell.detailTextLabel.text = [unspecifiedPositions componentsJoinedByString:@", "];
    }else{
        if (indexPath.row==[allKeys count]+1) {
            cell.textLabel.text = @"Add new allocation category";
            cell.imageView.image = [UIImage imageNamed:@"ic_add_circle_outline"];
            cell.detailTextLabel.text = nil;
        }else{
    NSString* keyLabel = [allKeys objectAtIndex:indexPath.row];
    cell.textLabel.text = keyLabel;
            __block NSMutableArray *unspecifiedPositions = [NSMutableArray arrayWithCapacity:3];
            
            [[[PositionModel dataHandler] positionDictionary] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
               // NSLog(@"%@->%@",key,obj);
                if ([obj[@"allocType"] isEqualToString:keyLabel]) {
                 //   NSLog(@"position in %@ is not specified",key);
                    [unspecifiedPositions addObject:key];
                }
            }];
            cell.detailTextLabel.text = [unspecifiedPositions componentsJoinedByString:@", "];
            UIButton *settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 36, 36)];
            [settingsButton addTarget:self action:@selector(settingsTapped:) forControlEvents:UIControlEventTouchUpInside];
            settingsButton.tag = indexPath.row;
            [settingsButton setImage:[UIImage imageNamed:@"ic_settings_36pt"] forState:UIControlStateNormal];
            cell.accessoryView = settingsButton;
            cell.imageView.image = nil;
            
             }
    }
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    
    NSArray *allKeys = [[[[PositionModel dataHandler] assetTypeDictionary] allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    
    if (indexPath.row<[allKeys count]){
        return YES;}
    else{return NO;}
}


#warning need to add editing/insertion

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        NSArray *allKeys = [[[[PositionModel dataHandler] assetTypeDictionary] allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
        
        NSString* keyLabel = [allKeys objectAtIndex:indexPath.row];
        
        for (NSString* ticker in [[PositionModel dataHandler] tickerList]) {
            NSString *positionsAlloc = [[PositionModel dataHandler] positionDictionary][ticker][@"allocType"];
            
            
            if ([positionsAlloc isEqualToString:keyLabel]) {
                
                [[PositionModel dataHandler] positionIn:ticker shouldChangeAllocToType:@"None"];
            }
        }
        
        [[[PositionModel dataHandler] assetTypeDictionary] removeObjectForKey:keyLabel];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     NSArray *allKeys = [[[[PositionModel dataHandler] assetTypeDictionary] allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    if (indexPath.row==[allKeys count]+1) {
    
    
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"New Asset Class"
                                                                   message:@"New Asset Class Name:"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.textAlignment = NSTextAlignmentCenter;
        textField.placeholder = @"Asset Class";
        textField.keyboardType = UIKeyboardTypeDefault;}];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                            
                                                              NSString* amountField = alert.textFields[0].text;
                                                              
                                                              BOOL tagNotUsed = YES;
                                                              for (NSString *assetString in allKeys) {
                                                                  if ([amountField isEqualToString:assetString]) {
                                                                      tagNotUsed=NO;
                                                                  }
                                                              }
                                                            
                                                              if (tagNotUsed) {
                                                                  [[[PositionModel dataHandler] assetTypeDictionary] addEntriesFromDictionary:@{amountField : @{@"targetAlloc":@0,@"actualAlloc":@0}}];
                                                                  [[PositionModel dataHandler] updateAllocations];
                                                                  [self.tableView reloadData];
                                                              }else{
#warning implement an error for conflicting input here
                                                              }
                                                          }];
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:^(){}];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    AllocSelectorTableViewController * destCont = segue.destinationViewController;
    
    destCont.typeString = @"None";
  
    NSArray *allKeys = [[[[PositionModel dataHandler] assetTypeDictionary] allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    if(indexPath.row<allKeys.count){
    
    destCont.typeString = [allKeys objectAtIndex:indexPath.row];
    }

    
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
     NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if (indexPath.row<=[[[PositionModel dataHandler] assetTypeDictionary] allKeys].count) {
        return YES;
    }
    return NO;
}


@end
