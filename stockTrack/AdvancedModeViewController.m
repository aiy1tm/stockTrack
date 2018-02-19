//
//  AdvancedModeViewController.m
//  stockTrack
//
//  Created by Scott Sullivan on 5/21/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import "AdvancedModeViewController.h"
#import "PositionModel.h"

@interface AdvancedModeViewController ()

@end

@implementation AdvancedModeViewController
@synthesize tapRecognizer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Keyboard stuff
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    
    self.navigationController.navigationBarHidden = YES;
    self.topLabel.text = [NSString stringWithFormat:@"Advanced Settings: %@",self.positionName];
    
}



-(void) didTapAnywhere:(UITapGestureRecognizer*)sender
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)returnHome:(id)sender {
    
        [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)scheduleBuys:(id)sender {
}


- (IBAction)tapSetShare:(id)sender {
    [self showEditAlertForBasis:NO];
}

- (IBAction)tapSetBasis:(id)sender {
    [self showEditAlertForBasis:YES];
}

- (void)showEditAlertForBasis: (BOOL) isBasis
{
    NSString *modifyString = @"Modify Share Count";
    if (isBasis) {
        modifyString = @"Modify Cost Basis";
    }
    NSString *basisString = [[PositionModel dataHandler] positionDictionary][self.positionName][@"shareBasisPoints"];
    float basis = [basisString floatValue];
    NSDecimalNumber *shareCount = [NSDecimalNumber decimalNumberWithString:basisString];
    NSString *costString = [[PositionModel dataHandler] positionDictionary][self.positionName][@"costBasisPennies"];
    float cost = [costString floatValue];
     NSDecimalNumber* costBasis = [NSDecimalNumber decimalNumberWithString:costString];
     UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ : %.02f shares at cost $%.02f",self.positionName,basis,cost]
     message:modifyString
     preferredStyle:UIAlertControllerStyleAlert];
     [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
     textField.placeholder = [NSString stringWithFormat:@"%.01f",basis];
         if(isBasis)textField.placeholder = [NSString stringWithFormat:@"%.01f",cost];
     textField.keyboardType = UIKeyboardTypeNumberPad;
         textField.textAlignment = NSTextAlignmentCenter;
     
     
     }];
     
     UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Set Value" style:UIAlertActionStyleDefault
     handler:^(UIAlertAction * action) {
     NSCharacterSet * amountSet = [[NSCharacterSet characterSetWithCharactersInString:@".,0123456789"] invertedSet];
     NSString* amountField = alert.textFields[0].text;
     BOOL shouldUpdate=  ([amountField rangeOfCharacterFromSet:amountSet].location == NSNotFound);
     if (shouldUpdate) {
         if (isBasis) {
              [[PositionModel dataHandler] storePositionInTicker: self.positionName forShareBasisAmount:shareCount andPennyCost:[NSDecimalNumber decimalNumberWithString:amountField]];
         }else{
              [[PositionModel dataHandler] storePositionInTicker: self.positionName forShareBasisAmount: [NSDecimalNumber decimalNumberWithString:amountField] andPennyCost: costBasis];
         }

     }
     }];

    UIAlertAction* deltaAction = [UIAlertAction actionWithTitle:@"Increment Value" style:UIAlertActionStyleDefault
                        handler:^(UIAlertAction * action) {
                            NSCharacterSet * amountSet = [[NSCharacterSet characterSetWithCharactersInString:@"-.,0123456789"] invertedSet];
                                NSString* amountField = alert.textFields[0].text;
                                BOOL shouldUpdate=  ([amountField rangeOfCharacterFromSet:amountSet].location == NSNotFound);
                                if (shouldUpdate) {
                                if (isBasis) {
            [[PositionModel dataHandler] storePositionInTicker: self.positionName forShareBasisAmount:shareCount andPennyCost:[costBasis decimalNumberByAdding: [NSDecimalNumber decimalNumberWithString:amountField]]];
                    }else{
        [[PositionModel dataHandler] storePositionInTicker: self.positionName forShareBasisAmount:[shareCount decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:amountField]] andPennyCost: costBasis];
                                }
                                                                  
                                                              }                                                          }];
    
    UIAlertAction* backAction = [UIAlertAction actionWithTitle:@"Go Back" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                        }];
    [alert addAction:defaultAction];
    [alert addAction:deltaAction];
    [alert addAction:backAction];
    
     [self presentViewController:alert animated:YES completion:nil];
    
    
}
@end
