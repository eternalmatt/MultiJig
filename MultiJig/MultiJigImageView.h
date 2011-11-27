//
//  MultiJigImageView.h
//  MultiJig
//
//  Created by Senn, Matthew on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MultiJigImageView : UIImageView
{
    CGPoint correctPlacement;
    CGAffineTransform previousRotation;
}

@property (nonatomic) CGPoint correctPlacement;
@property (nonatomic) CGAffineTransform previousRotation;

-(void)resetToStartingLocation;

-(CGFloat)nearestQuarterAngle:(CGFloat)angle;
-(void)combineSelfWithOther:(MultiJigImageView*)other atOffset:(CGPoint)offset;
-(NSArray*)nearbyPuzzlePieces:(NSArray*)allPieces;

-(BOOL)touchExistsOnTransparency:(CGPoint)touch;

@end
