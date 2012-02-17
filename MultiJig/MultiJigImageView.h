//
//  MultiJigImageView.h
//  MultiJig
//
//  Created by Senn, Matthew on 11/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MJGestureDelegate <NSObject>
@required
-(void)panToMatchGesture:(UIPanGestureRecognizer*)gesture;
-(void)rotateToMatchGesture:(UIRotationGestureRecognizer*)gesture;
-(void)tapToMatchGesture:(UITapGestureRecognizer*)gesture;

@end


@interface MultiJigImageView : UIImageView <NSCopying>
@property (nonatomic) NSInteger grid_x;
@property (nonatomic) NSInteger grid_y;
@property (nonatomic) CGAffineTransform previousRotation;
@property (nonatomic) BOOL selected;

-(void)setDelegate:(id<MJGestureDelegate, UIGestureRecognizerDelegate>)delegate;

-(CGFloat)adjustToNearestDesiredAngle;

-(id)initWithFrame:(CGRect)frame;// this is the designated initializer or whatever
-(id)initByCombining:(id)oneView 
            andOther:(id)twoView 
     withRegularSize:(CGSize)pieceSize;


/* these three methods don't work and are deprecated */
-(BOOL)touchExistsOnTransparency:(CGPoint)touch;
//-(void)combineSelfWithOther:(MultiJigImageView*)other atOffset:(CGPoint)offset;
//-(NSArray*)nearbyPuzzlePieces:(NSArray*)allPieces;

@end
