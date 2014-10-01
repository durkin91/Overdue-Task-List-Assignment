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

#define ADDED_TASKS_KEY @"Added Tasks Array"
#define COMPLETED_TASKS_KEY @"Uncompleted Tasks Array"
#define OVERDUE_TASKS_KEY @"Overdue Tasks Array"

@interface NDViewController ()

@end

@implementation NDViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //temporarily clear out all arrays
//    [self.tasks removeAllObjects];
//    [self saveAnIndividualArray:self.tasks toNSUserDefaultsKey:ADDED_TASKS_KEY];
//    
//    [self.completedTasks removeAllObjects];
//    [self saveAnIndividualArray:self.completedTasks toNSUserDefaultsKey:COMPLETED_TASKS_KEY];
//    
//    [self.completedTasks removeAllObjects];
//    [self saveAnIndividualArray:self.overdueTasks toNSUserDefaultsKey:OVERDUE_TASKS_KEY];
    
    
    
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
    
    
    //retrieve the array of uncompleted task property lists, and turn them into task objects and save them in the tasks array property.
    NSArray *tasksAsPropertyLists = [[NSUserDefaults standardUserDefaults] objectForKey:ADDED_TASKS_KEY];
    [self populateArray:self.tasks withTasksFromPropertyLists:tasksAsPropertyLists];
    NSLog(@"Populated self.tasks");
    NSLog(@"%@", self.tasks);
    
    //then do the same for the completed tasks
    tasksAsPropertyLists = [[NSUserDefaults standardUserDefaults] objectForKey:COMPLETED_TASKS_KEY];
    [self populateArray:self.completedTasks withTasksFromPropertyLists:tasksAsPropertyLists];
    NSLog(@"Populated self.completedTasks");
    NSLog(@"%@", self.completedTasks);
    
    //and for overdue tasks
    tasksAsPropertyLists = [[NSUserDefaults standardUserDefaults] objectForKey:OVERDUE_TASKS_KEY];
    [self populateArray:self.overdueTasks withTasksFromPropertyLists:tasksAsPropertyLists];
    NSLog(@"Populated self.overdueTasks");
    NSLog(@"%@", self.overdueTasks);
  
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
            detailTaskVC.task = [[self correctArrayBasedOnIndexPath:indexPath] objectAtIndex:indexPath.row];
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

#pragma mark Add Task VC Delegate Methods
-(void)didAddTask:(NDTask *)task;
{
    //perform lazy instantiation on self.tasks, then add the new task to that array. Create a tasksAsPropertyList variable that holds the array retrieved from NSUserDefaults, and if no such array exists then alloc one. Then add the task's property list to that array. Then put the array back into NSUserDefaults and save it. Dismiss the modal and reload the tableview data.
    
    NSMutableArray *tasksAsPropertyLists;
    
    //Check whether the task is overdue
    int secsUntilDue = [task.dueDate timeIntervalSinceNow];
    if (secsUntilDue < 0) {
        [self.overdueTasks addObject:task];
        tasksAsPropertyLists = [[[NSUserDefaults standardUserDefaults] arrayForKey:OVERDUE_TASKS_KEY] mutableCopy];
        if (!tasksAsPropertyLists) tasksAsPropertyLists = [[NSMutableArray alloc] init];
        [tasksAsPropertyLists addObject:[self taskAsPropertyList:task]];
        [[NSUserDefaults standardUserDefaults] setObject:tasksAsPropertyLists forKey:OVERDUE_TASKS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        [self.tasks addObject:task];
        tasksAsPropertyLists = [[[NSUserDefaults standardUserDefaults] arrayForKey:ADDED_TASKS_KEY] mutableCopy];
        if (!tasksAsPropertyLists) tasksAsPropertyLists = [[NSMutableArray alloc] init];
        [tasksAsPropertyLists addObject:[self taskAsPropertyList:task]];
        [[NSUserDefaults standardUserDefaults] setObject:tasksAsPropertyLists forKey:ADDED_TASKS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
    
}

-(void)didCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Detail Task VC Delegate

-(void)saveTask:(NDTask *)task atIndexPath:(NSIndexPath *)indexPath
{
    //check whether the task is overdue. If it is it needs to be placed in the overdue section
    NSMutableArray *arrayOfTasks = [self correctArrayBasedOnIndexPath:indexPath];
    [arrayOfTasks removeObjectAtIndex:indexPath.row];
    
    if (([task.dueDate timeIntervalSinceNow] < 0.0) && task.completed == NO)
        [self.overdueTasks addObject:task];
    else if ([task.dueDate timeIntervalSinceNow] >= 0.0 && task.completed == NO)
        [self.tasks addObject:task];
    else
        [self.completedTasks addObject:task];

//    [arrayOfTasks replaceObjectAtIndex:indexPath.row withObject:task];
//    
//    NSMutableArray *editedTasks = [[NSMutableArray alloc] init];
//    for (NDTask *task in arrayOfTasks) {
//        [editedTasks addObject:[self taskAsPropertyList:task]];
//    }
    
    [self saveTasksToNSUserDefaults];
    [self.tableView reloadData];

}

-(void)didChangeCompletionStatus:(UIButton *)button withLabel:(UILabel *)label atIndexPath:(NSIndexPath *)indexPath
{
    NDTask *task = [self taskWithIndexPath:indexPath];
    if (!task.completed) {
        [button setBackgroundImage:[UIImage imageNamed:@"WhiteCompletedTaskIcon"] forState:UIControlStateNormal];
        label.text = @"COMPLETED";
        label.textColor = [UIColor whiteColor];
    }
    else {
        [button setBackgroundImage:[UIImage imageNamed:@"WhiteUncompletedTaskIcon"] forState:UIControlStateNormal];
        
        //setup due date label
        label.text = [task convertDateIntoDueDateFormat];
        label.textColor = [task colorForDueDateString];
    }
    
    [self setTaskCompletionStatusAndPersist:indexPath];
    [self.tableView reloadData];
}


#pragma mark Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    int number = 0;
//    if ([self.tasks count])
//        number = number + 1;
//    if ([self.overdueTasks count])
//        number = number + 1;
//    if ([self.completedTasks count])
//        number = number + 1;
//    NSLog(@"Number of sections: %i", number);
    return 3;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //create the background and label view
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 28)];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, self.tableView.frame.size.width, 24)];
    
    //Format the title & view
    headerView.alpha = 0.8;
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.textColor = [UIColor whiteColor];
    headerTitle.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14];
    
    if (section == 0) {
        headerView.backgroundColor = [StyleKit red];
        headerTitle.text = @"OVERDUE";
    }
    else if (section == 1) {
        headerView.backgroundColor = [StyleKit green];
        headerTitle.text = @"TO DO";
    }
    else {
        headerView.backgroundColor = [StyleKit darkGrey];
        headerTitle.text = @"COMPLETED";
    }
    
    [headerView addSubview:headerTitle];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28;
}

//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    if (section == 2) {
//        
//        //create background view and make transparent
//        UIView *clearTasksView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 55)];
//        clearTasksView.backgroundColor = [UIColor clearColor];
//        
//        //Format the button
//        UIButton *clearTasksButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 22, self.tableView.frame.size.width, 14)];
//        [clearTasksButton setTitle:@"CLEAR COMPLETED TASKS" forState:UIControlStateNormal];
//        clearTasksButton.tintColor = [UIColor whiteColor];
//        clearTasksButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:10];
//        
//        //Format the button's action events
//        [clearTasksButton addTarget:self action:@selector(clearTasksButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [clearTasksView addSubview:clearTasksButton];
//        return clearTasksView;
//    }
//    else return nil;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if (section == 0) return 0;
//    else if (section == 1) return 0;
//    else return 55;
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"numberOfRowsInSection");
    if (section == 0){
        NSLog(@"I am in section 0");
        return [self.overdueTasks count];
    }
    else if (section == 1) {
        NSLog(@"I am in section 1");
        return [self.tasks count];
    }
    else {
        NSLog(@"I am in section 2");
        return [self.completedTasks count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"taskCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSLog(@"Set up the cell");
    
    //select the task from the correct array, depending on the section
    NDTask *task = [self taskWithIndexPath:indexPath];
    
    //Configure the cell
    cell.textLabel.text = task.title;
    cell.showsReorderControl = YES;
    
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
    
    
    //Check if the task is completed. If not, change accessory icon to uncompleted icon and give it translucent background.
    if (task.completed == NO) {
        //change accessory icon
        UIImage *uncompletedTask = [UIImage imageNamed:@"UncompletedTaskIcon"];
        [button setBackgroundImage:uncompletedTask forState:UIControlStateNormal];
        
        //change text color
        cell.textLabel.textColor = [UIColor blackColor];
        
        //setup 'due in' label
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



#pragma mark Table View Delegate methods

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

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toDetailVC" sender:indexPath];
    [self.tableView reloadData];
    return indexPath;
    
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //Use the helper methods to change the completion status and persist to NSuserdefaults, then reload table view
    [self setTaskCompletionStatusAndPersist:indexPath];
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
    //determine the correct array to remove the object from, then do it
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[self correctArrayBasedOnIndexPath:indexPath] removeObjectAtIndex:indexPath.row];
        [self saveTasksToNSUserDefaults];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}

//Tell tableview that it is allowed to be reordered
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) return NO;
    else return YES;
}

//Where the tableview reordering actually happens
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSMutableArray *arrayOfTasksSource = [self correctArrayBasedOnIndexPath:sourceIndexPath];
    NSMutableArray *arrayOfTasksDestination = [self correctArrayBasedOnIndexPath:destinationIndexPath];
    NDTask *task = [arrayOfTasksSource objectAtIndex:sourceIndexPath.row];
    
    //Change the completed status if necessary
    if (arrayOfTasksDestination == self.completedTasks)
        task.completed = YES;
    else if (arrayOfTasksDestination == self.tasks)
        task.completed = NO;
    
    //remove object from old section and replace it in new section
    [arrayOfTasksSource removeObjectAtIndex:sourceIndexPath.row];
    [arrayOfTasksDestination insertObject:task atIndex:destinationIndexPath.row];

    [self saveTasksToNSUserDefaults];
    [self.tableView reloadData];
}

//Disable dragging a cell to the overdue section
-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.section == 0) {
        return sourceIndexPath;
    }
    else return proposedDestinationIndexPath;
}


#pragma mark helper methods

//lazy instantiation for task array
-(NSMutableArray *)tasks
{
    if (!_tasks) {
        _tasks = [[NSMutableArray alloc] init];
    }
    return _tasks;
}

//lazy instantiation for overdue tasks array
-(NSMutableArray *)overdueTasks
{
    if (!_overdueTasks) {
        _overdueTasks = [[NSMutableArray alloc] init];
    }
    return _overdueTasks;
}

//lazy instantiation for completed tasks array
-(NSMutableArray *)completedTasks
{
    if (!_completedTasks) {
        _completedTasks = [[NSMutableArray alloc] init];
    }
    return _completedTasks;
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

//Saves self.tasks, self.overdueTasks and self.completedTasks data into NSUserdefaults.
-(void)saveTasksToNSUserDefaults
{
    [self saveAnIndividualArray:self.tasks toNSUserDefaultsKey:ADDED_TASKS_KEY];
    [self saveAnIndividualArray:self.overdueTasks toNSUserDefaultsKey:OVERDUE_TASKS_KEY];
    [self saveAnIndividualArray:self.completedTasks toNSUserDefaultsKey:COMPLETED_TASKS_KEY];
}

//will save an individual array of task objects to NSUserDefaults
-(void)saveAnIndividualArray:(NSMutableArray *)array toNSUserDefaultsKey:(NSString *)key
{
    NSMutableArray *newSavedTasksData = [[NSMutableArray alloc] init];
    for (NDTask *task in array) {
        [newSavedTasksData addObject:[self taskAsPropertyList:task]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:newSavedTasksData forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//populate a tasks array with task objects from a dictionary (taken from NSUserdefaults
-(void)populateArray:(NSMutableArray *)array withTasksFromPropertyLists:(NSArray *)propertyList
{
    for (NSDictionary *dictionary in propertyList) {
        NDTask *task = [[NDTask alloc] initWithData:dictionary];
        [array addObject:task];
    }
}

//select the correct task from the correct array
-(NDTask *)taskWithIndexPath:(NSIndexPath *)indexPath
{
    NDTask *task;
    if (indexPath.section == 0) task = [self.overdueTasks objectAtIndex:indexPath.row];
    else if (indexPath.section == 1) task = [self.tasks objectAtIndex:indexPath.row];
    else task = [self.completedTasks objectAtIndex:indexPath.row];
    return task;
}

-(NSMutableArray *)correctArrayBasedOnIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) return self.overdueTasks;
    else if (indexPath.section == 1) return self.tasks;
    else return self.completedTasks;
}

//Set and persist the task's completion status.
-(void)setTaskCompletionStatusAndPersist:(NSIndexPath *)indexPath
{
    NDTask *task = [self taskWithIndexPath:indexPath];
    NSMutableArray *correctArray = [self correctArrayBasedOnIndexPath:indexPath];
    
    if (!task.completed) {
        task.completed = YES;
        [correctArray removeObjectAtIndex:indexPath.row];
        [self.completedTasks addObject:task];
    }
    else {
        task.completed = NO;
        [correctArray removeObjectAtIndex:indexPath.row];
        
        //Check to see if its overdue
        NSString *dueDate = [task convertDateIntoDueDateFormat];
        if ([dueDate isEqualToString:@"OVERDUE"]) {
            [self.overdueTasks addObject:task];
        }
        else [self.tasks addObject:task];
    }
    [self saveTasksToNSUserDefaults];
}

#pragma mark Actions

- (IBAction)reorderTaskBarButtonPressed:(UIBarButtonItem *)sender
{
    if (!self.tableView.editing)
        self.tableView.editing = YES;
    else
        self.tableView.editing = NO;
}

- (IBAction)addTaskBarButtonPressed:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"toAddTaskVC" sender:sender];
}

//-(void)clearTasksButtonPressed:(UIButton *)sender
//{
//    for (NDTask *task in self.completedTasks) {
//        [self.completedTasks removeObject:task];
//    }
//    [self saveAnIndividualArray:self.completedTasks toNSUserDefaultsKey:COMPLETED_TASKS_KEY];
//    [self.tableView reloadData];
//}

@end
