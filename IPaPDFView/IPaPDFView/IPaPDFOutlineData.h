//
//  IPaPDFOutlineData.h
//  DigitalLibrary
//
//  Created by IPaPa on 12/4/27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPaPDFOutlineData : NSObject
@property (nonatomic,copy) NSString* Title;
@property (nonatomic,assign) NSUInteger pageNum;
@property (nonatomic,strong) NSArray *children;
@end
