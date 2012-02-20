//
//  MultiJigViewController.m
//  MultiJig
//
//  Created by Senn, Matthew on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MultiJigViewController.h"
#import "MultiJigImageView.h"
#import "UIImageCategory.h"
#import "Settings.h"

#pragma mark Private Properties
@interface MultiJigViewController()     //private .h
{
    CGSize pieceSize;
    BOOL accelerationEnabled;
}
@property (nonatomic, retain) MJGameModel *model;
@property (nonatomic, retain) NSMutableArray *puzzlePieces;
@property (nonatomic) NSInteger numberSelected;
@property (nonatomic, retain) UIAlertView *userWonAlertView;
@property (nonatomic, retain) UIPopoverController *popcorn;
@end
#pragma mark Public Properties
@implementation MultiJigViewController
@synthesize numberSelected;
@synthesize number_of_rows;
@synthesize number_of_columns;
@synthesize mainImage = _mainImage;
@synthesize puzzlePieces = _puzzlePieces;
@synthesize model = _model;
@synthesize userWonAlertView;
@synthesize startDate;
@synthesize mainTimer;
@synthesize popcorn;

#pragma mark - Initialization
-(id)init
{
    if (self = [super init])
    {
        _puzzlePieces = [[NSMutableArray alloc] init];
        _model = [[MJGameModel alloc] init];
        _model.delegate = self;
        numberSelected = 0;
        userWonAlertView = [[UIAlertView alloc] initWithTitle:@"You beat the game!" 
                                                      message:@"Would you like to play again?"
                                                     delegate:self
                                            cancelButtonTitle:@"No"
                                            otherButtonTitles:@"Yes", nil];
    }
    return self;
}

-(void)enableAcceleration:(BOOL)enable
{
    accelerationEnabled = enable;
}

-(void)dosomething
{
    [self.popcorn presentPopoverFromRect:CGRectMake(753,0,0,0)
                             inView:self.view 
                permittedArrowDirections:UIPopoverArrowDirectionUp 
                                animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Navigation Bar!";
    
    /* setting up accelerator */
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0/40.0)];
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
    accelerationEnabled = YES;
    
    /* settings button */
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.rightBarButtonItem.target = self;
    self.navigationItem.rightBarButtonItem.action = @selector(dosomething);
    
    /* view controller and popover for settings button */
    Settings *settings = [[Settings alloc] init];
    settings.delegate = self;
    self.popcorn = [[[UIPopoverController alloc] initWithContentViewController:settings] autorelease];
    [settings release];
    self.popcorn.popoverContentSize = CGSizeMake(230,60);
    
    
    /* default image */
    if (nil == self.mainImage)
        self.mainImage = [UIImage imageNamed:@"puppy.jpg"];
    
    NSArray *imageArray = [self.mainImage getRectangularPuzzlePiecesWithRows:number_of_rows andColumns:number_of_columns];
    
    pieceSize = CGSizeMake(self.mainImage.size.width / ((CGFloat)number_of_columns),
                           self.mainImage.size.height / ((CGFloat)number_of_rows));
    self.model.pieceSize = pieceSize;
    
    int i=0, j;
    NSMutableArray *pieces = [[NSMutableArray alloc] initWithCapacity:number_of_rows*number_of_columns];
    for(NSArray *row in imageArray)
    {
        j=0;
        for(UIImage *image in row) 
        {
            const CGFloat X = arc4random() % (int)(self.view.frame.size.width - image.size.width / 2.0);
            const CGFloat Y = arc4random() % (int)(self.view.frame.size.height - image.size.height / 2.0);
            CGRect frame = CGRectMake(X, Y, image.size.width, image.size.height);
        
            MultiJigImageView *view = [[MultiJigImageView alloc] initWithFrame:frame];
            view.image = image;
            view.grid_x = i;
            view.grid_y = j;
            [view setDelegate:self];
            
            [pieces addObject:view];
            [self.view addSubview:view];
            [self.model setGamePiece:view atGridPosition:CGPointMake(view.grid_x,view.grid_y)];
            [view release];
            j++;
        }
        i++;
    }
        
    self.puzzlePieces = pieces;
    self.startDate = [NSDate date];
    
    self.mainTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/100.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    
    NSLog(@"ViewController loaded");
}


#pragma mark -  Model Delegate methods

-(void)combinePiece:(MultiJigImageView*)one withOther:(MultiJigImageView*)two
{
    NSLog(@"Implementing %s", __FUNCTION__);
    
    if (self.numberSelected <= 0)
    {
        NSLog(@"Nope, number selected is %d", numberSelected);
        self.numberSelected = 0;
    }
    else if (ABS([one adjustToNearestDesiredAngle] - [two adjustToNearestDesiredAngle]) > .1) 
    {
        NSLog(@"Bad angle");
        return;
    }
    else
    { 
        NSLog(@"Good angle");

        if (CGRectIntersectsRect(one.frame, two.frame))
            [UIView animateWithDuration:0.5 animations:^{
                NSLog(@"They are intersecting");
                self.numberSelected = 0;
            
                MultiJigImageView *view = [[MultiJigImageView alloc] initByCombining:one andOther:two withRegularSize:pieceSize];
                view.delegate = self;
            
                [self.model combinePieces:one andOther:two intoNew:view];
                [one removeFromSuperview];
                [two removeFromSuperview];
                [self.puzzlePieces removeObject:one];
                [self.puzzlePieces removeObject:two];
            
                [self.puzzlePieces addObject:view];
                [self.view addSubview:view];
                
                [view release];
            }];
        else NSLog(@"Not intersecting");
    }
    
    
}

-(void)userDidSolvePuzzle
{
    NSLog(@"Need to implement %s", __FUNCTION__);
    [userWonAlertView show];
}



#pragma mark - Gesture Recognizer methods

-(void)tapToMatchGesture:(UITapGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        MultiJigImageView *view = (MultiJigImageView*)gesture.view;
        
        if (!view.selected && self.numberSelected <= 1)
        {
            CGAffineTransform scale = CGAffineTransformMakeScale(2.0, 2.0);
            CGAffineTransform transform = CGAffineTransformConcat(scale, view.previousRotation);
            [UIView animateWithDuration:0.5 animations:^(void){ view.transform = transform; }];
            self.numberSelected += 1;
        }
        else if (view.selected)
        {
            [UIView animateWithDuration:0.5 animations:^(void){ view.transform = view.previousRotation; }];
            self.numberSelected -= 1;
        }
        
        view.selected = !view.selected;
        [self.model updateWithView:view andSelected:view.selected];
    }
}

-(void)panToMatchGesture:(UIPanGestureRecognizer*)gesture
{
    MultiJigImageView *view = (MultiJigImageView*)gesture.view;
    switch(gesture.state)
    {
        case UIGestureRecognizerStateBegan:
            
            NSLog(@"Pan Began");
            [self.view bringSubviewToFront:view]; //might also want this in StateEnded. gameplay decison.
            
        case UIGestureRecognizerStateChanged:
        {
            //obtain translation (since last call to function)
            CGPoint translation = [gesture translationInView:view.superview];
            
            //change the center (similar to view.center += translation)
            view.center = CGPointMake(view.center.x + translation.x, view.center.y + translation.y);
            
            //reset the translation to 0
            [gesture setTranslation:CGPointZero inView:view.superview];
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self.model setGamePiece:view atWorldPosition:view.center];
            NSLog(@"Number selected is %d", numberSelected);
        }
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateFailed:   
            break;
    }
}

-(void)rotateToMatchGesture:(UIRotationGestureRecognizer*)gesture
{
    MultiJigImageView *view = (MultiJigImageView*)gesture.view;
    
    switch(gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        {
            CGAffineTransform transform = CGAffineTransformMakeRotation(gesture.rotation * 1.5); //makes it feel faster
            transform = CGAffineTransformConcat(view.previousRotation, transform);
            view.transform = transform;
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
        {
            [UIView animateWithDuration:0.5 animations:^{ 
                CGFloat angle = [view adjustToNearestDesiredAngle];
                view.transform = CGAffineTransformMakeRotation(angle);
                view.previousRotation = view.transform;
            }];
        }
            
        case UIGestureRecognizerStatePossible:
            break;
    }
    
    if (view.selected) view.transform = CGAffineTransformConcat(view.transform, CGAffineTransformMakeScale(2.0, 2.0));
}

#pragma mark - Accelerometer, Shake, Timer

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    if (!accelerationEnabled) return;
    static const float sensitivity = 10.0f;        
    float xDistance=acceleration.x*sensitivity;
    float yDistance=acceleration.y*(0-sensitivity);
    
    //NSLog(@"sf %f", acceleration.x);
    if(fabsf(acceleration.x)<0.01||fabsf(acceleration.y)<0.01)
    {
        xDistance=0;
        yDistance=0;
    }
    else for(MultiJigImageView *view in self.puzzlePieces)
    {
        CGPoint newCenter = [view center];
        newCenter.x += xDistance;
        newCenter.y += yDistance;
        
        if(newCenter.x<50.0)
            newCenter.x=50.0;
        else if(newCenter.x>700.0)
            newCenter.x=700.0;
        
        if (newCenter.y<50.0)
            newCenter.y=50.0;
        else if(newCenter.y>950.0)
            newCenter.y=950.0;
        
        [view setCenter:newCenter];
    }
}


-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if(motion == UIEventSubtypeMotionShake)
        [[[[UIAlertView alloc] initWithTitle:@"You shook the puzzle!" 
                                     message:@"Would you like to reset the puzzle pieces?"
                                    delegate:self 
                           cancelButtonTitle:@"Cancel"
                           otherButtonTitles:@"Yes", nil] 
          autorelease] show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == userWonAlertView)
    {
        if (buttonIndex == 0)
            [self.navigationController popViewControllerAnimated:YES];
        else
            [self.navigationController popViewControllerAnimated:YES];
    }
    else 
    if (buttonIndex==1) 
    {
        self.startDate = [NSDate date];
        self.mainTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/100.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
        
        [UIView animateWithDuration:0.5 animations:^{
            for (MultiJigImageView *view in self.puzzlePieces) 
            {
                view.center = CGPointMake(arc4random() % 768, arc4random() % 1024);
                view.previousRotation = view.transform = CGAffineTransformMakeRotation(arc4random());
            }
        }];
    }
}


-(void) updateTimer{
    //    static NSInteger counter=0;
    //    stopWatch.text=[NSString stringWithFormat:@"Counter: %i",counter++];
    //    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss:SS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString = [dateFormatter stringFromDate:timerDate];
    self.title = [NSString stringWithFormat:@"MultiJig --- %@", timeString];
    [dateFormatter release];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self becomeFirstResponder];
}
-(BOOL)canBecomeFirstResponder{
    return YES;
}

#pragma mark - Gesture Delegate methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s",__FUNCTION__);
}

-(void)touchesChanged:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s",__FUNCTION__);

}-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s",__FUNCTION__);
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s",__FUNCTION__);
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - View Lifecycle


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (void)dealloc
{
    [super dealloc];
    [_puzzlePieces release];
    _puzzlePieces = nil;
    [_model release];
    _model = nil;
    [userWonAlertView release];
    userWonAlertView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
