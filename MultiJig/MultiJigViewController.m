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
@interface MultiJigViewController()     //private .h
@property (nonatomic, retain) NSMutableArray *puzzlePieces;
@end

@implementation MultiJigViewController
@synthesize puzzlePieces = _puzzlePieces;
-(id)puzzlePieces
{
    if (nil == _puzzlePieces) 
        _puzzlePieces = [[NSMutableArray alloc] init];
    return _puzzlePieces;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Navigation Bar!";
    const NSUInteger ROW = 3, COL = 3;

    
    UIImage *puppy = [UIImage imageNamed:@"puppy.jpg"];
    
    NSArray *imageArray = [puppy getRectangularPuzzlePiecesWithRows:ROW andColumns:COL];
    NSMutableArray *pieces = [[NSMutableArray alloc] initWithCapacity:ROW*COL];
    
    int i = 0;
    for(UIImage *image in imageArray)
    {
        const CGFloat X = arc4random() % (int)(self.view.frame.size.width - image.size.width / 2.0);
        const CGFloat Y = arc4random() % (int)(self.view.frame.size.height - image.size.height / 2.0);
        CGRect frame = CGRectMake(X, Y, image.size.width, image.size.height);
    
        MultiJigImageView *view = [[MultiJigImageView alloc] initWithFrame:frame];
        view.image = image;
        view.correctPlacement = CGPointMake(100+image.size.width*(i/ROW),100+image.size.height*(i%COL));
        
        UIPanGestureRecognizer *panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToMatchGesture:)];
        [panner setDelegate:self];
        [view addGestureRecognizer:panner];
        [panner release];
        
        UIRotationGestureRecognizer *rotater = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateToMatchGesture:)];
        [rotater setDelegate:self];
        [view addGestureRecognizer:rotater];
        [rotater release];
        
        
        [pieces addObject:view];
        [self.view addSubview:view];
        [view release];
        i++;
    }
    
    self.puzzlePieces = pieces;
    NSLog(@"ViewController loaded");
}


-(IBAction)resetPicture:(id)sender
{
    [UIView animateWithDuration:3.0 animations:^(void)
     {
         for(MultiJigImageView *view in self.puzzlePieces)
             [view resetToStartingLocation];
     }];
}

#pragma mark Gesture Recognizer methods

-(void)panToMatchGesture:(UIPanGestureRecognizer*)gesture
{
    MultiJigImageView *view = (MultiJigImageView*)gesture.view;
    
    if ([view touchExistsOnTransparency:[gesture locationInView:gesture.view]])
        return;
    
    
    switch(gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [self.view bringSubviewToFront:view]; //might also want this in StateEnded. gameplay decison.
        }
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
            NSArray *nearby = [view nearbyPuzzlePieces:self.puzzlePieces];
            for (MultiJigImageView *other in nearby) 
            {
                CGPoint point = CGPointMake(other.center.x - view.center.x, other.center.y - view.center.y);
                //[view combineSelfWithOther:other atOffset:point];
                
                [other removeFromSuperview];
                [self.puzzlePieces removeObject:other];
                
                UIImage *image = [UIImage imageByCombining:view.image another:other.image atOffset:point];
                MultiJigImageView *mjiv = [[MultiJigImageView alloc] initWithFrame:view.frame];
                mjiv.image = image;
                
                UIPanGestureRecognizer *panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToMatchGesture:)];
                [panner setDelegate:self];
                [mjiv addGestureRecognizer:panner];
                [panner release];
                
                UIRotationGestureRecognizer *rotater = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateToMatchGesture:)];
                [rotater setDelegate:self];
                [mjiv addGestureRecognizer:rotater];
                [rotater release];
                
                
                [self.view addSubview:mjiv];
                [self.puzzlePieces addObject:mjiv];
                [mjiv release];
            }
            
            
            self.title = [NSString stringWithFormat:@"That piece was touching %d others", nearby.count];
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
    CGAffineTransform enlarge  = CGAffineTransformMakeScale(2.0, 2.0);  //2*width, 2*height
    CGAffineTransform current  = CGAffineTransformMakeRotation(1.5 * gesture.rotation);//rotation is faster
    CGAffineTransform rotation = CGAffineTransformConcat(view.previousRotation, current);//rotation += previous
    
    switch(gesture.state)
    {
        case UIGestureRecognizerStateBegan:
            [UIView animateWithDuration:0.5 animations:^{
                view.transform = enlarge;   //just enlarge the view
            }];
            break;
            
        case UIGestureRecognizerStateChanged:
            view.transform = CGAffineTransformConcat(enlarge, rotation); //enlarge + rotation
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
            
            [UIView animateWithDuration:0.5 animations:^{
                CGAffineTransform nearest = CGAffineTransformMakeRotation([view nearestQuarterAngle:gesture.rotation]);
                view.transform = CGAffineTransformConcat(nearest, view.previousRotation);
                //  view.transform = rotation;  //just the rotation (take away the enlargement)
            }];
            view.previousRotation = rotation;
            
            CGFloat angle = atan2(view.transform.b,view.transform.a);
            NSLog(@"%f", [view nearestQuarterAngle:angle]);
            
            
        case UIGestureRecognizerStatePossible:
            break;
    }
}

#pragma mark Gesture Delegate methods

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

#pragma mark View Lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)dealloc
{
    [super dealloc];
    [_puzzlePieces release];
    _puzzlePieces = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
