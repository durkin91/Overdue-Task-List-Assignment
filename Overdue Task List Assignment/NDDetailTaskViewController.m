//
//  NDDetailTaskViewController.m
//  Overdue Task List Assignment
//
//  Created by Nikki Durkin on 9/29/14.
//  Copyright (c) 2014 Nikki Durkin. All rights reserved.
//

#import "NDDetailTaskViewController.h"
#import "ILTranslucentView.h"

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
    
    //setup description text view appearance
    self.taskDescriptionTextView.backgroundColor = [UIColor clearColor];
    self.taskDescriptionTextView.textColor = [UIColor whiteColor];
    
    //setup content
    self.taskTitleLabel.text = self.task.title;
    self.taskDescriptionTextView.text = self.task.description;

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

- (IBAction)editTaskBarButtonPressed:(UIBarButtonItem *)sender {
}

-(IBAction)Btn_back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
