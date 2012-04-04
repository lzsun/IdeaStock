//
//  XoomlNoteParser.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XoomlNote.h"
#import "AssociativeBulletinBoard.h"
#import "BulletinBoardAttributes.h"
#import "DDXML.h"

/*
 This is helper that handles parsing and working 
 with Xooml syntax
 */
@interface XoomlParser : NSObject


/*
 Create a note object from the contents of Xooml file
 specified in data
 */
//TODO maybe I should just return NSData * here too.
+ (XoomlNote *) xoomlNoteFromXML: (NSData *)data;

/*
 Converst the contents of a note object to Xooml xml data
 */
+ (NSData *) convertNoteToXooml: (XoomlNote *) note;

/*
 Creates the boilerplate Xooml bulletin baord document
 and returns it as NSData
 */
+ (NSData *) getEmptyBulletinBoardXooml;

/*
 Creates an empty xooml:associationToolAttribute for holding
 a note attribute
 */
+ (DDXMLElement *) xoomlForAssociationToolAttributeWithName: (NSString *) attributeName 

                                                    andType: (NSString *) attributeType; 

/*
 Creates an empty xooml:fragmentToolAttributes for holding
 an attribute
 */
+ (DDXMLElement *) xoomlForFragmentToolAttributeWithName: (NSString *) attributeName 
                                                 andType: (NSString *) attributeType;
/*
 Creates an note reference element. 
 */
+ (DDXMLNode *) xoomlForNoteRef: (NSString *) refID;

/*
 Returns the xPath for accessing a note with noteID
 */
+ (NSString *) xPathforNote: (NSString *) noteID;

+ (NSString *) xPathForBulletinBoardAttribute: (NSString *) attributeType;
/*
 Returns the xPath for accessing a framgment attribute with name and type
 specified. 
 */
+ (NSString *) xPathForFragmentAttributeWithName: (NSString *) attributeName
                                         andType: (NSString *) attributeType;


@end
