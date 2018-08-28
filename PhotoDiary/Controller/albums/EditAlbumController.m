//
//  AddAlbumController.m
//  PhotoDiary
//
//  Created by Francesco Saccani on 25/08/2018.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import "EditAlbumController.h"
#import "Album+CoreDataClass.h"
#import <QuartzCore/QuartzCore.h>


@interface EditAlbumController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)delete:(UIButton *)sender;

@end


@implementation EditAlbumController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.descTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.3] CGColor]];
    [self.descTextView.layer setBorderWidth:1.0];
    self.descTextView.layer.cornerRadius = 5;
    self.descTextView.clipsToBounds = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.album) {
        self.title = @"Modifica album";
        [self.titleTextField setText:self.album.title];
        [self.descTextView setText:self.album.desc];
    } else {
        self.deleteButton.hidden = YES;
    }
}


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
    Album *album;
    if (self.album) {
        album = self.album;
    } else {
        album = (Album *)[NSEntityDescription
                          insertNewObjectForEntityForName:@"Album"
                          inManagedObjectContext:context];
    }
    album.title = self.titleTextField.text;
    album.desc = self.descTextView.text;
    
    NSError *error = nil;
    if ([context save:&error]) {
        NSLog(@"Album saved");
    } else {
        NSLog(@"Error: %@ %@", error, [error localizedDescription]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)delete:(UIButton *)sender {
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:self.album];
    
    NSError *error = nil;
    if ([context save:&error]) {
        NSLog(@"Album deleted");
    } else {
        NSLog(@"Deleting error: %@ %@", error, [error localizedDescription]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
