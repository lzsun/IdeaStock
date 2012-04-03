//
//  XoomlBulletinBoard.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/30/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "AssociativeBulletinBoard.h"
#import "XoomlParser.h"
#import "BulletinBoardDelegate.h"
#import "BulletinBoardDatasource.h"
#import "XoomlBulletinBoardController.h"

@interface AssociativeBulletinBoard()

/*
 Holds the actual individual note contents. This dictonary is keyed on the noteID.
 
 The noteIDs in this dictionary determine whether a note belongs to this bulletin board or not. 
 */
@property (nonatomic,strong) NSMutableDictionary <Note> * noteContents;


/*
 holds all the attributes that belong to the bulletin board level: for example stack groups. 
 */
@property (nonatomic,strong) BulletinBoardAttributes * bulletinBoardAttributes;


/*
 This is an NSDictionary of BulletinBoardAttributes. Its keyed on the noteIDs.
 
 For each noteID,  this contains all of the note level attributes that are
 associated with that particular note.
 */
@property (nonatomic,strong) NSMutableDictionary * noteAttributes;



/*
 This is the datamodel that the bulletin board uses for retrieval and storage of itself. 
 */
@property (nonatomic,strong) id<DataModel> dataModel;

/*
 This delegate object provides information for all of the data specific 
 questions that the bulletin baord may ask. 
 
 Properties of the bulletin board are among these data specific questions. 
 */
@property (nonatomic,strong) id <BulletinBoardDelegate> delegate;


@property (nonatomic,strong) id <BulletinBoardDatasource> dataSource;

@end
@implementation AssociativeBulletinBoard

@synthesize dataModel = _dataModel;
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize noteAttributes = _noteAttributes;
@synthesize bulletinBoardAttributes = _bulletinBoardAttributes;
@synthesize noteContents = _noteContents;

/*
 These are the default attributes for note
 Add new ones here. 
 */
//TODO  some of these definition may need to go to a higher level header
// or even inside a definitions file
#define POSITION_X @"positionX"
#define POSITION_Y @"positionY"
#define IS_VISIBLE @"isVisible"

#define POSITION_TYPE @"position"
#define VISIBILITY_TYPE @"visibility"
#define LINKAGE_TYPE @"linkage"
#define STACKING_TYPE @"stacking"
#define GROUPING_TYPE @"grouping"
#define NOTE_NAME_TYPE @"name"

#define DEFAULT_X_POSITION @"0"
#define DEFAULT_Y_POSITION @"0"
#define DEFAULT_VISIBILITY  @"true"
#define NOTE_NAME @"name"
#define NOTE_ID @"ID"

#define LINKAGE_NAME @"name"
#define STACKING_NAME @"name"
#define REF_IDS @"refIDs"

/*
 Factory method for the bulletin board attributes
 */
-(BulletinBoardAttributes *) createBulletinBoardAttributeForBulletinBoard{
        return [[BulletinBoardAttributes alloc] initWithAttributes:[NSArray arrayWithObjects:STACKING_TYPE,GROUPING_TYPE, nil]];
}

/*
 Factory method for the note bulletin board attributes
 */
-(BulletinBoardAttributes *) createBulletinBoardAttributeForNotes{
    return [[BulletinBoardAttributes alloc] initWithAttributes:[NSArray arrayWithObjects:LINKAGE_TYPE,POSITION_TYPE, VISIBILITY_TYPE, nil]];
}
-(id)initEmptyBulletinBoardWithDataModel: (id <DataModel>) dataModel{
    
    self = [super init];
    
    self.dataModel = dataModel;
    
    //create an empty bulletinBoard controller and make it both delegate
    //and the datasource
    id bulletinBoardController = [[XoomlBulletinBoardController alloc] initAsEmpty];
    self.dataSource = bulletinBoardController;
    self.delegate = bulletinBoardController;
    
    self.noteContents = [NSMutableDictionary dictionary];
    
    //initialize the bulletin board attributes with stacking and grouping
    //to add new attributes first define them in the header file and the
    //initilize the bulletinBoardAttributes with an array of them
    self.bulletinBoardAttributes = [self createBulletinBoardAttributeForBulletinBoard];
    
    //initialize the note attributes dictionary as an empty dictionary
    self.noteAttributes = [NSMutableDictionary dictionary];
    
    return self;
    
}

/*
 Initilizes the bulletin board with the content of a xooml file for a previously
 created bulletinboard. 
 */

//TODO this initializer is getting to heavy weight
-(id) initBullrtinBoardFromXoomlDatamodel:(id<DataModel>)datamodel andName:(NSString *)bulletinBoardName{
    
    //initialize as an empty bulletin board
    self = [self initEmptyBulletinBoardWithDataModel:datamodel];
    
    //Now we will initialize the innards of the class one by one
    
    //First get the xooml file for the bulletinboard as NSData from
    //the datamodel
    NSData * bulletinBoardData = [datamodel getBulletinBoard:bulletinBoardName];  
    
    //Initialize the bulletinBoard controller to parse and hold the 
    //tree for the bulletin board
    id bulletinBoardController= [[XoomlBulletinBoardController alloc]  initWithData:bulletinBoardData];
    
    //Make the bulletinboard controller the datasource and delegate
    //for the bulletin board so the bulletin board can structural and
    //data centric questions from it.
    self.dataSource = bulletinBoardController;
    self.delegate = bulletinBoardController;
    
    //Now start to initialize the bulletin board attributes one by one
    //from the delegate.
    
    
    //First Note properties
    
    //Get all the note info for all the notes in the bulletinBoard
    NSDictionary * noteInfo = [self.delegate getAllNoteBasicInfo];
   
    for (NSString * noteID in noteInfo){
        //for each note create a note Object by reading its separate xooml files
        //from the data model
        NSString * noteName = [[noteInfo objectForKey:noteID] objectForKey:NOTE_NAME];
        NSData * noteData = [self.dataModel getNoteForTheBulletinBoard:bulletinBoardName WithName:noteName];
        id <Note> noteObj = [XoomlParser xoomlNoteFromXML:noteData];
        
        //now set the note object as a noteContent keyed on its id
        [self.noteContents setObject:noteObj forKey:noteID];
        
        //now initialize the bulletinBoard attributes to hold all the 
        //note specific attributes for that note
        BulletinBoardAttributes * noteAttribute = [self createBulletinBoardAttributeForNotes];
        //get the note specific info from the note basic info
        NSString * positionX = [noteInfo objectForKey: POSITION_X];
        if (!positionX ) positionX = DEFAULT_X_POSITION;
        NSString * positionY = [noteInfo objectForKey: POSITION_Y];
        if (!positionY) positionY = DEFAULT_Y_POSITION;
        NSString * isVisible = [noteInfo objectForKey:IS_VISIBLE];
        if (! isVisible) isVisible = DEFAULT_VISIBILITY;
        
        //Fill out the note specific attributes for that note in the bulletin
        //board
        [noteAttribute createAttributeWithName:POSITION_X forAttributeType: POSITION_TYPE andValues:[NSArray arrayWithObject: positionX ]];
        [noteAttribute createAttributeWithName:POSITION_Y forAttributeType:POSITION_TYPE andValues:[NSArray arrayWithObject:positionY]];
        [noteAttribute createAttributeWithName:IS_VISIBLE forAttributeType:VISIBILITY_TYPE andValues:[NSArray arrayWithObject:isVisible]];
        [noteAttribute createAttributeWithName:NOTE_NAME forAttributeType: NOTE_NAME_TYPE andValues:[NSArray arrayWithObject: noteName ]];
        
        [self.noteAttributes setObject:noteAttribute forKey:noteID];
    }
    //now we have note contents set up 
    
    //For every note in the note content get all the linked notes and 
    //add them to the note attributes only if that referenced notes
    //in that linkage are exisiting in the note contents. 
    for (NSString * noteID in self.noteContents){
        NSDictionary *linkageInfo = [self.delegate getLinkageInfoForNote:noteID];
        NSArray * refIDs = [linkageInfo objectForKey:REF_IDS];
        NSString * linkageName = [linkageInfo objectForKey:LINKAGE_NAME];
        
        for (NSString * refID in refIDs){
            if (![self.noteContents objectForKey:refID]){
                [[self.noteAttributes objectForKey:noteID] addValues:[NSArray arrayWithObject:refID] ToAttribute:linkageName forAttributeType:LINKAGE_TYPE];
                
            }
        }
        
    }

    //Now we have all the note specific attributes stored
    
    
    //Setup bulletinboard attributes
    
    //get the stacking information and fill out the stacking attributes
    NSDictionary *stackingInfo = [self.delegate getStackingInfo];
    for (NSString * stackingName in stackingInfo){
        NSArray * refIDs = [stackingInfo objectForKey:REF_IDS];
        for (NSString * refID in refIDs){
            if(![self.noteContents objectForKey:refIDs]){
                [self.bulletinBoardAttributes addValues:[NSArray arrayWithObject:refID] ToAttribute:stackingName forAttributeType:STACKING_TYPE];
            }
        }
    }
    
    //get the grouping information and fill out the grouping info
    NSDictionary *groupingInfo = [self.delegate getGroupingInfo];
    for (NSString * groupingName in groupingInfo){
        NSArray * refIDs = [groupingInfo objectForKey:REF_IDS];
        for (NSString * refID in refIDs){
            if(![self.noteContents objectForKey:refIDs]){
                [self.bulletinBoardAttributes addValues:[NSArray arrayWithObject:refID] ToAttribute:groupingName forAttributeType:GROUPING_TYPE];
            }
        }
    }
    
    return self;    
}

- (void) addNoteContent: (id <Note>) note 
          andProperties: (NSDictionary *) properties{
    
    //get note Name and note ID if they are not present throw an exception
    NSString * noteID = [properties objectForKey:NOTE_ID];
    NSString * noteName = [properties  objectForKey:NOTE_NAME];
    if (!noteID || !noteName) [NSException raise:NSInvalidArgumentException
                             format:@"A Values is missing from the required properties dictionary"];
    
    //set the note content for the noteID
    [self.noteContents setObject:note forKey:noteID];
    
    //get other optional properties for the note. 
    //If they are not present use default values
    NSString * positionX = [properties objectForKey:POSITION_X];
    if (!positionX) positionX = DEFAULT_X_POSITION;
    NSString * positionY = [properties objectForKey:POSITION_Y];
    if (!positionY) positionY = DEFAULT_Y_POSITION;
    NSString * isVisible = [properties objectForKey:IS_VISIBLE];
    if(!isVisible) isVisible = DEFAULT_VISIBILITY;
    
    //create a dictionary of note properties
    NSDictionary *noteProperties = [NSDictionary dictionaryWithObjectsAndKeys:noteName,NOTE_NAME,
                                               noteID,NOTE_ID,
                                               positionX,POSITION_X,
                                               positionY, POSITION_Y,
                                               isVisible,IS_VISIBLE,
                                               nil];
    
    //have the delegate hold the structural information about the note
    [self.delegate addNoteWithID:noteID andProperties:noteProperties];
    
    //have the notes bulletin board attribute list for the note hold the note
    //properties
    BulletinBoardAttributes * noteAttribute = [self createBulletinBoardAttributeForNotes];
    [noteAttribute createAttributeWithName:NOTE_NAME forAttributeType: NOTE_NAME_TYPE andValues:[NSArray arrayWithObject: noteName ]];
    [noteAttribute createAttributeWithName:POSITION_X forAttributeType: POSITION_TYPE andValues:[NSArray arrayWithObject: positionX ]];
    [noteAttribute createAttributeWithName:POSITION_Y forAttributeType:POSITION_TYPE andValues:[NSArray arrayWithObject:positionY]];
    [noteAttribute createAttributeWithName:IS_VISIBLE forAttributeType:VISIBILITY_TYPE andValues:[NSArray arrayWithObject:isVisible]];
    
    [self.noteAttributes setObject:noteAttribute forKey:noteID];

}

- (void) addNoteAttribute: (NSString *) attributeName
         forAttributeType: (NSString *) attributeType
                  forNote: (NSString *) noteID 
                andValues: (NSArray *) values{
    
    //if the noteID is invalid return
    if(![self.noteContents objectForKey:noteID]) return;
    
    //get the noteattributes for the specified note. If there are no attributes for that
    //note create a new bulletinboard attribute list.
    BulletinBoardAttributes * noteAttributes = [self.noteAttributes objectForKey:noteID];
    if(!noteAttributes) noteAttributes = [self createBulletinBoardAttributeForNotes];
    
    //add the note attribute to the attribute list of the notes
    [noteAttributes createAttributeWithName:attributeName forAttributeType:attributeType andValues:values];
    
    //have the delegate reflect the changes in its struture
    [self.delegate addNoteAttribute:attributeName forType:attributeType forNote:noteID withValues:values];
        
}

- (void) addNote: (NSString *) targetNoteID
 toAttributeName: (NSString *) attributeName
forAttributeType: (NSString *) attributeType
          ofNote: (NSString *) sourceNoteId{

    //if the targetNoteID and sourceNoteID are invalid return
    if (![self.noteContents objectForKey:targetNoteID] || ![self.noteContents objectForKey:sourceNoteId]) return;
    
    // add the target noteValue to the source notes attribute list
    [[self.noteAttributes objectForKey:sourceNoteId] addValues:[NSArray arrayWithObject:targetNoteID] ToAttribute:attributeName forAttributeType:attributeType];
    
    //have the delegate reflect the changes in its struture
    [self.delegate addNoteAttribute:attributeName forType:attributeType forNote:sourceNoteId withValues:[NSArray arrayWithObject:targetNoteID]];
}

- (void) addBulletinBoardAttribute: (NSString *) attributeName
                  forAttributeType: (NSString *) attributeType{
    //add the attribtue to the bulletinBoard attribute list
    [self.bulletinBoardAttributes createAttributeWithName:attributeName forAttributeType:attributeType];
    
    //have the delegate reflect the change in its structure
    [self.delegate addBulletinBoardAttribute:attributeName forType:attributeType withValues:[NSArray array]];
}

- (void) addNoteWithID:(NSString *)noteID 
toBulletinBoardAttribute:(NSString *)attributeName 
     forAttributeType:(NSString *)attributeType{
    
    //if the noteID is invalid return
    if (![self.noteContents objectForKey:noteID]) return;
    
    //add the noteID to the bulletinboard attribute
    [self.bulletinBoardAttributes addValues:[NSArray arrayWithObject:noteID] ToAttribute:attributeName forAttributeType:attributeType];
        
    //have the delegate reflect the change in its structure
    [self.delegate addBulletinBoardAttribute:attributeName forType:attributeType withValues:[NSArray arrayWithObject:noteID]];
}

- (void) removeNoteWithID:(NSString *)delNoteID{

    //if the note does not exist return
    if (![self.noteContents objectForKey:delNoteID]) return;
    
    //remove the note content
    [self.noteContents removeObjectForKey:delNoteID];
    
    //remove All the references in the note attributes
    for (NSString * noteID in self.noteAttributes){
        [[self.noteAttributes objectForKey:noteID] removeAllOccurancesOfValue:delNoteID];
    }
    
    //remove all the references in the bulletinboard attributes
    [self.bulletinBoardAttributes removeAllOccurancesOfValue:delNoteID];
    
    //remove all the occurances in the xooml file
    [self.delegate deleteNote:delNoteID];
    
}

- (void) removeNote: (NSString *) targetNoteID
      fromAttribute: (NSString *) attributeName
             ofType: (NSString *) attributeType
   fromAttributesOf: (NSString *) sourceNoteID{

    //if the targetNoteID and sourceNoteID do not exist return
    if (![self.noteContents objectForKey:targetNoteID] || ![self.noteContents objectForKey:sourceNoteID]) return;
    
    //remove the note from note attributes
    [[self.noteAttributes objectForKey:sourceNoteID] removeNote:targetNoteID fromAttribute:attributeName ofType:attributeType fromAttributesOf:sourceNoteID];
    
    //reflect the changes in the xooml structure
    [self.delegate deleteNote:targetNoteID fromNoteAttribute:attributeName ofType:attributeType forNote:sourceNoteID];
}

- (void) removeNoteAttribute: (NSString *) attributeName
                      ofType: (NSString *) attributeType
                    FromNote: (NSString *) noteID{
    //if the noteID is not valid return
    if (![self.noteContents objectForKey:noteID]) return;
    
    //remove the note attribute from the note attribute list
    [[self.noteAttributes objectForKey:noteID] removeAttribute:attributeName forAttributeType:attributeType];
    
    //reflect the change in the xooml structure
    [self.delegate deleteNoteAttribute:attributeName ofType:attributeType fromNote:noteID];
}

- (void) removeNote: (NSString *) noteID
fromBulletinBoardAttribute: (NSString *) attributeName 
             ofType: (NSString *) attributeType{
    
    //if the noteId is not valid return
    if (![self.noteContents objectForKey:noteID]) return;
    
    //remove the note reference from the bulletin board attribute
    [self.bulletinBoardAttributes reomveValues: [NSArray arrayWithObject:noteID]
                                        fromAttribute: attributeName
                                     forAttributeType: attributeType];
    
    //reflect the change in the xooml structure
    [self.delegate deleteNote:noteID fromBulletinBoardAttribute:attributeName ofType:attributeType];
}

- (void) removeBulletinBoardAttribute:(NSString *)attributeName 
                               ofType:(NSString *)attributeType{
    
    //remove the attribtue from bulletin board attributes
    [self.bulletinBoardAttributes removeAttribute:attributeName forAttributeType:attributeType];
    
    
    //reflect the change in the xooml structure
    [self.delegate deleteBulletinBoardAttribute:attributeName ofType:attributeType];
    
}

- (void) updateNoteContentOf:(NSString *)noteID 
              withContentsOf:(id<Note>)newNote{

    //if noteID is inavlid return
    id <Note> oldNote = [self.noteContents objectForKey:noteID];
    if (!oldNote) return;

    //for attributes in newNote that a value is specified
    //update to old note to those values
    if (newNote.noteText) oldNote.noteText = newNote.noteText;
    if (newNote.noteTextID) oldNote.noteTextID = newNote.noteTextID;
    if (newNote.creationDate) oldNote.creationDate = newNote.creationDate;
    if (newNote.modificationDate) oldNote.modificationDate = newNote.modificationDate;
}

//TODO There may be performance penalities for this way of doing an update
- (void) renameNoteAttribute: (NSString *) oldAttributeName 
                      ofType: (NSString *) attributeType
                     forNote: (NSString *) noteID 
                    withName: (NSString *) newAttributeName{
    //if the note does not exist return
    if (![self.noteContents objectForKey:noteID]) return;
    
    //update the note bulletin board
    [[self.noteAttributes objectForKey:noteID] updateAttributeName:oldAttributeName ofType:attributeType withNewName:newAttributeName];
    
    //reflect the changes in the xooml data model
    [self.delegate updateNoteAttribute:oldAttributeName ofType:attributeType forNote:noteID withNewName:newAttributeName];
}

-(void) updateNoteAttribute: (NSString *) attributeName
                     ofType:(NSString *) attributeType 
                    forNote: (NSString *) noteID 
              withNewValues: (NSArray *) newValues{

    //iif the noteID is not valid return
    if (![self.noteContents objectForKey:noteID]) return;
    
    //update the note attribute values
    [[self.noteAttributes objectForKey:noteID] updateAttribue:attributeName ofType:attributeType withNewValue:newValues];
    
    //reflect the changes in the xooml data model
    [self.delegate updateNoteAttribute:attributeName ofType:attributeType withValues:newValues];
}

- (void) renameBulletinBoardAttribute: (NSString *) oldAttributeNAme 
                               ofType: (NSString *) attributeType 
                             withName: (NSString *) newAttributeName{
    
    //update the bulletin board attributes
    [self.bulletinBoardAttributes updateAttributeName: oldAttributeNAme ofType:attributeType withNewName:newAttributeName];
    
    //reflect the changes in the xooml data model
    [self.delegate updateBulletinBoardAttributeName:oldAttributeNAme ofType:attributeType withNewName:newAttributeName];
}

@end