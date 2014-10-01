//
//  NDDetailTaskViewController.h
//  Overdue Task List Assignment
//
//  Created by Nikki Durkin on 9/29/14.
//  Copyright (c) 2014 Nikki Durkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDTask.h"
#import "NDEditTaskViewController.h"


@protocol NDDetailTaskVCDelegate <NSObject>

-(void)saveTask:(NDTask *)task atIndexPath:(NSIndexPath *)indexPath;
-(void)didChangeCompletionStatus:(UIButton *)button withLabel:(UILabel *)label atIndexPath:(NSIndexPath *)indexPath;

@end

@interface NDDetailTaskViewController : UIViewController <NDEditTaskViewControllerDelegate>

@property (weak, nonatomic) id <NDDetailTaskVCDelegate> delegate;

@property (strong, nonatomic) NDTask *task;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) IBOutlet UILabel *taskTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *taskDueDateLabel;
@property (strong, nonatomic) IBOutlet UITextView *taskDescriptionTextView;
@property (strong, nonatomic) IBOutlet UIButton *checkmarkButton;


- (IBAction)checkmarkButtonPressed:(UIButton *)sender;
- (IBAction)editTaskBarButtonPressed:(UIBarButtonItem *)sender;

@end
