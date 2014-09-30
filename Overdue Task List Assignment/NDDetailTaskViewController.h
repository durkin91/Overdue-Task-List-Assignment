//
//  NDDetailTaskViewController.h
//  Overdue Task List Assignment
//
//  Created by Nikki Durkin on 9/29/14.
//  Copyright (c) 2014 Nikki Durkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDTask.h"

@interface NDDetailTaskViewController : UIViewController
@property (strong, nonatomic) NDTask *task;
@property (strong, nonatomic) IBOutlet UILabel *taskTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *taskDueDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *taskDescriptionLabel;


- (IBAction)editTaskBarButtonPressed:(UIBarButtonItem *)sender;

@end
