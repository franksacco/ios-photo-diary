//
//  DBManager.h
//  PhotoDiary
//
//  Created by Francesco Saccani on 22/08/2018.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

-(NSArray *)loadData:(NSString *)query;
-(void)executeQuery:(NSString *)query;

@end
