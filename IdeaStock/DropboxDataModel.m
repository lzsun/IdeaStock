//
//  DropboxDataModel.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "DropboxDataModel.h"
#import "FileSystemHelper.h"
#import "QueueProducer.h"
#import "DropboxAction.h"

#define ADD_BULLETIN_BOARD_ACTION @"addBulletinBoard"
#define UPDATE_BULLETIN_BOARD_ACTION @"updateBulletinBoard"
#define ADD_NOTE_ACTION @"addNote"
#define UPDATE_NOTE_ACTION @"updateNote"
#define ADD_IMAGE_NOTE_ACTION @"addImage"
#define ACTION_TYPE_CREATE_FOLDER @"createFolder"
#define ACTION_TYPE_UPLOAD_FILE @"uploadFile"


@interface DropboxDataModel()

/*--------------------------------------------------
 
                Delegation Properties
 
 -------------------------------------------------*/

//connection to dropbox
@property (nonatomic,strong) id tempDel;

/*--------------------------------------------------
 
                Operational Properties
 
 -------------------------------------------------*/



@end

/*=======================================================*/

@implementation DropboxDataModel

/*--------------------------------------------------
 
                    Synthesis
 
 -------------------------------------------------*/

@synthesize restClient = _restClient;
@synthesize tempDel = _tempDel;

@synthesize actionController = _actionController;
@synthesize actions = _actions;



-(DBRestClient *) restClient{
    if (!_restClient){
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        
        //the default is that the data model sets itself as delegate
        _restClient.delegate = self;
    }
    return _restClient;
}

-(void) setDelegate:(id <QueueProducer,DBRestClientDelegate>)delegate{
    self.restClient.delegate = delegate;
}

-(id) delegate{
    return  _restClient.delegate;
}

-(NSMutableDictionary *) actions{
    if (!_actions){
        _actions = [[NSMutableDictionary alloc] init];
    }
    return _actions;
}

/*=======================================================*/

/*--------------------------------------------------
 
                Local file system methods
 
 -------------------------------------------------*/


/*--------------------------------------------------
 
                    Creastion Methods
 
 -------------------------------------------------*/

#define BULLETINBOARD_XOOML_FILE_NAME @"XooML.xml"
-(void) addBulletinBoardWithName: (NSString *) bulletinBoardName
             andBulletinBoardInfo: (NSData *) content{
    
    
    //first write the new content to the disk

    NSError * err;
    NSString * path = [FileSystemHelper getPathForBulletinBoardWithName:bulletinBoardName];
    [FileSystemHelper createMissingDirectoryForPath:path];
    BOOL didWrite = [content writeToFile:path options:NSDataWritingAtomic error:&err];
    if (!didWrite){
        NSLog(@"Error in writing to file system: %@", err);
        return;
    }

    
    //temporarily save the delegate
    self.tempDel = self.delegate;
    
    //make yourself delegate
    self.restClient.delegate = self;

    
    //set the action
    
    if (![self.actions objectForKey:ACTION_TYPE_CREATE_FOLDER]){
        [self.actions setObject:[[NSMutableDictionary alloc] init] forKey:ACTION_TYPE_CREATE_FOLDER];
    }
    
    DropboxAction * action = [[DropboxAction alloc] init];
    action.action = ADD_BULLETIN_BOARD_ACTION;
    action.actionPath = path;
    action.actionBulletinBoardName = bulletinBoardName;
    
    NSString * folderName = bulletinBoardName;
    [[self.actions objectForKey:ACTION_TYPE_CREATE_FOLDER] setObject:action forKey:folderName];

    //now create a folder in dropbox the rest is done by the foldercreated delegate method
    [self.restClient createFolder:folderName];
}

-(void) addNote: (NSString *)noteName 
     withContent: (NSData *) note 
 ToBulletinBoard: (NSString *) bulletinBoardName{
    
    NSError * err;
    //first write the note to the disk
    NSString * path = [FileSystemHelper getPathForNoteWithName:noteName inBulletinBoardWithName:bulletinBoardName];
    
    [FileSystemHelper createMissingDirectoryForPath:path];
    BOOL didWrite = [note writeToFile:path options:NSDataWritingAtomic error:&err];
    if (!didWrite){
        NSLog(@"Error in writing to file system: %@", err);
        return;
    }
    
    //temporarily save the delegate
    self.tempDel = self.delegate;
    
    //make yourself delegate
    self.restClient.delegate = self;
    
    
    //now upload the file to the dropbox
    //First check whether the note folder exists
    //NSString * destination = [NSString stringWithFormat: @"/%@/%@/%@", bulletinBoardName, noteName, NOTE_XOOML_FILE_NAME];
    NSString * destination = [NSString stringWithFormat: @"/%@/%@", bulletinBoardName, noteName];
    
    
    if (![self.actions objectForKey:ACTION_TYPE_CREATE_FOLDER]){
        [self.actions setObject:[[NSMutableDictionary alloc] init] forKey:ACTION_TYPE_CREATE_FOLDER];
    }
    
    DropboxAction * action = [[DropboxAction alloc] init];
    action.action = ADD_NOTE_ACTION;
    action.actionPath = path;
    action.actionBulletinBoardName = bulletinBoardName;
    action.actionNoteName = noteName;
    
    NSString * folderName = [destination lastPathComponent];
    [[self.actions objectForKey:ACTION_TYPE_CREATE_FOLDER] setObject:action forKey:folderName];

    //the rest is done for loadedMetadata method
    [self.restClient createFolder: destination];
    
}

    
-(void) addImageNote: (NSString *) noteName 
     withNoteContent: (NSData *) note 
            andImage: (NSData *) img 
            withImageFileName:(NSString *)imgName
     toBulletinBoard: (NSString *) bulletinBoardName{
    
    /*
    NSError * err;
    NSString * path = [FileSystemHelper getPathForNoteWithName:noteName inBulletinBoardWithName:bulletinBoardName];
    self.actionPath = path;
    
    [FileSystemHelper createMissingDirectoryForPath:path];
    BOOL didWrite = [note writeToFile:path options:NSDataWritingAtomic error:&err];
    
    if (!didWrite){
        NSLog(@"Error in writing to file system: %@", err);
        return;
    }
    
    path = [path stringByDeletingLastPathComponent];
    path = [path stringByAppendingFormat:@"/%@",imgName];
    
    didWrite = [img writeToFile:path options:NSDataWritingAtomic error:&err];
    
    if (!didWrite){
        NSLog(@"Error in writing to file system: %@", err);
        return;
    }
    
    self.tempDel = self.delegate;
    
    self.restClient.delegate = self;
    
    self.action = ADD_IMAGE_NOTE_ACTION;
    self.actionBulletinBoardName = bulletinBoardName;
    self.actionNoteName = noteName;
    self.actionFileName =imgName;
    
    NSString * destination = [NSString stringWithFormat: @"/%@/%@", bulletinBoardName, noteName];
    
    //the rest is done for loadedMetadata method
    [self.restClient createFolder: destination];*/
}
/*--------------------------------------------------
 
                    Update Methods
 
 -------------------------------------------------*/

-(void) updateBulletinBoardWithName: (NSString *) bulletinBoardName 
               andBulletinBoardInfo: (NSData *) content{
    [self.actionController setActionInProgress:NO];
    
    /*    
    NSError * err;
    NSString * path = [FileSystemHelper getPathForBulletinBoardWithName:bulletinBoardName];
    [FileSystemHelper createMissingDirectoryForPath:path];
    
    BOOL didWrite = [content writeToFile:path options:NSDataWritingAtomic error:&err];
    if (!didWrite){
        NSLog(@"Error in writing to file system: %@", err);
        return;
    }
    
    //temporality save the delegate
    self.tempDel = self.delegate;
    
    //make yourself delegate
    self.restClient.delegate = self;
    
    //set the action
    self.action = UPDATE_BULLETIN_BOARD_ACTION;
    self.actionPath = path;
    self.actionBulletinBoardName = bulletinBoardName;
    
    //now update the bulletin board. No need to create any folders 
    //because we are assuming its always there.
    //To update we need to know the latest revision number by calling metadata
    NSString * destination = [NSString stringWithFormat:@"/%@/%@",bulletinBoardName,BULLETINBOARD_XOOML_FILE_NAME];
    [self.restClient loadMetadata:destination];
    
 */   
}
#define NOTE_XOOML_FILE_NAME @"XooML.xml"

-(void) updateNote: (NSString *) noteName 
       withContent: (NSData *) content
   inBulletinBoard:(NSString *) bulletinBoardName{
    /*
    NSError *err;
    NSString *path = [FileSystemHelper getPathForNoteWithName:noteName inBulletinBoardWithName:bulletinBoardName];
    [FileSystemHelper createMissingDirectoryForPath:path];
    
    BOOL didWrite = [content writeToFile:path options:NSDataWritingAtomic error:&err];
    if (!didWrite){
        NSLog(@"Error in writing to file system: %@", err);
        return;
    }
    
    //temporality save the delegate
    self.tempDel = self.delegate;
    
    //make yourself delegate
    self.restClient.delegate = self;
    
    //set the action
    self.action = UPDATE_NOTE_ACTION;
    self.actionPath = path;
    self.actionBulletinBoardName = bulletinBoardName;
    
    //now update the bulletin board. No need to create any folders 
    //because we are assuming its always there.
    //To update we need to know the latest revision number by calling metadata
    NSString * destination = [NSString stringWithFormat:@"/%@/%@/%@",bulletinBoardName,noteName, NOTE_XOOML_FILE_NAME];
    [self.restClient loadMetadata:destination];

    
 */   
}

/*--------------------------------------------------
 
                    Deletion Methods
 
 -------------------------------------------------*/

    
-(void) removeBulletinBoard:(NSString *) boardName{
    /*
    NSError * err;
    NSString * path = [FileSystemHelper getPathForBulletinBoardWithName:boardName];
    path = [path stringByDeletingLastPathComponent];
    NSFileManager * manager = [NSFileManager defaultManager];
    BOOL didDelete = [manager removeItemAtPath:path error:&err];
    
    //its okey if this is not on the disk and we have an error
    //try dropbox and see if you can delete it from there
    if (!didDelete){
        NSLog(@"Error in deleting the file from the disk: %@",err);
        NSLog(@"Trying to delete from dropbox...");
    }
    
    [self.restClient deletePath:boardName];
    */
}

-(void) removeNote: (NSString *) noteName
  FromBulletinBoard: (NSString *) bulletinBoardName{
    
    /*
    NSError *err;
    NSString * path = [[FileSystemHelper getPathForNoteWithName:noteName inBulletinBoardWithName:bulletinBoardName] stringByDeletingLastPathComponent];
    NSFileManager * manager = [NSFileManager defaultManager];
    BOOL didDelete = [manager removeItemAtPath:path error:&err];
    
    //its okey if this is not on the disk and we have an error
    //try dropbox and see if you can delete it from there
    if (!didDelete){
        NSLog(@"Error in deleting the file from the disk: %@",err);
        NSLog(@"Trying to delete from dropbox...");
    }
    
    NSString * delPath = [bulletinBoardName stringByAppendingFormat:@"/%@",noteName];
    [self.restClient deletePath:delPath];
*/
    
}

/*--------------------------------------------------
 
                    Query Methods
 
 -------------------------------------------------*/

-(NSArray *) getAllBulletinBoardsFromRoot{
    [self getAllBulletinBoardsAsynch];
    return nil;
}

-(NSData *) getBulletinBoard: (NSString *) bulletinBoardName{
    [self getBulletinBoardAsynch:bulletinBoardName];
    return nil;
}

-(void) getAllBulletinBoardsAsynch{
    
    [self.restClient loadMetadata:@"/"];
}

-(void) getBulletinBoardAsynch: (NSString *) bulletinBoardName{
    
    
    [[self restClient] loadMetadata:[NSString stringWithFormat: @"/%@", bulletinBoardName]];
    
}

/*--------------------------------------------------
 
                RESTClient delegate protocol
 
 -------------------------------------------------*/

-(void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
   /* 
    NSString * parentRev = [metadata rev];
    NSString * path = [metadata path];
                                     
    
    NSLog(@"Meta data loaded");
    if( [self.action isEqualToString:UPDATE_BULLETIN_BOARD_ACTION] ){
        
        NSLog(@"Performing Update Bulletin board action");
        
        NSString * sourcePath = self.actionPath;
        
        self.action = nil;
        self.actionPath = nil;
        self.actionBulletinBoardName = nil;
        self.actionNoteName = nil;
        self.restClient.delegate = self.tempDel;
        
        path = [path stringByDeletingLastPathComponent];
        
        NSLog(@"Uploading file: %@ to destination: %@", sourcePath, path);
        [self.restClient uploadFile:BULLETINBOARD_XOOML_FILE_NAME toPath:path withParentRev:parentRev fromPath:sourcePath];
        
        [self.actionController setActionInProgress:NO];
        return;
    }
    
    if ( [self.action isEqualToString:UPDATE_NOTE_ACTION]){
        
        NSLog(@"Performin Update Note Action");
        NSString * sourcePath = self.actionPath;        
     
        self.action = nil;
        self.actionPath = nil;
        self.actionNoteName = nil;
        self.actionBulletinBoardName = nil;

        
        path = [path stringByDeletingLastPathComponent];
        NSLog(@"Uploading file: %@ to destination : %@", sourcePath,path);
        [self.restClient uploadFile:NOTE_XOOML_FILE_NAME toPath:path withParentRev:parentRev fromPath:sourcePath];
        
        [self.actionController setActionInProgress:NO];
        return;
    }
    */
}

-(void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    
    NSLog(@"Error loading metadata: %@", error);
}

-(void) restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath{
    NSLog(@"File sucessfully uploaded from %@ to %@",srcPath, destPath);
    self.restClient.delegate = self.tempDel;
    if ([self.delegate respondsToSelector:@selector(produceNext)]){
            [self.delegate produceNext];
    }
    else{
        [self.actionController setActionInProgress:NO];
    }

}
    
-(void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder{
    
    DropboxAction * actionItem;
    
    if ([self.actions objectForKey:ACTION_TYPE_CREATE_FOLDER]){
        
        NSString * folderName = [[folder path] lastPathComponent];
        if ([[self.actions objectForKey:ACTION_TYPE_CREATE_FOLDER] objectForKey:folderName]){
            actionItem = [[self.actions objectForKey:ACTION_TYPE_CREATE_FOLDER] objectForKey:folderName];
            [[self.actions objectForKey:ACTION_TYPE_CREATE_FOLDER] removeObjectForKey:folderName];
        }
    }
    
    if ([actionItem.action isEqualToString:ADD_BULLETIN_BOARD_ACTION]){
        
        NSLog(@"Performing Add Bulletin board action");
        NSLog(@"Folder Created for bulletinboard: %@ ", actionItem.actionBulletinBoardName);
        NSString *path = [folder path];
        NSString * sourcePath = actionItem.actionPath;
        
        //reset the delegate
        self.restClient.delegate = self.tempDel;
        //since its a new file the revision is set to nil
        
        DropboxAction * newAction = [[DropboxAction alloc] init];
        newAction.action = ADD_BULLETIN_BOARD_ACTION;
        newAction.actionPath = path;
        newAction.actionFileName = BULLETINBOARD_XOOML_FILE_NAME;
        newAction.actionBulletinBoardName = actionItem.actionBulletinBoardName;
        
        if (![self.actions objectForKey:ACTION_TYPE_UPLOAD_FILE]){
            [self.actions setObject:[[NSMutableDictionary alloc] init] forKey:ACTION_TYPE_UPLOAD_FILE];
        }
        
        [[self.actions objectForKey:ACTION_TYPE_UPLOAD_FILE] setObject:newAction forKey:path];
        
        [self.restClient uploadFile:BULLETINBOARD_XOOML_FILE_NAME toPath:path withParentRev:nil fromPath:sourcePath];
        
        [self.actionController setActionInProgress:NO];
        
        return;
        
    }
    
     
    if([actionItem.action isEqualToString:ADD_NOTE_ACTION] ||
       [actionItem.action isEqualToString:ADD_IMAGE_NOTE_ACTION]){
        NSLog(@"Performing Add Note action");
        NSLog(@"Folder Created for note: %@", actionItem.actionNoteName);
        NSString * path = [folder path];
        
        
        NSString * sourcePath = actionItem.actionPath;
        BOOL isImage = [actionItem.action isEqualToString:ADD_IMAGE_NOTE_ACTION] ? YES: NO;
                
        self.restClient.delegate = self.tempDel;

        DropboxAction * newAction = [[DropboxAction alloc] init];
        newAction.action = ADD_NOTE_ACTION;
        newAction.actionPath = path;
        newAction.actionNoteName = actionItem.actionNoteName;
        newAction.actionFileName = sourcePath;
        newAction.actionBulletinBoardName = actionItem.actionBulletinBoardName;
        
        if (![self.actions objectForKey:ACTION_TYPE_UPLOAD_FILE]){
             [self.actions setObject:[[NSMutableDictionary alloc] init] forKey:ACTION_TYPE_UPLOAD_FILE];
        }
        [[self.actions objectForKey:ACTION_TYPE_UPLOAD_FILE] setObject:newAction forKey:path];
        
        [self.actionController setActionInProgress:YES];
        [self.restClient uploadFile:NOTE_XOOML_FILE_NAME toPath:path withParentRev:nil fromPath:sourcePath];
        
        if (isImage){
            
            NSLog(@"Note is an Image");
            NSString *imgPath = [sourcePath stringByDeletingLastPathComponent];
            imgPath = [imgPath stringByAppendingFormat:@"/%@",actionItem.actionFileName];
            NSLog(@"Uploading image file: from %@ to destination: %@", imgPath, path);
            
            DropboxAction * imageAction = [[DropboxAction alloc] init];
            imageAction.action = ADD_IMAGE_NOTE_ACTION;
            imageAction.actionPath = path;
            imageAction.actionNoteName = actionItem.actionNoteName;
            imageAction.actionFileName = actionItem.actionFileName;
            imageAction.actionBulletinBoardName = actionItem.actionBulletinBoardName;
            
            
            [[self.actions objectForKey:ACTION_TYPE_UPLOAD_FILE] setObject:imageAction forKey:path];
            [self.actionController setActionInProgress:YES];
            [self.restClient uploadFile:actionItem.actionFileName toPath:path withParentRev:nil fromPath:imgPath];
        } 
    }
}

-(void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error{
    NSLog(@"Failed to create Folder:: %@", error);
    self.restClient.delegate = self.tempDel;
}

@end
