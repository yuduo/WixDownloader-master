#import <Cocoa/Cocoa.h>

@interface ToolTipController: NSViewController
{
    NSString* tip;
    IBOutlet NSTextField* tool;
}

@property (strong) NSString* tip;

@end
