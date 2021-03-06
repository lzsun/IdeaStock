//
//  ImageView.m
//  IdeaStock
//
//  Created by Ali Fathalian on 5/27/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "ImageView.h"

@interface ImageView()


@property UIImageView * imageView;

@end

@implementation ImageView

@synthesize image = _image;
@synthesize imageView = _imageView;

#define IMG_OFFSET_X_RATE 0.055
#define IMG_OFFSET_Y_RATE 0.075
#define IMG_SIZE_WIDTH_RATIO 0.865
#define IMG_SIZE_HEIGHT_RATIO 0.82

-(id) initWithFrame:(CGRect)frame 
           andImage:(UIImage *)image{
    self = [super initWithFrame:frame];
    if (self){
        
        self.text = @"";
        for (UIView * view in self.subviews){
            if ([view isKindOfClass:[UITextView class]]){
                ((UITextView *) view).textColor = [UIColor whiteColor];
            }
            else if ([view isKindOfClass:[UIImageView class]]){
                UIImageView * newImage = [[UIImageView alloc] initWithImage:image];
                newImage.frame = CGRectMake(view.frame.origin.x + view.frame.size.width * IMG_OFFSET_X_RATE,
                                            view.frame.origin.y + view.frame.size.height * IMG_OFFSET_Y_RATE,
                                            view.frame.size.width * IMG_SIZE_WIDTH_RATIO,
                                            view.frame.size.height * IMG_SIZE_HEIGHT_RATIO);
                [view addSubview:newImage];
                self.image = image;
                self.imageView = newImage;
            }
        }
        
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


-(void) scale:(CGFloat) scaleFactor{

    [super scale:scaleFactor];
    UIImageView * newImage = [[UIImageView alloc] initWithImage:self.image];
   newImage.frame = CGRectMake(self.imageView.superview.frame.origin.x + self.imageView.superview.frame.size.width * IMG_OFFSET_X_RATE,
                                self.imageView.superview.frame.origin.y + self.imageView.superview.frame.size.height * IMG_OFFSET_Y_RATE,
                                self.imageView.superview.frame.size.width * IMG_SIZE_WIDTH_RATIO,
                                self.imageView.superview.frame.size.height * IMG_SIZE_HEIGHT_RATIO);
    UIView * superView = [self.imageView superview];
    [self.imageView removeFromSuperview];
    [superView addSubview:newImage];
    self.imageView = newImage;
}

-(void) resetSize{
    [super resetSize];
    self.imageView.frame = CGRectMake(self.imageView.superview.frame.origin.x + self.imageView.superview.frame.size.width * IMG_OFFSET_X_RATE,
                                      self.imageView.superview.frame.origin.y + self.imageView.superview.frame.size.height * IMG_OFFSET_Y_RATE,
                                      self.imageView.superview.frame.size.width * IMG_SIZE_WIDTH_RATIO,
                                      self.imageView.superview.frame.size.height * IMG_SIZE_HEIGHT_RATIO);
}

-(void)resizeToRect:(CGRect)rect Animate:(BOOL)animate{

    [super resizeToRect:rect Animate:animate];
    UIImageView * newImage = [[UIImageView alloc] initWithImage:self.image];
    newImage.frame = CGRectMake(self.imageView.superview.frame.origin.x + self.imageView.superview.frame.size.width * IMG_OFFSET_X_RATE,
                                self.imageView.superview.frame.origin.y + self.imageView.superview.frame.size.height * IMG_OFFSET_Y_RATE,
                                self.imageView.superview.frame.size.width * IMG_SIZE_WIDTH_RATIO,
                                self.imageView.superview.frame.size.height * IMG_SIZE_HEIGHT_RATIO);
    UIView * superView = [self.imageView superview];
    [self.imageView removeFromSuperview];
    [superView addSubview:newImage];
    self.imageView = newImage;
}

@end
