//
//  NDViewController.h
//  Overdue Task List Assignment
//
//  Created by Nikki Durkin on 9/28/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDAddTaskViewController.h"
#import "NDDetailTaskViewController.h"

@interface NDViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NDAddTaskViewControllerDelegate, NDDetailTaskVCDelegate>

@property (strong, nonatomic) NSMutableArray *tasks;
@property (strong, nonatomic) NSMutableArray *completedTasks;
@property (strong, nonatomic) NSMutableArray *overdueTasks;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)reorderTaskBarButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)addTaskBarButtonPressed:(UIBarButtonItem *)sender;
-(void)clearTasksButtonPressed:(UIButton *)sender;

@end
