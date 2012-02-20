//
//  Menu.h
//  MultiJig
//
//  Created by The House on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiJigViewController.h"

@interface Menu : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) MultiJigViewController *mainGameController;
@property (nonatomic, retain) UIPopoverController *popcorn;

/*images*/
@property (nonatomic, retain) IBOutlet UIImageView *selectedImage;

/*sliders*/
@property (nonatomic, retain) IBOutlet UISlider *difficultySliderRows;
@property (nonatomic, retain) IBOutlet UISlider *difficultySliderColumns;

/*labels*/
@property (nonatomic, retain) IBOutlet UILabel *difficultyLabelRows;
@property (nonatomic, retain) IBOutlet UILabel *difficultyLabelColumns;

/*miscellaneous*/
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedContent;



-(IBAction)buttonClicked:(id)sender;
-(IBAction)startGame:(id)sender;

-(IBAction)difficultyChangedForRow:(id)sender;
-(IBAction)difficultyChangesDidEndForRow:(id)sender;

-(IBAction)difficultyChangedForColumns:(id)sender;
-(IBAction)difficultyChangesDidEndForColumn:(id)sender;

-(IBAction)contentSourceTypeDidChange:(id)sender;

@end
