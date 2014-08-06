

#import "avViewCellController.h"


@implementation avViewCellController

@synthesize newsViewBlock;
@synthesize newsContent;


- (void)viewDidLoad
{
    [super viewDidLoad];
    //////////////////////////////
    
    NSString *strNews =   [ [@"<style type=\"text/css\" BODY{ color: #434343; }></style><b>" stringByAppendingString:newsContent[@"descr"] ] stringByAppendingString:[@"</b>" stringByAppendingString:newsContent[@"text"] ] ];
    
    [self.newsViewBlock loadHTMLString:strNews baseURL:nil];
    
    UIImage *imgBackground = [UIImage imageNamed:@"logoNewsView.png"];
    UIImageView * imgBackgroundView = [[UIImageView alloc] initWithImage:imgBackground];
    UIBarButtonItem * barButtonImg = [[UIBarButtonItem alloc] initWithCustomView:imgBackgroundView];
    [self.navigationItem setRightBarButtonItem:barButtonImg animated:YES];
    [barButtonImg release];
    [imgBackgroundView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)dealloc {
    
    NSLog(@"Working dealic view Cell controller");
    [newsViewBlock release];
    [newsContent release];
    
    [super dealloc];

}
@end
