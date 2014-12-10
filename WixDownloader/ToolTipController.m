#import "ToolTipController.h"

@implementation ToolTipController
@synthesize tip;

- (id)init
{
    self = [super initWithNibName:@"ToolTip" bundle:nil];
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)awakeFromNib
{
    [tool setStringValue:tip];
}

@end
