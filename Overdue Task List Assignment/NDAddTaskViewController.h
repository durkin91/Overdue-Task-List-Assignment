//
//  NDAddTaskViewController.h
//  Overdue Task List Assignment
//
//  Created by Nikki Durkin on 9/29/14.
//  Copyright (c) 2014 Nikki Durkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDTask.h"

@protocol NDAddTaskViewControllerDelegate <NSObject>

-(void)didAddTask:(NDTask *)task;
-(void)didCancel;

@end

@interface NDAddTaskViewController : UIViewController <UITextViewDelegate>
@property (weak, nonatomic) id <NDAddTaskViewControllerDelegate> delegate;

//IBOutlets
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

//Actions
- (IBAction)cancelButtonPressed:(UIButton *)sender;
- (IBAction)addTaskButtonPressed:(UIButton *)sender;

@end
