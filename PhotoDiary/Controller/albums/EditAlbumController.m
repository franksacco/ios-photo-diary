//
//  AddAlbumController.m
//  PhotoDiary
//
//  Created by Francesco Saccani on 25/08/2018.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import "EditAlbumController.h"
#import "AlbumPhotosController.h"
#import "Album+CoreDataClass.h"
#import <QuartzCore/QuartzCore.h>


@interface EditAlbumController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)delete:(UIButton *)sender;
- (IBAction)titleChanged:(UITextField *)sender;
- (IBAction)hideKeyboard:(id)sender;

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
        self.saveButton.enabled = YES;
    } else {
        self.saveButton.enabled = NO;
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
    if (![context save:&error]) {
        NSLog(@"Error: %@ %@", error, [error localizedDescription]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)delete:(UIButton *)sender {
    UIAlertController *dialog =
        [UIAlertController alertControllerWithTitle:@"Elimina album"
            message:@"Confermi l'eliminazione dell'album? L'azione non può essere annullata"
            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction =
        [UIAlertAction actionWithTitle:@"Conferma"
                                 style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction * _Nonnull action) {
                                   [self deleteAlbum];
                               }];
    [dialog addAction:confirmAction];
    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:@"Annulla"
                                 style:UIAlertActionStyleCancel
                               handler:nil];
    [dialog addAction:cancelAction];
    
    [self presentViewController:dialog animated:YES completion:nil];
}

- (void)deleteAlbum {
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:self.album];
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Deleting error: %@ %@", error, [error localizedDescription]);
    }
    self.album.title = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)titleChanged:(UITextField *)sender {
    if ([sender.text length] == 0) {
        self.saveButton.enabled = NO;
    } else {
        self.saveButton.enabled = YES;
    }
}


- (IBAction)hideKeyboard:(id)sender {
    [self.titleTextField resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
