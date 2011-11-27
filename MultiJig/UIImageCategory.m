//
//  UIImageCategory.m
//  MultiJig
//
//  Created by Senn, Matthew on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImageCategory.h"

@implementation UIImage (UIImageCategory)

//written by Matt Senn with help from http://stackoverflow.com/questions/679245/create-a-uiimage-from-two-other-uiimages-on-the-iphone
+(UIImage*)imageByCombining:(UIImage*)one another:(UIImage*)two atOffset:(CGPoint)offset
{
    CGSize size = CGSizeMake(MAX(one.size.width,  two.size.width) + ABS(offset.x),
                             MAX(one.size.height, two.size.height)+ ABS(offset.y));
     
    CGPoint onePoint, twoPoint;
    if (offset.x < 0.0)
        if (offset.y < 0.0){
            onePoint = offset;
            twoPoint = CGPointZero;
        }
        else{
            onePoint = CGPointMake(0,offset.y);
            twoPoint = CGPointMake(offset.x,0);
        }
    else
        if (offset.y < 0.0){
            onePoint = CGPointMake(offset.x,0);
            twoPoint = CGPointMake(0,offset.y);
        }
        else{
            onePoint = CGPointZero;
            twoPoint = offset;
        }
    
    
    UIGraphicsBeginImageContext(size);
    [one drawAtPoint:onePoint];
    [two drawAtPoint:twoPoint];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();  //returns autoreleased
    UIGraphicsEndImageContext();
    
    return result;
}


//written by Matt Senn
+(UIImage*)imageByCroppingImage:(UIImage*)image inRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    
    return result;
}

//written by Matt Senn
-(NSMutableArray*)getRectangularPuzzlePiecesWithRows:(NSUInteger)row andColumns:(NSUInteger)col
{
    const CGFloat rowDiff = self.size.width  / ((CGFloat)row);
    const CGFloat colDiff = self.size.height / ((CGFloat)col);
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:row*col];
    
    
    for(CGFloat i=0; i < self.size.width; i += rowDiff)      
        for(CGFloat j=0; j < self.size.height; j += colDiff)      
        {
            UIImage *cropped = [UIImage imageByCroppingImage:self inRect:CGRectMake(i, j, rowDiff, colDiff)];
            [array addObject:cropped];
        }
    
    return [array autorelease];
}

@end
