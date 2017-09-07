//
//  ViewController.m
//  PictureSorter
//
//  Created by Zenel Kazushi on 8/18/16.
//  Copyright (c) 2016 Zenel Kazushi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak) IBOutlet NSImageView *imageViewOutput;
@property (nonatomic, strong) NSString *inputPath;
@property (nonatomic, strong) NSArray *imageFiles;
@property (nonatomic, assign) int index;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)keyDown:(NSEvent *)theEvent {
    if (theEvent.type != NSKeyDown || !self.imageFiles) {
        return;
    }
    NSString *folderName = nil;
    switch ([theEvent.characters characterAtIndex:0]) {
        case '1':
            folderName = @"1";
            break;
        case '2':
            folderName = @"2";
            break;
        case '3':
            folderName = @"3";
            break;
        case '4':
            folderName = @"4";
            break;
        default:
            return;
    }
    [self copyTopFileTo:folderName];
}

- (void)copyTopFileTo:(NSString *)folderName {
    NSString *fullFolderPath = [self.inputPath stringByAppendingPathComponent:folderName];
    NSString *fileName = [self.imageFiles[self.index] lastPathComponent];
    [[NSFileManager defaultManager] moveItemAtPath:self.imageFiles[self.index] toPath:[fullFolderPath stringByAppendingPathComponent:fileName] error:nil];
    ++self.index;
    [self showImage];
}

- (IBAction)buttonSelectFolder:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanCreateDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    NSInteger clicked = [openPanel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        self.inputPath = [[openPanel URL] path];
        [self startShowingPictures];
    }
}

- (void)startShowingPictures {
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.inputPath error:nil];
    NSMutableArray *imageFiles = [NSMutableArray new];
    for (NSString *file in files) {
        if ([[file pathExtension] isEqualToString:@"png"]
            || [[file pathExtension] isEqualToString:@"jpg"]
            || [[file pathExtension] isEqualToString:@"gif"]) {
            [imageFiles addObject:[self.inputPath stringByAppendingPathComponent:file]];
        }
    }
    self.imageFiles = [imageFiles copy];
    [[NSFileManager defaultManager] createDirectoryAtPath:[self.inputPath stringByAppendingPathComponent:@"1"] withIntermediateDirectories:NO attributes:nil error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:[self.inputPath stringByAppendingPathComponent:@"2"] withIntermediateDirectories:NO attributes:nil error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:[self.inputPath stringByAppendingPathComponent:@"3"] withIntermediateDirectories:NO attributes:nil error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:[self.inputPath stringByAppendingPathComponent:@"4"] withIntermediateDirectories:NO attributes:nil error:nil];
    self.index = 0;
    [self showImage];
}

- (void)showImage {
    if (self.index >= self.imageFiles.count) {
        NSLog(@"All done!");
        self.imageViewOutput.image = nil;
        return;
    }
    NSString *file = self.imageFiles[self.index];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:file];
    self.imageViewOutput.image = image;
}

@end
