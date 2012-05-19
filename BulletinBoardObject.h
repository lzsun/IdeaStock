//
//  BulletinBoardObject.h
//  IdeaStock
//
//  Created by Ali Fathalian on 5/16/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BulletinBoardObject <NSObject>

-(void) scale:(CGFloat) scaleFactor;
@property (strong,nonatomic) NSString * text;
@property (nonatomic) BOOL highlighted;


@end