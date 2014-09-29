//
//  NDEditTaskViewController.h
//  Overdue Task List Assignment
//
//  Created by Nikki Durkin on 9/29/14.
//  Copyright (c) 2014 Nikki Durkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NDEditTaskViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *taskTitleTextField;
@property (strong, nonatomic) IBOutlet UITextView *taskDescriptionTextField;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;


- (IBAction)saveTaskButtonPressed:(UIButton *)sender;

@end
