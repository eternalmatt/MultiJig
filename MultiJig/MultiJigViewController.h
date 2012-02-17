//
//  MultiJigViewController.h
//  MultiJig
//
//  Created by Senn, Matthew on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "MultiJigImageView.h"
#import "MJGameModel.h"
#import "Settings.h"

@interface MultiJigViewController : UIViewController 
<UIAlertViewDelegate, 
UIAccelerometerDelegate, 
UIGestureRecognizerDelegate, 
MJModelDelegate,
MJGestureDelegate,
MJSettingsDelegate>
{
    NSDate *startDate;
    NSTimer *maintimer;
}
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSTimer *mainTimer;

@property (nonatomic, retain) UIImage *mainImage;
@property (nonatomic) NSUInteger number_of_rows;
@property (nonatomic) NSUInteger number_of_columns;

-(IBAction)resetPicture:(id)sender;

//these are functions declared from MJGestureDelegate
-(void)panToMatchGesture:(UIPanGestureRecognizer*)gesture;
-(void)rotateToMatchGesture:(UIRotationGestureRecognizer*)gesture;
-(void)tapToMatchGesture:(UITapGestureRecognizer*)gesture;


//these are things i'm going to implement that are automatically declared from MJModelDelegate
-(void)combinePiece:(id)one withOther:(id)other;
-(void)userDidSolvePuzzle;

@end