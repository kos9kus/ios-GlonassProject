

#import <UIKit/UIKit.h>
#import "avNewsEntry.h"

@interface RootMainTable : UITableViewController<AppModelDelegate>
{
    avNewsEntry *avNewsEntryInstance;
    UIRefreshControl *refreshControl;
}

-(NSUInteger)countOfNewsAtDate:(NSString*)date;

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicatorWebDowloadData;
@property(nonatomic,retain)avNewsEntry *avNewsEntryInstance;
@property (nonatomic,retain) IBOutlet UIRefreshControl *refreshControl;

@end
