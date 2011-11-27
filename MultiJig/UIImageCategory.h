//
//  UIImageCategory.h
//  MultiJig
//
//  Created by Senn, Matthew on 11/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (UIImageCategory)


+(UIImage*)imageByCombining:(UIImage*)one another:(UIImage*)another atOffset:(CGPoint)point;
+(UIImage*)imageByCroppingImage:(UIImage*)image inRect:(CGRect)rect;
-(NSMutableArray*)getRectangularPuzzlePiecesWithRows:(NSUInteger)row andColumns:(NSUInteger)col;

@end
