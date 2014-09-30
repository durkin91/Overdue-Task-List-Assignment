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
#import "StyleKit.h"

@interface NDViewController ()

@end

@implementation NDViewController


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
            detailTaskVC.indexPath = indexPath;
            detailTaskVC.delegate = self;
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

#pragma Detail Task VC Delegate

-(void)saveTask:(NDTask *)task atIndexPath:(NSIndexPath *)indexPath
{
    [self.tasks replaceObjectAtIndex:indexPath.row withObject:task];
    
    NSMutableArray *editedTasks = [[NSMutableArray alloc] init];
    for (NDTask *task in self.tasks) {
        [editedTasks addObject:[self taskAsPropertyList:task]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:editedTasks forKey:ADDED_TASKS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadData];

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
    
    //making the cell background clear
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    
    //set up accessory view button frame
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    
    //Change backgroud color of delete editingAccessory view. Not sure if this works though??
    cell.editingAccessoryView.backgroundColor = [StyleKit red];
    
    
    //Check if the task is completed. If not, change accessory icon to uncompleted icon and give it translucent background.
    if (task.completed == NO) {
        //change accessory icon
        UIImage *uncompletedTask = [UIImage imageNamed:@"UncompletedTaskIcon"];
        [button setBackgroundImage:uncompletedTask forState:UIControlStateNormal];
        
        //change text color
        cell.textLabel.textColor = [UIColor blackColor];
        
        //setup 'due in' label with the right colors by using containsString helper method to check if the string contains '0d'
        cell.detailTextLabel.text = [task convertDateIntoDueDateFormat];
        cell.detailTextLabel.textColor = [task colorForDueDateString];
        
        //change cell background to translucent
        ILTranslucentView *translucentView = [[ILTranslucentView alloc] initWithFrame:cell.frame];
        translucentView.alpha = .95;
        [cell setBackgroundView:translucentView];
    }
    else {
        //change icon
        UIImage *completedTask = [UIImage imageNamed:@"CompletedTaskIcon"];
        [button setBackgroundImage:completedTask forState:UIControlStateNormal];

        //change formatting
        cell.textLabel.textColor = [UIColor whiteColor];
        NSDictionary* attributes = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:task.title attributes:attributes];
        cell.textLabel.attributedText = attributedString;
        
        //change text due date to 'COMPLETED'
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.text = @"COMPLETED";
        
        //making the cell background clear
        [cell setBackgroundView:nil];
    }
    
    return cell;
    
}

//Check if custom accessory button is tapped
- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil){
        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}


#pragma Table View Delegate methods

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toDetailVC" sender:indexPath];
    [self.tableView reloadData];
    return indexPath;
    
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //Find the appropriate task in the tasks array. If it is not completed, then set it to completed. If it is completed then set it to not completed.
    NDTask *task = [self.tasks objectAtIndex:indexPath.row];
    if (!task.completed) task.completed = YES;
    else task.completed = NO;
    NSLog(@"Task is completed? %d", task.completed);
    
    
    //Save the updated data to NSUserdefaults. There may be a more efficient way of doing this by just changing the one object, and not the whole array??? Then reload the tableview
    NSMutableArray *newUpdatedTasks = [[NSMutableArray alloc] init];
    for (NDTask *task in self.tasks) {
        [newUpdatedTasks addObject:[self taskAsPropertyList:task]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:newUpdatedTasks forKey:ADDED_TASKS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];

}

//Make sure each row is editable
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//Supports editing the table view
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tasks removeObjectAtIndex:indexPath.row];
        NSMutableArray *newSavedTasksData = [[NSMutableArray alloc] init];
        for (NDTask *task in self.tasks) {
            [newSavedTasksData addObject:[self taskAsPropertyList:task]];
        }
        [[NSUserDefaults standardUserDefaults] setObject:newSavedTasksData forKey:ADDED_TASKS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}

//Drag to reorder each row
-tableView


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
