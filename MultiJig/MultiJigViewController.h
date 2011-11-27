//
//  MultiJigViewController.h
//  MultiJig
//
//  Created by Senn, Matthew on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "MultiJigImageView.h"

@interface MultiJigViewController : UIViewController <UIGestureRecognizerDelegate>

-(IBAction)resetPicture:(id)sender;

-(void)panToMatchGesture:(UIPanGestureRecognizer*)gesture;
-(void)rotateToMatchGesture:(UIRotationGestureRecognizer*)gesture;

@end
