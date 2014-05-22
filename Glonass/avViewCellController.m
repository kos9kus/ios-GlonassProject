

#import "avViewCellController.h"


@implementation avViewCellController

@synthesize newsViewBlock = _newsViewBlock;;
@synthesize newsContent;


- (void)viewDidLoad
{
    [super viewDidLoad];
    //////////////////////////////
    
    NSString *strNews =   [ [@"<style type=\"text/css\" BODY{ color: #434343; }></style><b>" stringByAppendingString:newsContent[@"descr"] ] stringByAppendingString:[@"</b>" stringByAppendingString:newsContent[@"text"] ] ];
    
    [_newsViewBlock loadHTMLString:strNews baseURL:nil];
    
    UIImage *imgBackground = [UIImage imageNamed:@"logoNewsView.png"];
    UIImageView * imgBackgroundView = [[UIImageView alloc] initWithImage:imgBackground];
    UIBarButtonItem * barButtonImg = [[UIBarButtonItem alloc] initWithCustomView:imgBackgroundView];
    [self.navigationItem setRightBarButtonItem:barButtonImg animated:YES];
    [imgBackgroundView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)dealloc {
    
    NSLog(@"Working dealic view Cell controller");
    [_newsViewBlock release];
    [newsContent release];
    newsContent = nil;
    [super dealloc];

}
@end
