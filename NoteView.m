//
//  NoteView.m
//  IdeaStock
//
//  Created by Ali Fathalian on 4/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "NoteView.h"

@interface NoteView()

/*========================================================================*/


/*-----------------------------------------------------------
 Modal Properties
 -----------------------------------------------------------*/

@property (nonatomic) CGRect originalFrame;
@property (nonatomic) CGRect lastFrame;

@end

/*========================================================================*/

@implementation NoteView

/*-----------------------------------------------------------
 Synthesizers
 -----------------------------------------------------------*/
#define STARTING_POS_OFFSET_X 0.07
#define STARTING_POS_OFFSET_Y 0.07
#define TEXT_WIDHT_RATIO 0.8
#define TEXT_HEIGHT_RATIO 0.75

@synthesize text = _text;
@synthesize highlighted = _highlighted;
@synthesize originalFrame = _originalFrame;
@synthesize highLightedImage = _highLightedImage;
@synthesize normalImage = _normalImage;
@synthesize lastFrame = _lastFrame;
@synthesize delegate = _delegate;
@synthesize ID = _ID;


-(void) setDelegate:(id<NoteViewDelegate>) delegate{
    _delegate = delegate;
}

-(UIImage *) normalImage{
    if (!_normalImage){
        _normalImage = [UIImage imageNamed:@"notelight.png"];
    }
    return _normalImage;
}


-(UIImage *) highLightedImage{
    
    if (! _highLightedImage){
        _highLightedImage = [UIImage imageNamed:@"noteselected.png"];
        
    }
    return _highLightedImage;
}

-(void) setHighlighted:(BOOL) highlighted{
    _highlighted = highlighted;
    
    for (UIView * subView in self.subviews){
        
        if (highlighted){
            if ([subView isKindOfClass:[UIImageView class]]){
                
                [((UIImageView *) subView) setImage:self.highLightedImage];
                [UIView animateWithDuration:0.20 animations:^{                [subView setTransform:CGAffineTransformMakeScale(1.2, 1.3)];}];                             
            }
        }
        else{
            if ([subView isKindOfClass:[UIImageView class]]){
                [((UIImageView *) subView) setImage:self.normalImage];
                [UIView animateWithDuration:0.20 animations:^{[subView setTransform:CGAffineTransformIdentity];}];
                
            }
            
        }
        
    }
}

-(void) setText:(NSString *) text{
    for (UIView * subView in self.subviews){
        if ([subView isKindOfClass:[UITextView class]]){
            ((UITextView *) subView).text = text;
            return;
        }
    }
}

-(NSString *) text{
    for (UIView * subView in self.subviews){
        if ([subView isKindOfClass:[UITextView class]]){
            return ((UITextView *) subView).text;
        }
    }
    return nil;
    
    
}

/*========================================================================*/

/*-----------------------------------------------------------
 Initializers
 -----------------------------------------------------------*/

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.originalFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
        UIImageView * imageView = [[UIImageView alloc] initWithImage:self.normalImage];
        imageView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
        
        CGRect textFrame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * STARTING_POS_OFFSET_X ,
                                      self.bounds.origin.y + self.bounds.size.height * STARTING_POS_OFFSET_Y,
                                      self.bounds.size.width * TEXT_WIDHT_RATIO, self.bounds.size.height * TEXT_HEIGHT_RATIO);
        UITextView * textView = [[UITextView alloc] initWithFrame:textFrame];
        textView.font = [UIFont fontWithName:@"Cochin" size:17.0];
        [textView setBackgroundColor:[UIColor clearColor]];
        
        textView.delegate = self;
        [self addSubview:imageView];
        [self addSubview:textView];
        self.text = @"Tap To Edit Note";
        // self.backgroundColor = [UIColor blueColor];
    }
    return self;
}

-(id) initNoteWithFrame:(CGRect) frame 
                andText: (NSString *)text
                  andID:(NSString *)ID{
    self = [self initWithFrame:frame];
    self.text = text;
    self.ID = ID;
    
    return self;
}

/*-----------------------------------------------------------
 Layout Methods
 -----------------------------------------------------------*/

-(void) resetSize{
    [self setFrame: self.originalFrame];
    for (UIView * subView in self.subviews){
        if ([subView isKindOfClass:[UIImageView class]]){
            subView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
            
        }
        else if ([subView isKindOfClass:[UITextView class]]){
            subView.frame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * STARTING_POS_OFFSET_X ,
                                       self.bounds.origin.y + self.bounds.size.height * STARTING_POS_OFFSET_Y,
                                       self.bounds.size.width * TEXT_WIDHT_RATIO, self.bounds.size.height * TEXT_HEIGHT_RATIO);
        }
    }
}

-(void) scale:(CGFloat) scaleFactor{
    
    
    if ( self.frame.size.width * scaleFactor > self.originalFrame.size.width * 2||
        self.frame.size.height * scaleFactor > self.originalFrame.size.height * 2){
        return;
    }
    if ( self.frame.size.width * scaleFactor < self.originalFrame.size.width * 0.9 ||
        self.frame.size.height * scaleFactor < self.originalFrame.size.height * 0.9){
        return;
    }
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y, 
                            self.frame.size.width * scaleFactor,
                            self.frame.size.height * scaleFactor);
    for (UIView * subView in self.subviews){
        
        if ([subView isKindOfClass:[UIImageView class]]){
            subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y, subView.frame.size.width * scaleFactor, subView.frame.size.height * scaleFactor);
            
        }
        else if ([subView isKindOfClass:[UITextView class]]){
            //doing this to make the text clearer instead of resizing an existing UITextView
            NSString * oldText = ((UITextView *)subView).text;
            CGRect textFrame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * STARTING_POS_OFFSET_X ,
                                          self.bounds.origin.y + self.bounds.size.height * STARTING_POS_OFFSET_Y,
                                          self.bounds.size.width * TEXT_WIDHT_RATIO, self.bounds.size.height * TEXT_HEIGHT_RATIO);
            UITextView * textView = [[UITextView alloc] initWithFrame:textFrame];
            textView.font = [UIFont fontWithName:@"Cochin" size:17.0];
            
            [textView setBackgroundColor:[UIColor clearColor]];
            
            textView.textColor = ((UITextView *)subView).textColor;
            textView.text = oldText;
            
            textView.delegate = self;
            [subView removeFromSuperview];
            
            [self addSubview:textView];
            
        }
    }
}

-(void) resizeToRect:(CGRect)rect Animate: (BOOL) animate{
    if (animate){
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = rect;
            for (UIView * subView in self.subviews){
                if ([subView isKindOfClass:[UIImageView class]]){
                    subView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
                }
                else if ([subView isKindOfClass:[UITextView class]]){
                    //doing this to make the text clearer instead of resizing an existing UITextView
                    NSString * oldText = ((UITextView *)subView).text;
                    CGRect textFrame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * STARTING_POS_OFFSET_X ,
                                                  self.bounds.origin.y + self.bounds.size.height * STARTING_POS_OFFSET_Y,
                                                  self.bounds.size.width * TEXT_WIDHT_RATIO, self.bounds.size.height * TEXT_HEIGHT_RATIO);
                    UITextView * textView = [[UITextView alloc] initWithFrame:textFrame];
                    textView.font = [UIFont fontWithName:@"Cochin" size:17.0];
                    textView.textColor = ((UITextView *)subView).textColor;
                    
                    [textView setBackgroundColor:[UIColor clearColor]];
                    
                    textView.text = oldText;
                    textView.delegate = self;
                    
                    [subView removeFromSuperview];
                    
                    [self addSubview:textView];
                }
            }
            
        }
         ];
    }
    else {
        self.frame = rect;
        for (UIView * subView in self.subviews){
            if ([subView isKindOfClass:[UIImageView class]]){
                subView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
            }
            else if ([subView isKindOfClass:[UITextView class]]){
                //doing this to make the text clearer instead of resizing an existing UITextView
                NSString * oldText = ((UITextView *)subView).text;
                CGRect textFrame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * STARTING_POS_OFFSET_X ,
                                              self.bounds.origin.y + self.bounds.size.height * STARTING_POS_OFFSET_Y,
                                              self.bounds.size.width * TEXT_WIDHT_RATIO, self.bounds.size.height * TEXT_HEIGHT_RATIO);
                UITextView * textView = [[UITextView alloc] initWithFrame:textFrame];
                
                textView.textColor = ((UITextView *)subView).textColor;
                [textView setBackgroundColor:[UIColor clearColor]];
                
                textView.text = oldText;
                
                
                
                [subView removeFromSuperview];
                
                [self addSubview:textView];
            }
        }
    }
    
}


/*-----------------------------------------------------------
 Keyboard methods
 -----------------------------------------------------------*/

-(void) resignFirstResponder{
    for (UIView * subView in self.subviews){
        if ([subView isKindOfClass:[UITextView class]]){
            if (subView.isFirstResponder){
                [subView resignFirstResponder];
            }
        }
    }
}
/*-----------------------------------------------------------
 textViewDelegate
 -----------------------------------------------------------*/

-(void) textViewDidEndEditing:(UITextView *)textView{
    NSString * text = textView.text;
    [self.delegate note:self changedTextTo:text];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Tap To Edit Note"]){
        textView.text = @"";
    }
}
@end
