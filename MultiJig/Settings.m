//
//  Settings.m
//  MultiJig
//
//  Created by Matthew Senn on 12/8/11.
//  Copyright (c) 2011 UNC Charlotte. All rights reserved.
//

#import "Settings.h"


@implementation Settings
@synthesize delegate;

-(void)valueChanged:(UISwitch*)sender
{
    [delegate enableAcceleration:sender.on];
}

@end
