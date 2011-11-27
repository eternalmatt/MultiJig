//
//  MultiJigImageView.m
//  MultiJig
//
//  Created by Senn, Matthew on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MultiJigImageView.h"
#import "UIImageCategory.h"
@interface MultiJigImageView()
{
    CGPoint startingLocation;
    NSInteger nearestQuarterAngle;
}
@end

@implementation MultiJigImageView
@synthesize correctPlacement;
@synthesize previousRotation;

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled   = YES;
        
        startingLocation = CGPointMake(frame.origin.x+frame.size.width /2.0,
                                       frame.origin.y+frame.size.height/2.0);
        
        int degrees = arc4random() % 360;
        float radians = 3.14159 / 180.0 * degrees;
        self.transform = CGAffineTransformMakeRotation(radians);
        previousRotation = self.transform;
        
        
        static const CGFloat PI_OVER_TWO = 3.14159f / 2.0f;
        CGFloat angle = atan2(self.transform.b, self.transform.a);
        nearestQuarterAngle = round(angle * PI_OVER_TWO);
    }
    return self;
}


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
    [data release];
    
    int row = touch.x;
    int col = touch.y;
    int indexOfAlpha = row * bpr + col * bytes_per_pixel + bytes_per_pixel - 1;
    
    if (indexOfAlpha > width*height)
        return NO;
    else 
        return bytes[row * bpr + col * bytes_per_pixel + bytes_per_pixel - 1] < 0xFF;
    
    /*
    for(size_t row = 0; row < height; row++)
    {
        for(size_t col = 0; col < width; col++)
        {
            const uint8_t* pixel = &bytes[row * bpr + col * bytes_per_pixel];
            
            alphas[row * width + height] = pixel[bytes_per_pixel-1];
            printf("%.2X", alphas[row*width+height]);
                 
            //the alpha channel is pixel[bytes_per_pixel - 1]
        }
    }
    [data release];
    free(alphas);
    */
}

-(void)resetToStartingLocation
{
    previousRotation = CGAffineTransformIdentity;
    self.transform   = CGAffineTransformIdentity;
    self.center      = correctPlacement;
}



-(CGFloat)nearestQuarterAngle:(CGFloat)angle
{
    static const CGFloat PI_OVER_TWO = 3.14159 / 2.0;
    
    return round(angle / PI_OVER_TWO);
}


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


-(void)combineSelfWithOther:(MultiJigImageView*)other atOffset:(CGPoint)offset
{
    UIImage *image = [UIImage imageByCombining:self.image another:other.image atOffset:offset];
    self.frame = CGRectMake(MIN(self.frame.origin.x,other.frame.origin.x),
                            MIN(self.frame.origin.y,other.frame.origin.y),
                            MAX(self.frame.size.width,other.frame.size.width+ABS(offset.x)),
                            MAX(self.frame.size.height,other.frame.size.height+ABS(offset.y)));
    self.image = image;
}


@end

