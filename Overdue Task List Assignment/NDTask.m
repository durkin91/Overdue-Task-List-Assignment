//
//  NDTask.m
//  Overdue Task List Assignment
//
//  Created by Nikki Durkin on 9/29/14.
//  Copyright (c) 2014 Nikki Durkin. All rights reserved.
//

#import "NDTask.h"
#import "StyleKit.h"

@implementation NDTask

-(id)init
{
    self = [self initWithData:nil];
    return self;
}

-(NDTask *)initWithData:(NSDictionary *)data
{
    self = [super init];
    self.title = data[TITLE];
    self.description = data[DESCRIPTION];
    self.dueDate = data[DUE_DATE];
    self.completed = [data[COMPLETION] boolValue];
    
    return self;
}

//turn NSdate into a string that can be displayed in the cell
-(NSString *)convertDateIntoDueDateFormat
{
    int timeInterval = [self.dueDate timeIntervalSinceNow];
    int daysLeft = [self daysLeftUntilTaskDue];
    int hoursLeft = (timeInterval % 86400) / 3600;
    
    NSString *dueIn;
    if (timeInterval >= 0) {
        dueIn = [NSString stringWithFormat:@"Due in %id %ih", abs(daysLeft), abs(hoursLeft)];
    }
    else dueIn = @"OVERDUE";
    
    return dueIn;
}
//tells you how many days are left until the task is due
-(int)daysLeftUntilTaskDue
{
    int timeInterval = [self.dueDate timeIntervalSinceNow];
    int daysLeft = abs(floor((double)timeInterval / 86400));
    return daysLeft;
}

//format the Due Date String with the right color
-(UIColor *)colorForDueDateString
{
    UIColor *color;
    NSString *dueDateString = [self convertDateIntoDueDateFormat];
    int daysLeft = [self daysLeftUntilTaskDue];
    if ([dueDateString isEqualToString:@"OVERDUE"])
        color = [StyleKit red];
    else if (daysLeft < 1)
        color = [StyleKit orange];
    else color = [StyleKit green];
    
    return color;

}



@end
