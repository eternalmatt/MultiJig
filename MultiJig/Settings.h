//
//  Settings.h
//  MultiJig
//
//  Created by Matthew Senn on 12/8/11.
//  Copyright (c) 2011 UNC Charlotte. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MJSettingsDelegate <NSObject>
@required

-(void)enableAcceleration:(BOOL)enable;

@end



@interface Settings : UIViewController
@property (nonatomic, assign) id<MJSettingsDelegate> delegate;

-(IBAction)valueChanged:(id)sender;

@end
