//
//  Menu.m
//  MultiJig
//
//  Created by The House on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Menu.h"

@implementation Menu
#pragma mark - Property Synthesization
@synthesize mainGameController = _mainGameController;
@synthesize popcorn = _popcorn;
@synthesize selectedImage = _selectedImage;
@synthesize segmentedContent = _segmentedContent;
@synthesize difficultyLabelRows, difficultyLabelColumns;
@synthesize difficultySliderRows, difficultySliderColumns;

#pragma mark - Difficulty Sliders and Labels

-(IBAction)difficultyChangedForRow:(id)sender
{
    difficultyLabelRows.text = [NSString stringWithFormat:@"There will be %.0f rows", 
                                round(difficultySliderRows.value)];
}

-(IBAction)difficultyChangesDidEndForRow:(id)sender
{
    difficultySliderRows.value = round(difficultySliderRows.value);
    [self difficultyChangedForRow:sender];
}

-(IBAction)difficultyChangedForColumns:(id)sender
{
    difficultyLabelColumns.text = [NSString stringWithFormat:@"There will be %.0f columns", 
                                   round(difficultySliderColumns.value)];
}

-(IBAction)difficultyChangesDidEndForColumn:(id)sender;
{
    difficultySliderColumns.value = round(difficultySliderColumns.value);
    [self difficultyChangedForColumns:sender];
}

#pragma mark - Image Picker

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.selectedImage.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissModalViewControllerAnimated:YES];
}


-(void)contentSourceTypeDidChange:(UISegmentedControl*)sender
{
    UIImagePickerController *picker = (UIImagePickerController*)self.popcorn.contentViewController;
    switch(sender.selectedSegmentIndex)
    {
        case 0: 
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
    }
}

#pragma mark - Button Presses

-(IBAction)buttonClicked:(UIView*)sender
{
    self.popcorn.popoverContentSize = CGSizeMake(0,0);
    [self.popcorn presentPopoverFromRect:CGRectMake(sender.frame.origin.x,sender.center.y,0,0)
                                  inView:self.view 
                permittedArrowDirections:UIPopoverArrowDirectionRight 
                                animated:YES];
}


-(IBAction)startGame:(id)sender
{
    NSLog(@"In startGame");
    _mainGameController = [[MultiJigViewController alloc] init];
    self.mainGameController.mainImage = self.selectedImage.image;
    self.mainGameController.number_of_rows = self.difficultySliderRows.value;
    self.mainGameController.number_of_columns = self.difficultySliderColumns.value;
    
    [self.navigationController pushViewController:self.mainGameController animated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"MultiJig";
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate   = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    self.popcorn = [[UIPopoverController alloc] initWithContentViewController:picker];
    [picker release];
    
    [self difficultyChangesDidEndForRow:nil];
    [self difficultyChangesDidEndForColumn:nil];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [self.segmentedContent removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_mainGameController release];
    [_popcorn release];
    [_selectedImage release];
    [_segmentedContent release];
    [difficultyLabelRows release];
    [difficultyLabelColumns release];
    [difficultySliderRows release];
    [difficultySliderColumns release];
}

@end
