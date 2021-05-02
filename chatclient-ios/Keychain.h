//
//  Keychain.h
//  chatclient-ios
//
//  Created by Blair Urish on 6/18/20.
//  Copyright © 2020 Blair Urish. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSDictionary<NSString*, NSString*>* CredentialInfo;

@interface Keychain : NSObject

+ (BOOL)addServer:(NSString*)server withUsername:(NSString*)username andPassword:(NSString*)password;
+ (BOOL)removeConnectionFrom:(NSString*)server withUsername:(NSString*)username;
+ (BOOL)updatePassword:(NSString*)password toServer:(NSString*)server withUsername:(NSString*)username;
+ (NSArray<CredentialInfo>*)readCredentials;

@end
