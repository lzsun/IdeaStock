//
//  ImageView.m
//  IdeaStock
//
//  Created by Ali Fathalian on 5/27/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "ImageView.h"

@implementation ImageView

-(id) initWithFrame:(CGRect)frame 
           andImage:(UIImage *)image{
    self = [super initWithFrame:frame];
    if (self){
        
        self.text = @"";
        self.normalImage = image;
        self.highLightedImage = image;
        self.highlighted = NO;
    }
    
    return self;
}

-(id) initWithFrame:(CGRect)frame 
           andImage:(UIImage *)image 
              andID:(NSString *)ID{
    self = [self initWithFrame:frame andImage:image];
    if (self){
        self.ID = ID;
    }
    return self;
}

@end
