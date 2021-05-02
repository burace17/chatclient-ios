//
//  Keychain.m
//  chatclient-ios
//
//  Created by Blair Urish on 6/18/20.
//  Copyright © 2020 Blair Urish. All rights reserved.
//

#import <Security/Security.h>
#import "Keychain.h"

@implementation Keychain

+ (BOOL)addServer:(NSString*)server withUsername:(NSString*)username andPassword:(NSString*)password {
  auto dict = @{
    (__bridge id)kSecClass : (__bridge id)kSecClassInternetPassword,
    (__bridge id)kSecAttrServer : [server dataUsingEncoding:NSUTF8StringEncoding],
    (__bridge id)kSecAttrAccount : [username dataUsingEncoding:NSUTF8StringEncoding],
    (__bridge id)kSecValueData : [password dataUsingEncoding:NSUTF8StringEncoding],
  };
  
  auto result = SecItemAdd((__bridge CFDictionaryRef)dict, nil);
  if (result != errSecSuccess) {
    NSLog(@"Failed to add security item. Status: %d", result);
  }
  
  return result == errSecSuccess;
}

+ (BOOL)removeConnectionFrom:(NSString*)server withUsername:(NSString*)username {
  auto query = @{
    (__bridge id)kSecClass : (__bridge id)kSecClassInternetPassword,
    (__bridge id)kSecAttrServer : [server dataUsingEncoding:NSUTF8StringEncoding],
    (__bridge id)kSecAttrAccount : [username dataUsingEncoding:NSUTF8StringEncoding],
  };
  
  auto result = SecItemDelete((__bridge CFDictionaryRef)query);
  if (result != errSecSuccess) {
    NSLog(@"Failed to delete security item. Status %d", result);
  }
  
  return result == errSecSuccess;
}

+ (BOOL)updatePassword:(NSString*)password toServer:(NSString*)server withUsername:(NSString*)username {
  auto query = @{
    (__bridge id)kSecClass : (__bridge id)kSecClassInternetPassword,
    (__bridge id)kSecAttrServer : [server dataUsingEncoding:NSUTF8StringEncoding],
    (__bridge id)kSecAttrAccount : [username dataUsingEncoding:NSUTF8StringEncoding],
  };
  
  auto update = @{
    (__bridge id)kSecValueData : [password dataUsingEncoding:NSUTF8StringEncoding]
  };
 
  auto result = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)update);
  if (result != errSecSuccess) {
    NSLog(@"Failed to update security item. Status %d", result);
  }
  
  return result == errSecSuccess;
}

+ (NSArray<CredentialInfo>*)readCredentials {
  auto query = @{
    (__bridge id)kSecClass : (__bridge id)kSecClassInternetPassword,
    (__bridge id)kSecMatchLimit : (__bridge id)kSecMatchLimitAll,
    (__bridge id)kSecReturnAttributes : (__bridge id)kCFBooleanTrue,
    (__bridge id)kSecReturnData : (__bridge id)kCFBooleanTrue
  };

  CFTypeRef cfResult = nullptr;
  auto status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &cfResult);
  if (status == errSecItemNotFound)
    return nil;

  // Take the dictionary we got from Core Foundation and get rid of the CFStrings so it's easier to use.
  auto finalResult = [[NSMutableArray alloc] init];
  auto cfResultArray = (__bridge_transfer NSArray*)cfResult;
  for (NSDictionary* dict in cfResultArray) {
    auto server = [[NSString alloc] initWithData:dict[(__bridge id)kSecAttrServer] encoding:NSUTF8StringEncoding];
    auto account = [[NSString alloc] initWithData:dict[(__bridge id)kSecAttrAccount] encoding:NSUTF8StringEncoding];
    auto password = [[NSString alloc] initWithData:dict[(__bridge id)kSecValueData] encoding:NSUTF8StringEncoding];
    auto cleanedDict = @{ @"address" : server, @"username" : account, @"password" : password };
    
    [finalResult addObject:cleanedDict];
  }
  
  return finalResult;
}

@end
