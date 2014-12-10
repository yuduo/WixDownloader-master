#import <Cocoa/Cocoa.h>
#import "ToolTipController.h"

@interface AppDelegate : NSWindowController <NSWindowDelegate>
{
    IBOutlet NSTextField* site;
    IBOutlet NSTextField* domain;
    IBOutlet NSButton* download;
    IBOutlet NSComboBox* agent;
    IBOutlet NSTextField* level;
    IBOutlet NSButton* media;
    IBOutlet NSButton* editor;
    IBOutlet NSButton* php;
    IBOutlet NSTextField* email;
    IBOutlet NSButton* seo;
    IBOutlet NSProgressIndicator *loading;
    IBOutlet NSProgressIndicator *progress;
    IBOutlet NSTextField* percent;
}

- (IBAction) download_Click:(id)sender;
- (IBAction)tooltip_Click:(NSButton*)button;
- (void) Debug:(NSString*)d;

@end
