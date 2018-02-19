//
//  BudgetModel.h
//  stockTrack
//
//  Created by Scott Sullivan on 2/28/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BudgetModel : NSObject

+ (instancetype) dataHandler;

@property (nonatomic) NSMutableDictionary* budgetDictionary;
@property (nonatomic) NSMutableArray* expenseList;
@property (nonatomic) NSMutableArray* savingsList;
@property (nonatomic) float SWR;
@property (nonatomic) float expectedGain;

-(void)saveState;
-(void)restoreState;
-(void)clearDefaults;
-(void)addBudgetItem: (NSString*) itemName forPennyAmount: (int) pennyAmount andFrequency: (NSString*) freq;
-(void)addBudgetItem: (NSString*) itemName forDollarAmount: (float) dollarAmount andFrequency: (NSString*) freq;
-(int) monthsToFiForCagr: (float) cagr andNestEgg: (NSDecimalNumber*) nestEgg andSWR: (float) swr;
-(float) totalMonthlySavings;
-(float) totalMonthlyExpenses;
-(double) fiNumber;

@end
