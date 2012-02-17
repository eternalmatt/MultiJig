//
//  MJGameModel.h
//  MultiJig
//
//  Created by Matthew Senn on 11/26/11.
//  Copyright (c) 2011 UNC Charlotte. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MJModelDelegate <NSObject>
@required
-(void)combinePiece:(id)one withOther:(id)other;
-(void)userDidSolvePuzzle;
@end


@interface MJGameModel : NSObject
@property (nonatomic, assign) id<MJModelDelegate> delegate;
@property (nonatomic) CGSize pieceSize;

-(void)setGamePiece:(id)piece
     atGridPosition:(CGPoint)point;

-(void)setGamePiece:(id)piece
    atWorldPosition:(CGPoint)worldPosition;

-(void)updateWithView:(id)view
          andSelected:(BOOL)selected;

-(void)combinePieces:(id)one 
            andOther:(id)two 
             intoNew:(id)newView;



@end



