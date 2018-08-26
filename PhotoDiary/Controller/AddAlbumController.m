//
//  AddAlbumController.m
//  PhotoDiary
//
//  Created by Francesco Saccani on 25/08/2018.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import "AddAlbumController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface AddAlbumController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end


@implementation AddAlbumController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_descTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.3] CGColor]];
    [_descTextView.layer setBorderWidth:1.0];
    _descTextView.layer.cornerRadius = 5;
    _descTextView.clipsToBounds = YES;
}


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(persistentContainer)]) {
        context = [[delegate persistentContainer] viewContext];
    }
    return context;
}


- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)save:(id)sender {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *album = [NSEntityDescription insertNewObjectForEntityForName:@"Album"
                                                           inManagedObjectContext:context];
    NSLog(@"title textfield: %@", self.titleTextField);
    [album setValue:self.titleTextField.text forKey:@"title"];
    [album setValue:self.descTextView.text forKey:@"desc"];
    
    NSError *error = nil;
    if ([context save:&error]) {
        NSLog(@"Album inserted");
    } else {
        NSLog(@"Error during album inserting: %@ %@", error, [error localizedDescription]);
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
