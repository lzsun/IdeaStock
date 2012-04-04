//
//  XoomlBulletinBoardController.m
//  IdeaStock
//
//  Created by Ali Fathalian on 4/1/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "XoomlBulletinBoardController.h"
#import "DDXML.h"
#import "XoomlParser.h"

@interface XoomlBulletinBoardController()

//This is the actual xooml document that this object wraps around.
@property (nonatomic,strong) DDXMLDocument * document;
@end

@implementation XoomlBulletinBoardController 

@synthesize document = _document;
/*------------------------*
 Datasource Implementation
 *-----------------------*/

//TODO There may be some tidying up needed in the xooml file.
// to validate it and make sure its proper and also add some parts to it yourself
// as planz does
- (id) initWithData:(NSData *)data{
    
    self = [super init];
    //open the document from the data
    NSError * err = nil;
    self.document = [[DDXMLDocument alloc] initWithData:data options:0 error:&err];
    
    //TODO right now im ignoring err. I should use it 
    //to determine the error
    if (self.document == nil){
        NSLog(@"Error reading the note XML File");
        return nil;
    }
    
    return self;
}

-(id) initAsEmpty{
    
    //use this helper method to create xooml
    //for an empty bulletinboard
    NSData * emptyBulletinBoardDate =[XoomlParser getEmptyBulletinBoardXooml];
    
    //call designated initializer
    self = [self initWithData:emptyBulletinBoardDate];
    
    return self;
}

-(NSData *) getSerializableData{
    return [self.document XMLData];
}

/*------------------------
 Private helpers
 
 New bulletinboard structural functionality should be added here
 The bulletinboard object itself is oblivious of the 
 functionality that it can perform. 
 -------------------------*/

/*
 Finds a xml node element with noteID and returns it 
 */

- (DDXMLElement *) getNoteElementFor: (NSString *) noteID{
    //get the note fragment using xpath
    
    //xooml:association[@ID ="d391c321-4f25-4128-8a82-13dd5f268034"]
    //TODO this may not work maybe I shoud remove @ sign
    NSString * xPath = [XoomlParser xPathforNote:noteID];
    
    NSError * err;
    NSArray *notes = [self.document nodesForXPath: xPath error: &err];
    if (notes == nil){
        NSLog(@"Error reading the content from XML");
        return nil;
    }
    if ([notes count] == 0 ){
        NSLog(@"No Note Content exist for the given note");
        return nil;
    }
    
    return [notes lastObject];
    
}


/*
 The reason why there are static method names for linkage and stacking and etc
 instead of a dynamic attribute Type is that at some point in future the processes
 and elements for each type may be different for other. 
 */

/*
 Adds a linkage to note with noteID to note with note refID
 
 If the noteID is not valid this method returns without doing anything. 
 
 This method assumes that refNoteID is a valid refID. 
 */


#define XOOML_NOTE_TOOL_ATTRIBUTE @"xooml:associationToolAttributes"
#define ATTRIBUTE_NAME @"name"
#define ATTRIBUTE_TYPE @"type"
#define LINKAGE_TYPE @"linkage"

- (void) addLinkage: (NSString *) linkageName
             ToNote: (NSString *) noteID
WithReferenceToNote: (NSString *) refNoteID{
    //if the note doesn't exists return
    DDXMLElement * noteNode = [self getNoteElementFor:noteID];
    if (!noteNode) return;
    
    
    DDXMLNode * noteRef = [XoomlParser xoomlForNoteRef: refNoteID];
    //see if there already exists a linkage attribute and if so
    //add the noteRef to that element
    for (DDXMLElement * noteChild in [noteNode children]){
        if ([[noteChild name] isEqualToString:XOOML_NOTE_TOOL_ATTRIBUTE] &&
            [[[noteChild attributeForName:ATTRIBUTE_NAME] stringValue] isEqualToString:linkageName] && 
            [[[noteChild attributeForName:ATTRIBUTE_TYPE] stringValue] isEqualToString:LINKAGE_TYPE]){
            [noteChild addChild:noteRef];
            return;
            
        }
        
    }
    
    //a note linkage with the given name does not exist so we have to 
    //create it 
    DDXMLElement * linkageElement = [XoomlParser xoomlForAssociationToolAttributeWithName:linkageName andType:LINKAGE_TYPE];
    [linkageElement addChild:noteRef];
    [noteNode addChild:linkageElement];
    
    
}

/*
 Adds a stacking property with stackingName and the notes that are specified
 in the array note. 
 
 The array notes contains a list of noteIDs. 
 
 The method assumes that the stackingName is unique and if there exists
 another stacking with the same name adds it anyways. 
 
 Th method assumes the noteIDs passed in the NSArray notes are valid existing
 refNoteIDs. 
 */

#define STACKING_TYPE @"stacking"

- (void) addStackingWithName: (NSString *) stackingName
                   withNotes: (NSArray *) notes{
    DDXMLElement * stackingElement = [XoomlParser xoomlForFragmentToolAttributeWithName:stackingName andType:STACKING_TYPE];
    for (NSString * noteID in notes){
        DDXMLNode * note = [XoomlParser xoomlForNoteRef:noteID];
        [stackingElement addChild:note];
    }
    [[self.document rootElement] addChild:stackingElement];
    
    
}
/*
 Adds a grouping property with groupingName and the notes that are specified
 in the array note. 
 
 The array notes contains a list of noteIDs. 
 
 The method assumes that the groupingName is unique and if there exists
 another grouping with the same name adds it anyways. 
 
 Th method assumes the noteIDs passed in the NSArray notes are valid existing
 refNoteIDs. 
 */

#define GROUPING_TYPE @"grouping"

- (void) addGroupingWithName: (NSString *) groupingName
                   withNotes: (NSArray *) notes{
    DDXMLElement * groupingElement = [XoomlParser xoomlForFragmentToolAttributeWithName:groupingName andType:GROUPING_TYPE];
    for (NSString * noteID in notes){
        DDXMLNode * note = [XoomlParser xoomlForNoteRef:noteID];
        [groupingElement addChild:note];
    }
    [[self.document rootElement] addChild:groupingElement];
    
    
    
}

/*
 Adds a note with noteID to the stacking with stackingName. 
 
 If a stacking with stackingName does not exist, this method returns without
 doing anything. 
 
 This method assumes that the noteID is a valid noteID. 
 
 This method assumes that stackingName is unique. If there are more than
 one stacking with the stackingName it adds the note to the first stacking.
 */

- (void) addNote: (NSString *) noteID
      toStacking: (NSString *) stackingName{
    
    //get the xpath for the required attribute
    NSString * xPath = [XoomlParser xPathForFragmentAttributeWithName:stackingName andType:STACKING_TYPE];
    
    NSError * err;
    NSArray *attribtues = [self.document nodesForXPath: xPath error: &err];
    if (attribtues == nil){
        NSLog(@"Error reading the content from XML");
        return;
    }
    if ([attribtues count] == 0 ){
        NSLog(@"Fragment attribute is no avail :D");
        return;
    }

    DDXMLElement * bulletinBoardAttribute = [attribtues lastObject];
    DDXMLNode * noteRef = [XoomlParser xoomlForNoteRef:noteID];
    [bulletinBoardAttribute addChild:noteRef];
}


/*
 Adds a note with noteID to the grouping with groupingName. 
 
 If a grouping with groupingName does not exist, this method returns without
 doing anything. 
 
 This method assumes that the noteID is a valid noteID. 
 
 This method assumes that groupingName is unique. If there are more than
 one grouping with the groupingName it adds the note to the first stacking.
 */

- (void) addNote: (NSString *) noteID
      toGrouping: (NSString *) groupingName{
    //get the xpath for the required attribute
    NSString * xPath = [XoomlParser xPathForFragmentAttributeWithName:groupingName andType:GROUPING_TYPE];
    
    NSError * err;
    NSArray *attribtues = [self.document nodesForXPath: xPath error: &err];
    if (attribtues == nil){
        NSLog(@"Error reading the content from XML");
        return;
    }
    if ([attribtues count] == 0 ){
        NSLog(@"Fragment attribute is no avail :D");
        return;
    }
    
    DDXMLElement * bulletinBoardAttribute = [attribtues lastObject];
    DDXMLNode * noteRef = [XoomlParser xoomlForNoteRef:noteID];
    [bulletinBoardAttribute addChild:noteRef];
}


/*
 Deletes the linkage with linkageName for the note with NoteID. 
 
 Deleting the linkage removes all the notes whose refIDs appear in the linakge.
 
 If the noteID or the linkageName are invalid. This method returns without
 doing anything. 
 */

- (void) deleteLinkage: (NSString *) linkageName 
               forNote: (NSString *)noteID{
    
    DDXMLElement * noteNode = [self getNoteElementFor:noteID];
    
    //if the note is not found delete
    if (!noteNode) return;
    
    for (DDXMLElement * noteChild in [noteNode children]){
        if ([[noteChild name] isEqualToString:XOOML_NOTE_TOOL_ATTRIBUTE] &&
            [[[noteChild attributeForName:ATTRIBUTE_NAME] stringValue] isEqualToString:linkageName] && 
            [[[noteChild attributeForName:ATTRIBUTE_TYPE] stringValue] isEqualToString:LINKAGE_TYPE]){
            
            [noteNode removeChildAtIndex:[noteChild index]];
            return;
        }
        
    }
    
}


/*
 Delete the note with noteRefID from the linkage with linkageName belonging
 to the note with noteID.
 
 If the noteID, noteRefID, or linkageName are invalid this method returns
 without doing anything. 
 */

#define REF_ID @"refID"
- (void) deleteNote: (NSString *) noteRefID
        fromLinkage: (NSString *)linkageName
            forNote: (NSString *) noteID{
    DDXMLElement * noteNode = [self getNoteElementFor:noteID];
    
    //if the note is not found delete
    if (!noteNode) return;
    
    //for every child of the note see if it has the queried linkage
    //atribute. Then loop over all the children of the attribute to 
    //find the note to delete and then delete it. 
    for (DDXMLElement * noteChild in [noteNode children]){
        if ([[noteChild name] isEqualToString:XOOML_NOTE_TOOL_ATTRIBUTE] &&
            [[[noteChild attributeForName:ATTRIBUTE_NAME] stringValue] isEqualToString:linkageName] && 
            [[[noteChild attributeForName:ATTRIBUTE_TYPE] stringValue] isEqualToString:LINKAGE_TYPE]){
            
            for (DDXMLElement * noteRef in [noteChild children]){
                if ([[[noteRef attributeForName:REF_ID] stringValue] isEqualToString:noteRefID]){
                    [noteRef removeChildAtIndex:[noteRef index]];
                }
            }
            return;
        }
        
    }
    
    
}
/*
 Deletes the stacking with stackingName from the bulletin board. 
 
 This deletion removes any notes that the stacking with stackingName 
 refered to from the list of its attributes. 
 
 If the stackingName is invalid this method returns without doing anything.
 */

- (void) deleteStacking: (NSString *) stackingName{
    
    NSString * xPath = [XoomlParser xPathForFragmentAttributeWithName:stackingName andType:STACKING_TYPE];
    
    NSError * err;
    NSArray *attribtues = [self.document nodesForXPath: xPath error: &err];
    
    //if the stacking attribute does not exist return
    if (attribtues == nil || [attribtues count] == 0) return;
    
    DDXMLElement * bulletinBoardAttribute = [attribtues lastObject];
    DDXMLElement * attributeParent = (DDXMLElement *)[bulletinBoardAttribute parent];
    [attributeParent removeChildAtIndex:[bulletinBoardAttribute index]];

    
}

/*
 Deletes the note with noteID from the stacking with stackingName. 
 
 If the stackingName or noteID are invalid this method returns without
 doing anything.
 */

- (void) deleteNote: (NSString *) noteID
       fromStacking: (NSString *) stackingName{
    
    NSString * xPath = [XoomlParser xPathForFragmentAttributeWithName:stackingName andType:STACKING_TYPE];
    
    NSError * err;
    NSArray *attribtues = [self.document nodesForXPath: xPath error: &err];
    
    //if the stacking attribute does not exist return
    if (attribtues == nil || [attribtues count] == 0) return;
    
    DDXMLElement * bulletinBoardAttribute = [attribtues lastObject];
    
    for (DDXMLElement * element in [bulletinBoardAttribute children]){
        if ( [[[element attributeForName:REF_ID] stringValue] isEqualToString:noteID]){
            [bulletinBoardAttribute removeChildAtIndex:[element index]];
            return;
        }
    }
    
}
/*
 Deletes the grouping with groupingName from the bulletin board. 
 
 This deletion removes any notes that the grouping with grouping 
 refered to from the list of its attributes. 
 
 If the groupingName is invalid this method returns without doing anything.
 */


- (void) deleteGrouping: (NSString *) groupingName{
    
    NSString * xPath = [XoomlParser xPathForFragmentAttributeWithName:groupingName andType:GROUPING_TYPE];
    
    NSError * err;
    NSArray *attribtues = [self.document nodesForXPath: xPath error: &err];
    
    //if the stacking attribute does not exist return
    if (attribtues == nil || [attribtues count] == 0) return;
    
    DDXMLElement * bulletinBoardAttribute = [attribtues lastObject];
    DDXMLElement * attributeParent = (DDXMLElement *)[bulletinBoardAttribute parent];
    [attributeParent removeChildAtIndex:[bulletinBoardAttribute index]];

    
}

/*
 Deletes the note with noteID from the grouping with groupingName. 
 
 If the groupingName or noteID are invalid this method returns without
 doing anything.
 */

- (void) deleteNote: (NSString *) noteID
        fromGroupin: (NSString *) groupingName{
    
    NSString * xPath = [XoomlParser xPathForFragmentAttributeWithName:groupingName andType:GROUPING_TYPE];
    
    NSError * err;
    NSArray *attribtues = [self.document nodesForXPath: xPath error: &err];
    
    //if the stacking attribute does not exist return
    if (attribtues == nil || [attribtues count] == 0) return;
    
    DDXMLElement * bulletinBoardAttribute = [attribtues lastObject];
    
    for (DDXMLElement * element in [bulletinBoardAttribute children]){
        if ( [[[element attributeForName:REF_ID] stringValue] isEqualToString:noteID]){
            [bulletinBoardAttribute removeChildAtIndex:[element index]];
            return;
        }
    }
    
    
}

/*
 updates the name of linkage for note with noteID from linkageName
 to newLinkageName. 
 
 If the noteID or linkageName are invalid the method returns without 
 doing anything. 
 */

- (void) updateLinkageName: (NSString *) linkageName
                   forNote: (NSString *) noteID
               withNewName: (NSString *) newLinkageName{
    
}

/*
 Updates the name of a bulletin board stacking from stacking to 
 newStackingName. 
 
 If the stackingName is invalid the method returns without doing anything.
 */

- (void) updateStackingName: (NSString *) stackingName
                withNewName: (NSString *) newStackingName{
    
}
/*
 Updates the name of a bulletin board grouping from groupingName to 
 newGroupingName. 
 
 If the groupingName is invalid the method returns without doing anything.
 */

- (void) updateGroupingName: (NSString *) groupingName
                withNewName: (NSString *) newGroupingName{
    
}

- (NSDictionary *) getLinkageInfoForNote: (NSString *) noteID{
    
}

/*
 Returns all the stacking info for the bulletin board.
 
 A stacking info contain name of the stacking and an array of noteIDs that
 belong to that stacking. These are expressed as two keys name and refIDs.
 
 For Example: 
 {name="Stacking1", refIDs = {"NoteID2", "NoteID3"}}
 
 If no stacking infos exist the dictionary will be empty. 
 
 The method assumes that each stacking is uniquely identified with its name.
 As a result it only returns the first stacking with a given name and ignores 
 the rest. 
 */

- (NSDictionary *) getStackingInfo{
    
}

/*
 Returns all the grouping info for the bulletin board.
 
 A grouping info contain name of the grouping and an array of noteIDs that
 belong to that grouping. These are expressed as two keys name and refIDs.
 
 For Example: 
 {name="Grouping1", refIDs = {"NoteID2", "NoteID3"}}
 
 If no grouping infos exist the dictionary will be empty. 
 
 The method assumes that each grouping is uniquely identified with its name.
 As a result it only returns the first grouping with a given name and ignores 
 the rest. 
 */

- (NSDictionary *) getGroupingInfo{
    
}
@end
