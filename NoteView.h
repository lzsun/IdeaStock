//
//  NoteView.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BulletinBoardObject.h"
#import "NoteViewDelegate.h"

@interface NoteView : UIView <BulletinBoardObject>

@property (weak,nonatomic) id<NoteViewDelegate> delegate;

-(id) initNoteWithFrame:(CGRect) frame 
                  andText: (NSString *)text
                    andID:(NSString *)ID;

-(void) resetSize;

-(void) resizeToRect:(CGRect) rect Animate: (BOOL) animate;


@end
