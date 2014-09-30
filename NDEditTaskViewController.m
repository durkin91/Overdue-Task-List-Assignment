//
//  NDEditTaskViewController.m
//  Overdue Task List Assignment
//
//  Created by Nikki Durkin on 9/29/14.
//  Copyright (c) 2014 Nikki Durkin. All rights reserved.
//

#import "NDEditTaskViewController.h"

@interface NDEditTaskViewController ()

@end

@implementation NDEditTaskViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set delegates
    [self.descriptionTextField setDelegate:self];
    
    //load in existing task's information
    self.titleTextField.text = self.task.title;
    self.descriptionTextField.text = self.task.description;
    self.datePicker.date = self.task.dueDate;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelButtonPressed:(UIButton *)sender
{
    [self.delegate didCancel];
}

- (IBAction)saveTaskButtonPressed:(UIButton *)sender
{
    self.task.title = self.titleTextField.text;
    self.task.description = self.descriptionTextField.text;
    self.task.dueDate = self.datePicker.date;
    
    [self.delegate didEditTask:self.task];
}



-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self.descriptionTextField resignFirstResponder];
        return NO;
    }
    else return YES;
}

@end
