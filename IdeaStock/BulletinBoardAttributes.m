//
//  BulletinBoardAttributes.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/30/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "BulletinBoardAttributes.h"

@interface BulletinBoardAttributes()

/*
 the main datastructure for holding the attributes. This is an NSDictionary of NSDictionary of NSArrays. 
 attributes is keyed on attribute type.
 attribute[attributeType] is keyed on attribute Name.
 attribute[attributeType][attibuteName] is an array of noteIDs belonging to
 that attribute. 
 
 for example. attribute["Stack"]["StackName1] returns and array of all the noteIDs that bleong to the attribute stackName1 of type Stack. 
 */
@property (nonatomic,strong) NSMutableDictionary * attributes;

@end

@implementation BulletinBoardAttributes

@synthesize attributes = _attributes;


- (id) initWithAttributes: (NSArray *)attributeTypes{
    self = [super init];
    self.attributes = [NSMutableDictionary dictionary];
    for (NSString * attributeType in attributeTypes){
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [self.attributes setObject:attributes forKey:attributeType];
    }
    return self;
}

- (void) createAttributeWithName: (NSString *) attributeName
                forAttributeType:(NSString *) attributeType
                       andValues: (NSArray *)values{
    
    [[self.attributes objectForKey:attributeType] setObject:[values mutableCopy] forKey:attributeName];
}

-(void) addValues:(NSArray *)values
      ToAttribute:(NSString *)attributeName
 forAttributeType:(NSString *)attributeType{
    NSMutableArray * oldValues = [[self.attributes objectForKey:attributeType] objectForKey:attributeName];
    if (!oldValues){
        [self createAttributeWithName:attributeName forAttributeType:attributeType andValues:values];
        return;
    }
    
    [oldValues addObjectsFromArray:values];
    
}

- (NSDictionary *) getAllAttributeNamesForAttributeType: (NSString *) attributeType{
    return [[self.attributes objectForKey:attributeType] copy];
}

- (NSArray *) getAttributeWithName: (NSString *) attributeName
                  forAttributeType: (NSString *) attributeType{
    return [[[self.attributes objectForKey:attributeType] objectForKey:attributeName] copy];
    
}




- (void) removeValues: (NSArray *) values
        fromAttribute: (NSString *) attributeName
     forAttributeType: (NSString *) attributeType{
    [[[self.attributes objectForKey:attributeType] objectForKey:attributeName] removeObjectsInArray:values];
}

- (void) removeAttribute: (NSString *) attributeName
        forAttributeType: (NSString *)AttributeType{
    
    [[self.attributes objectForKey:AttributeType] removeObjectForKey:attributeName];
}

- (void) updateAttributeName : (NSString *) attributeName 
                       ofType: (NSString *) attributeType 
                  withNewName: (NSString *) newAttributeName{
    NSArray * values = [self getAttributeWithName:attributeName forAttributeType:attributeType];
    [self removeAttribute:attributeName forAttributeType:attributeType];
    [self createAttributeWithName:newAttributeName forAttributeType:attributeType andValues:values];
    
}

- (void) updateValue: (NSString *) value 
          ofAttribue: (NSString *) attributeName 
              ofType: (NSString *) attributeType 
        withNewValue: (NSString *) newValue{
    [self removeValues:[NSArray arrayWithObject:value] fromAttribute:attributeName forAttributeType:attributeType];
    [self addValues:[NSArray arrayWithObject:newValue] ToAttribute: attributeName forAttributeType:attributeType];
    
}



@end
