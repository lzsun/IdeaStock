//
//  NoteView.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteView : UIView

-(void) scale:(CGFloat) scaleFactor;
@property (strong,nonatomic) NSString * text;
@end