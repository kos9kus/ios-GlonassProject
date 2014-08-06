

#import "avNewsEntry.h"

@implementation avNewsEntry

@synthesize allNews = _allNews;
@synthesize dateArray = _dateArray;
@synthesize errorWeb = _errorWeb;

@synthesize delegate = _delegate;

#pragma mark - private methods
-(void) parserDidStart {
    if ( [self.delegate respondsToSelector:@selector(appModelParsingDidStart:)] )
        [self.delegate appModelParsingDidStart:self];
}

-(void) parserDidFinish {
    if ( [self.delegate respondsToSelector:@selector(appModelParsingDidFinish:)] )
        [self.delegate appModelParsingDidFinish:self];
}

-(void) parserDidError{
    if ([self.delegate respondsToSelector:@selector(appModelParsingDidError:)]) {
        [self.delegate appModelParsingDidError:self];
    }
}

-(void)recieveAndParseJSON {
    NSAutoreleasePool * autopool = [[NSAutoreleasePool alloc] init];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://glonass-portal.ru/api/ios/news/"] ];
    _errorWeb = nil;
    NSData *dataWeb = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&(_errorWeb) ];
    
    if (_errorWeb == nil) {
        _allNews = [NSJSONSerialization JSONObjectWithData:dataWeb options:NSJSONReadingMutableLeaves|| NSJSONReadingMutableContainers error:&(_errorWeb)];
        
        _allNews = [[_allNews sortedArrayUsingComparator: ^(id obj1, id obj2) {
            
            NSString *str1 = obj1[@"date"];
            NSString *str2 = obj2[@"date"];
            
            NSComparisonResult returnOrderedResult  = [str1 compare:str2];
            if (NSOrderedAscending == returnOrderedResult) {
                return NSOrderedDescending;
            }
            
            if (returnOrderedResult == NSOrderedDescending) {
                return NSOrderedAscending;
            }
            return returnOrderedResult;
        }] retain];
        
        
        NSMutableArray * dateArraySort = [[[NSMutableArray alloc] init] autorelease];
        for ( int i = 0; i < [_allNews count]; ++i ) {
            if (![dateArraySort containsObject:_allNews[i][@"date"]]) {
                [dateArraySort addObject:_allNews[i][@"date"]];
            }
        }
        
        _dateArray = [dateArraySort retain];
        
        [self parserDidFinish];
    }
    else{
        [self parserDidError];
        NSLog(@"%@",_errorWeb);
    }
    
    [autopool release];
}

////////////////////////////////////////////////////////////////////////////////////////

-(NSString*) docPath {
    NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[pathList objectAtIndex:0] stringByAppendingPathComponent:@"LastStoreNews.plist"];
}

-(void) refresh {
    [self parserDidStart];
    [self performSelectorInBackground:@selector(recieveAndParseJSON) withObject:nil];
}

-(void)saveToDisk{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL successWhrite = [_allNews writeToFile:[self docPath] atomically:YES];
        if(successWhrite){
            NSLog(@"success Write");
            if ( [self.delegate respondsToSelector:@selector(appModelParsingWriteIsOk)] )
                [self.delegate appModelParsingWriteIsOk];
        }
    });
}

-(void)readAndSetAllNewsformFile{
    _allNews = [NSArray arrayWithContentsOfFile:[self docPath] ];
    
    _allNews = [[_allNews sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        NSString *str1 = obj1[@"date"];
        NSString *str2 = obj2[@"date"];
        
        NSComparisonResult returnOrderedResult = [str1 compare:str2];
        if (NSOrderedAscending == returnOrderedResult) {
            return NSOrderedDescending;
        }
        
        if (returnOrderedResult == NSOrderedDescending) {
            return NSOrderedAscending;
        }
        return returnOrderedResult;
    }] retain];
    
    NSMutableArray * dateArraySort = [[NSMutableArray alloc] init];
    for ( int i = 0; i < [_allNews count]; ++i ) {
        if (![dateArraySort containsObject:_allNews[i][@"date"]]) {
            [dateArraySort addObject:_allNews[i][@"date"]];
        }
    }
     _dateArray = [dateArraySort retain];
    [dateArraySort release];
}

-(void)dealloc{
    NSLog(@" working dealloc 'avNewsEntry' ");
    
    if(_errorWeb != nil){
        [_errorWeb release];
    }
    
    [_delegate release];
    [_allNews release];
    [_dateArray release];
    [super dealloc];
}

@end
