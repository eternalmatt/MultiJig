//
//  MultiJigImageView.m
//  MultiJig
//
//  Created by Senn, Matthew on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MultiJigImageView.h"
#import "UIImageCategory.h"

#pragma mark MultiJig Image View Class
@implementation MultiJigImageView
//@synthesize superview;
@synthesize previousRotation;
@synthesize selected;
@synthesize grid_x, grid_y;

#pragma mark - Initialization
-(id)init{return nil;}
-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled   = YES;
        self.transform = CGAffineTransformMakeRotation(arc4random());
        [self adjustToNearestDesiredAngle];
        previousRotation = self.transform;
        self.selected = NO;
    }
    return self;
}

-(id)initByCombining:(id)oneView andOther:(id)twoView withRegularSize:(CGSize)pieceSize;
{
    MultiJigImageView *one = oneView;//[oneView copy]; //should probably copy here!
    MultiJigImageView *two = twoView;//[twoView copy];
    CGAffineTransform incomingTransform = one.transform;
    one.transform = CGAffineTransformIdentity;
    two.transform = CGAffineTransformIdentity;
    
    CGRect oneframe = CGRectMake(one.grid_x * pieceSize.width, one.grid_y * pieceSize.height, one.frame.size.width, one.frame.size.height);
    CGRect twoframe = CGRectMake(two.grid_x * pieceSize.width, two.grid_y * pieceSize.height, two.frame.size.width, two.frame.size.height);
    
    CGPoint onepoint, twopoint;
    if (oneframe.origin.x < twoframe.origin.x)
    {
        onepoint.x = 0; 
        twopoint.x = twoframe.origin.x - oneframe.origin.x;
    }
    else
    {
        onepoint.x = oneframe.origin.x - twoframe.origin.x; 
        twopoint.x = 0;
    }
    if (oneframe.origin.y < twoframe.origin.y)
    {
        onepoint.y = 0;
        twopoint.y = twoframe.origin.y - oneframe.origin.y;
    }
    else
    {
        onepoint.y = oneframe.origin.y - twoframe.origin.y; 
        twopoint.y = 0;
    }
    
    
    CGRect frame;
    frame.origin      = CGPointZero;
    frame.size.width  = MAX(onepoint.x + oneframe.size.width, twopoint.x + twoframe.size.width);
    frame.size.height = MAX(onepoint.y + oneframe.size.height,twopoint.y + twoframe.size.height);
    
    if (self = [self initWithFrame:frame])
    {
        UIGraphicsPushContext(UIGraphicsGetCurrentContext());
        UIGraphicsBeginImageContext(frame.size);
        
        [one.image drawAtPoint:onepoint];
        [two.image drawAtPoint:twopoint];
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        UIGraphicsPopContext();
        /*
        NSLog(@"one:(%d,%d), two:(%d,%d)", one.grid_x, one.grid_y, two.grid_x, two.grid_y);
        NSLog(@"%@, %@", NSStringFromCGPoint(onepoint), NSStringFromCGPoint(twopoint));
        NSLog(@"%@, %@, %@", NSStringFromCGRect(oneframe), NSStringFromCGRect(twoframe), NSStringFromCGRect(frame));
        */
        self.grid_x = MIN(one.grid_x, two.grid_x);
        self.grid_y = MIN(one.grid_y, two.grid_y);
        
        self.center = one.center;
        self.transform = CGAffineTransformScale(incomingTransform, 0.5, 0.5);
        self.previousRotation = self.transform;
        
    }
    
    //[one release]; //should release here after copy!
    //[two release];
    return self;
}

#pragma mark - Miscellaneous
-(void)setDelegate:(id<MJGestureDelegate, UIGestureRecognizerDelegate>)delegate
{
    UIPanGestureRecognizer *panner = [[UIPanGestureRecognizer alloc] initWithTarget:delegate action:@selector(panToMatchGesture:)];
    [panner setDelegate:delegate];
    [self addGestureRecognizer:panner];
    [panner release];
    
    UIRotationGestureRecognizer *rotater = [[UIRotationGestureRecognizer alloc] initWithTarget:delegate action:@selector(rotateToMatchGesture:)];
    [rotater setDelegate:delegate];
    [self addGestureRecognizer:rotater];
    [rotater release];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:delegate action:@selector(tapToMatchGesture:)];
    [tapper setDelegate:delegate];
    [tapper setNumberOfTapsRequired:2];
    [self addGestureRecognizer:tapper];
    [tapper release];
}


//not sure if this works yet.
-(id)copyWithZone:(NSZone *)zone
{
    MultiJigImageView *copy = [[MultiJigImageView alloc] init];
    copy.previousRotation = self.previousRotation;
    copy.selected = self.selected;
    copy.grid_x = self.grid_x;
    copy.grid_y = self.grid_y;
    return copy;
}

//this doesn't really work.
//http://stackoverflow.com/questions/6073259/getting-rgb-pixel-data-from-cgimage
-(BOOL)touchExistsOnTransparency:(CGPoint)touch
{
    const CGImageRef cgimage = self.image.CGImage;
    const size_t width  = CGImageGetWidth(cgimage);
    const size_t height = CGImageGetHeight(cgimage);
    const size_t bpr    = CGImageGetBytesPerRow(cgimage);
    const size_t bpp    = CGImageGetBitsPerPixel(cgimage);
    const size_t bpc    = CGImageGetBitsPerComponent(cgimage);
    const size_t bytes_per_pixel = bpp / bpc;
    
    const NSData* data = (NSData*)CGDataProviderCopyData(CGImageGetDataProvider(cgimage));
    const uint8_t* bytes = [data bytes];
    
    //printf("Pixel Data:\n");
    for(size_t row = 0; row < height; row++)
    {
        for(size_t col = 0; col < width; col++)
        {
            const uint8_t* pixel = &bytes[row * bpr + col * bytes_per_pixel];
            
            if (pixel[bytes_per_pixel - 1] == 0x00)
                return YES;
            
            for(size_t x = 0; x < bytes_per_pixel; x++)
            {
                //printf("%.2X", pixel[x]);
                //if( x < bytes_per_pixel - 1 )
                //    printf(",");
                
                
            }
            
        }
    }
    [data release];
    return NO;
}


-(CGFloat)adjustToNearestDesiredAngle;
{
    static const CGFloat DESIRED_ANGLE = 3.14159 / 4.0;
    const CGFloat angle = atan2(self.transform.b, self.transform.a);
    const CGFloat thefloat = (NSInteger)round(angle / DESIRED_ANGLE);
    return thefloat * DESIRED_ANGLE;
}


@end

/*
//not used, deprecated.
-(NSArray*)nearbyPuzzlePieces:(NSArray*)allPieces
{
    const float N = 1.2; //test rect is 1.2x bigger because no ones perfect
	const float width  = self.frame.size.width  * N;
	const float height = self.frame.size.height * N;
	const float x = self.frame.origin.x - (self.frame.size.width  - width)  / 2.0;
	const float y = self.frame.origin.y - (self.frame.size.height - height) / 2.0;
	const CGRect test = CGRectMake(x, y, width, height);
	
	NSPredicate *pred = [NSPredicate predicateWithBlock:^(id object, NSDictionary *bindings)
    {
        if (object == self) return NO; //don't want self in this
        
        MultiJigImageView *other = (MultiJigImageView*)object;
        
        const CGFloat otherAngle = atan2(other.transform.b, other.transform.a);
        const CGFloat thisAngle = atan2(self.transform.b, self.transform.a);
        static const CGFloat threshold = 3.14159 / 4.0;
        
        return (BOOL)(ABS(thisAngle - otherAngle) < threshold
                      && CGRectIntersectsRect(test, other.frame));
    }];
    
	return [allPieces filteredArrayUsingPredicate:pred];
}

//not used, deprecated
-(void)combineSelfWithOther:(MultiJigImageView*)other atOffset:(CGPoint)offset
{
    UIImage *image = [UIImage imageByCombining:self.image another:other.image atOffset:offset];
    self.frame = CGRectMake(MIN(self.frame.origin.x,other.frame.origin.x),
                            MIN(self.frame.origin.y,other.frame.origin.y),
                            MAX(self.frame.size.width,other.frame.size.width+ABS(offset.x)),
                            MAX(self.frame.size.height,other.frame.size.height+ABS(offset.y)));
    self.image = image;
}
*/

