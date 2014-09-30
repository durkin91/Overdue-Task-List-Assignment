//
//  NDEditTaskViewController.h
//  Overdue Task List Assignment
//
//  Created by Nikki Durkin on 9/29/14.
//  Copyright (c) 2014 Nikki Durkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NDTask.h"

@protocol NDEditTaskViewControllerDelegate <NSObject>

@required
-(void)didCancel;
-(void)didEditTask:(NDTask *)task;

@end

@interface NDEditTaskViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) id <NDEditTaskViewControllerDelegate> delegate;
@property (strong, nonatomic) NDTask *task;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;


- (IBAction)cancelButtonPressed:(UIButton *)sender;
- (IBAction)saveTaskButtonPressed:(UIButton *)sender;


@end
