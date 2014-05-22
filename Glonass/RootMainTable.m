
#import "RootMainTable.h"
#import "NSDate+InternetDateTime.h"
#import "avViewCellController.h"
#import "FXImageView/UIImage+FX.h"

@implementation RootMainTable

@synthesize avNewsEntryInstance;
@synthesize indicatorWebDowloadData;
@synthesize refreshControl;

#pragma mark - Delegat realization
-(void)appModelParsingDidStart:(avNewsEntry *)appModel{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.indicatorWebDowloadData startAnimating];
}

-(void)appModelParsingDidFinish:(avNewsEntry *)appModel{
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        [self.indicatorWebDowloadData stopAnimating];
        
        [self.avNewsEntryInstance saveToDisk];
    });
    
}

-(void)appModelParsingDidError:(avNewsEntry *)appModel{
    [self.refreshControl endRefreshing];
    [self.indicatorWebDowloadData stopAnimating];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:@"Упс! Нет сети" message:@"Загрузить последние сохраненные новости?" delegate:self cancelButtonTitle:@"НЕТ" otherButtonTitles:@"Загрузить", nil ];
        [alertError show];
        [alertError release];
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSLog(@"Scanning disk...");
        [self.avNewsEntryInstance readAndSetAllNewsformFile];
        
        [self.tableView reloadData];
    }
}

-(void)appModelParsingWriteIsOk{
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIImage* imgIcon = [[UIImage imageNamed:@"icon.png"] imageWithReflectionWithScale:0.4f gap:0.0f alpha:0.4f];
        
        UIImageView * imgForItemBackgroundView = [[UIImageView alloc] initWithImage:imgIcon];
        imgForItemBackgroundView.frame =CGRectMake(0, 0, imgIcon.size.width/2.0f, imgIcon.size.height/2.0f);
        
        UIBarButtonItem * barButtonRight = [[UIBarButtonItem alloc] initWithCustomView:imgForItemBackgroundView];
        
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.prompt = @"Я сохранил все новости на ваш iPhone!";
        NSTimeInterval delayInSeconds = 1.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.navigationItem.prompt = nil;
            [self.navigationItem setRightBarButtonItem:barButtonRight animated:YES];
        });
    });
}


#pragma mark - implement Root View
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(NSUInteger)countOfNewsAtDate:(NSString *)date{
    NSUInteger count = 0;
    for(id val in avNewsEntryInstance.allNews){
        if ( [date compare:val[@"date"]] == NSOrderedSame) {
            count++;
        }
    }
    return count;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    ///////////////////////////////////////////////////
    avNewsEntryInstance = [[avNewsEntry alloc] init] ;
    avNewsEntryInstance.delegate = self;
    
    //////////////////////// indicatorView ////////////////////////////
    UIBarButtonItem * barButton =
    [[UIBarButtonItem alloc] initWithCustomView:indicatorWebDowloadData];
    [self.navigationItem setLeftBarButtonItem:barButton];
    [barButton release];
    ////////////////////////////////////////////////////
    UIImage *imgBackground = [UIImage imageNamed:@"logoNewsView.png"];
    UIImageView * imgBackgroundView = [[UIImageView alloc] initWithImage:imgBackground];
    self.navigationItem.titleView = imgBackgroundView;
    [imgBackgroundView release];
    ////////////////////////////////////////////////////
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self.avNewsEntryInstance action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [avNewsEntryInstance refresh];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.avNewsEntryInstance.dateArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self countOfNewsAtDate:avNewsEntryInstance.dateArray[section] ];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* customView = [[[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, 44.0)] autorelease];
    customView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.75 alpha:0.85];
    UILabel * headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, 24.0)] autorelease];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    
    NSString *currentDateStr = avNewsEntryInstance.dateArray[section];
    NSDate *articleDate = [NSDate dateFromInternetDateTimeString:currentDateStr formatHint:DateFormatHintRFC3339];
    
    NSDateFormatter * dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    
    currentDateStr = [dateFormatter stringFromDate:articleDate];
    
    headerLabel.text = currentDateStr;
    [customView addSubview:headerLabel];
    
    return customView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell" forIndexPath:indexPath];
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:11];
    UILabel *discripLabel = (UILabel *)[cell viewWithTag:13];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:12];
    
    NSMutableArray *rowsArrDate = [[[NSMutableArray alloc] init] autorelease];
    for (id val in self.avNewsEntryInstance.allNews) {
        if ([self.avNewsEntryInstance.dateArray[indexPath.section] compare:val[@"date"] ] == NSOrderedSame) {
            [rowsArrDate addObject:val];
        }
    }
    
    titleLabel.text = rowsArrDate[indexPath.row][@"title"];
    discripLabel.text = rowsArrDate[indexPath.row][@"descr"];
    
    imageView.hidden = YES;
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL* imgUrl = [NSURL URLWithString: rowsArrDate[indexPath.row][@"img"] ];
        NSURLRequest *request = [NSURLRequest requestWithURL:imgUrl ];
        UIImage *imgTest = [ UIImage imageWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil ] ];
        imgTest = [imgTest imageWithCornerRadius:4.0f];
        imgTest = [imgTest imageWithReflectionWithScale:0.4f gap:0.0f alpha:0.5f];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [imageView setImage:imgTest];
            imageView.hidden = NO;
        });
    });
    
    return cell;
}

//-(void) viewWillAppear:(BOOL)animated {
//    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
////        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"logo.png"] forBarMetrics:UIBarMetricsDefault];
//
//
//    }
//    else{
//        NSLog(@"This is iOS_6");
//        UIImage *imgBackground = [UIImage imageNamed:@"logoNewsView.png"];
//        UIImageView * imgBackgroundView = [[UIImageView alloc] initWithImage:imgBackground];
//        self.navigationItem.titleView = imgBackgroundView;
////        [imgBackgroundView release];
//    }
//    [super viewWillAppear:animated];
//}

//-(void) viewWillDisappear:(BOOL)animated {
////    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//    [super viewWillDisappear:animated];
//}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    UILabel *titleLabel = (UILabel*)[cell viewWithTag:11];
//    for (id val in self.avNewsEntryInstance.allNews) {
//        if ([titleLabel.text compare:val[@"title"] ] == NSOrderedSame) {
//            currentNews = val;
//        }
//    }
//}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"newsView"]){
        avViewCellController *newsView = [segue destinationViewController];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow] ];
        UILabel *titleLabel = (UILabel*)[cell viewWithTag:11];
        for (id val in self.avNewsEntryInstance.allNews) {
            if ([titleLabel.text compare:val[@"title"] ] == NSOrderedSame) {
                newsView.newsContent = val;
            }
        }
    }
}


-(void)dealloc{
    NSLog(@"Working 'RootMain' dealloc");
    [refreshControl release];
    refreshControl = nil;
    [indicatorWebDowloadData release];
    indicatorWebDowloadData = nil;
    [avNewsEntryInstance release];
    avNewsEntryInstance = nil;
    [super dealloc];
}

@end
