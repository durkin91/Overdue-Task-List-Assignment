//
//  NDViewController.m
//  Overdue Task List Assignment
//
//  Created by Nikki Durkin on 9/28/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "NDViewController.h"
#import "NDAddTaskViewController.h"
#import <Accelerate/Accelerate.h>
#import "ILTranslucentView.h"
#import "NDDetailTaskViewController.h"

@interface NDViewController ()

@end

@implementation NDViewController
#define ADDED_TASKS_KEY @"Added Tasks Array"

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Make the navigation bar transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    //setup background image
    self.view.layer.contents = (id)[UIImage imageNamed:@"BackgroundPhoto.png"].CGImage;
    
    //Setup navigation bar with Avenir Next Regular font and white title color
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"AvenirNext-Regular" size:17], NSFontAttributeName, nil]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    
    //retrieve the array of task property lists, and turn them into task objects and save them in the tasks array property.
    NSArray *tasksAsPropertyLists = [[NSUserDefaults standardUserDefaults] objectForKey:ADDED_TASKS_KEY];
    for (NSDictionary *dictionary in tasksAsPropertyLists) {
        NDTask *task = [[NDTask alloc] initWithData:dictionary];
        [self.tasks addObject:task];
    }
    
    //set tableview datasource and delegate equal to self, and remove seperators from empty cells
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        if ([segue.destinationViewController isKindOfClass:[NDAddTaskViewController class]]) {
            NDAddTaskViewController *addTaskVC = segue.destinationViewController;
            addTaskVC.delegate = self;
        }
    }
    if ([sender isKindOfClass:[NSIndexPath class]]) {
        if ([segue.destinationViewController isKindOfClass:[NDDetailTaskViewController class]]) {
            NDDetailTaskViewController *detailTaskVC = segue.destinationViewController;
            NSIndexPath *indexPath = sender;
            detailTaskVC.task = [self.tasks objectAtIndex:indexPath.row];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Add Task VC Delegate Methods
-(void)didAddTask:(NDTask *)task;
{
    //perform lazy instantiation on self.tasks, then add the new task to that array. Create a tasksAsPropertyList variable that holds the array retrieved from NSUserDefaults, and if no such array exists then alloc one. Then add the task's property list to that array. Then put the array back into NSUserDefaults and save it. Dismiss the modal and reload the tableview data.
    [self.tasks addObject:task];
    NSMutableArray *tasksAsPropertyLists = [[[NSUserDefaults standardUserDefaults] arrayForKey:ADDED_TASKS_KEY] mutableCopy];
    if (!tasksAsPropertyLists) tasksAsPropertyLists = [[NSMutableArray alloc] init];
    [tasksAsPropertyLists addObject:[self taskAsPropertyList:task]];
    [[NSUserDefaults standardUserDefaults] setObject:tasksAsPropertyLists forKey:ADDED_TASKS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
    
}

-(void)didCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tasks count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"taskCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    //Configure the cell
    NDTask *task = [self.tasks objectAtIndex:indexPath.row];
    cell.textLabel.text = task.title;
    cell.detailTextLabel.text = [self convertDateIntoDueDateFormat:task.dueDate];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //making the cell background clear
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    
    
    
//    NDTask *task = [self.tasks objectAtIndex:indexPath.row];
//    if (task.completed == NO) {
//        <#statements#>
//    }
   
    
    //Add the completed? button
    UIImage *uncompletedTask = [UIImage imageNamed:@"UncompletedTaskIcon"];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:uncompletedTask forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;
    //[button addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    
    //Make the cell translucent
    ILTranslucentView *translucentView = [[ILTranslucentView alloc] initWithFrame:cell.frame];
    translucentView.alpha = .95;
    [cell setBackgroundView:translucentView];
    
}

#pragma Table View Delegate methods

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toDetailVC" sender:indexPath];
    return indexPath;
    
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //Find the appropriate task in the tasks array. If it is not completed, then set it to completed. If it is completed then set it to not completed.
    NDTask *task = [self.tasks objectAtIndex:indexPath.row];
    if (!task.completed) task.completed = YES;
    else task.completed = NO;
    
    
    //Save the updated data to NSUserdefaults. There may be a more efficient way of doing this by just changing the one object, and not the whole array??? Then reload the tableview
    NSMutableArray *newUpdatedTasks = [[NSMutableArray alloc] init];
    for (NDTask *task in self.tasks) {
        [newUpdatedTasks addObject:[self taskAsPropertyList:task]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:newUpdatedTasks forKey:ADDED_TASKS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
}

#pragma helper methods

//lazy instantiation for task array
-(NSMutableArray *)tasks
{
    if (!_tasks) {
        _tasks = [[NSMutableArray alloc] init];
    }
    return _tasks;
}

//turn the task object into a dictionary of property lists
-(NSDictionary *)taskAsPropertyList:(NDTask *)task
{
    NSDictionary *taskPropertyList =
                    @{TITLE : task.title,
                      DESCRIPTION : task.description,
                      DUE_DATE : task.dueDate,
                      COMPLETION : @(task.completed) };
    return taskPropertyList;
}



#pragma Other Methods

//turn NSdate into a string that can be displayed in the cell
-(NSString *)convertDateIntoDueDateFormat:(NSDate *)date
{
    int timeInterval = [date timeIntervalSinceNow];
    int daysLeft = floor((double)timeInterval / 86400);
    int hoursLeft = (timeInterval % 86400) / 3600;
    
    NSString *dueIn;
    if (timeInterval <= 0) {
        dueIn = [NSString stringWithFormat:@"Due in %id %ih", abs(daysLeft), abs(hoursLeft)];
    }
    else dueIn = @"OVERDUE";
    
    return dueIn;
}



#pragma Actions

- (IBAction)reorderTaskBarButtonPressed:(UIBarButtonItem *)sender
{
    //reorder tasks action
}

- (IBAction)addTaskBarButtonPressed:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"toAddTaskVC" sender:sender];
}

@end
