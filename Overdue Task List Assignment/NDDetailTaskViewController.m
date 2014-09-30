//
//  NDDetailTaskViewController.m
//  Overdue Task List Assignment
//
//  Created by Nikki Durkin on 9/29/14.
//  Copyright (c) 2014 Nikki Durkin. All rights reserved.
//

#import "NDDetailTaskViewController.h"
#import "ILTranslucentView.h"
#import "NDEditTaskViewController.h"

@interface NDDetailTaskViewController ()

@end

@implementation NDDetailTaskViewController

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
    
    //setup background
    self.view.layer.contents = (id)[UIImage imageNamed:@"BlurredBackgroundImage"].CGImage;
    
    //setup nav bar
    UIImage* backButtonArrow = [UIImage imageNamed:@"BackArrowIcon"];
    CGRect backframe = CGRectMake(250, 9, 30, 13);
    UIButton *backbutton = [[UIButton alloc] initWithFrame:backframe];
    [backbutton setBackgroundImage:backButtonArrow forState:UIControlStateNormal];
    [backbutton addTarget:self action:@selector(Btn_back:)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backbarbutton =[[UIBarButtonItem alloc] initWithCustomView:backbutton];
    self.navigationItem.leftBarButtonItem = backbarbutton;
    //[backbutton release];
    
    //Update labels, formatting, etc
    [self updateLabelsWithCurrentTask];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]] && [segue.destinationViewController isKindOfClass:[NDEditTaskViewController class]]) {
        NDEditTaskViewController *editTaskVC = segue.destinationViewController;
        editTaskVC.task = self.task;
        editTaskVC.delegate = self;
    }
}

#pragma Helper Methods

-(void)updateLabelsWithCurrentTask
{
    //setup content
    self.taskTitleLabel.text = self.task.title;
    self.taskDescriptionTextView.text = self.task.description;
    
    //setup description text view appearance
    self.taskDescriptionTextView.backgroundColor = [UIColor clearColor];
    self.taskDescriptionTextView.textColor = [UIColor whiteColor];
    
    //setup due date
    if (self.task.completed == YES) {
        self.taskDueDateLabel.textColor = [UIColor whiteColor];
        self.taskDueDateLabel.text = @"COMPLETED";
    }
    else {
        self.taskDueDateLabel.text = [self.task convertDateIntoDueDateFormat];
        self.taskDueDateLabel.textColor = [self.task colorForDueDateString];
    }
}

#pragma NDEditTaskVC Delegate Methods

-(void)didCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didEditTask:(NDTask *)task
{
    //save the edited task to this VC's task property, but delegate the saving to NSUserDefaults to the delegate.
    self.task = task;
    [self.delegate saveTask:task atIndexPath:self.indexPath];
    
    [self updateLabelsWithCurrentTask];
    [self dismissViewControllerAnimated:YES completion:nil];
    
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

#pragma Actions on current VC

- (IBAction)editTaskBarButtonPressed:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"toEditTaskVC" sender:sender];
}

-(IBAction)Btn_back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
