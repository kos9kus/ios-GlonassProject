

#import <Foundation/Foundation.h>

@class avNewsEntry;

@protocol AppModelDelegate <NSObject>

@required
// уведомляет делегат о начале парсинга
-(void) appModelParsingDidStart:(avNewsEntry*)appModel;
// уведомляет делегат о завершении парсинга
-(void) appModelParsingDidFinish:(avNewsEntry*)appModel;
// Уведомление о том что произошла ошибка сети парсинга и т.д.
-(void) appModelParsingDidError:(avNewsEntry*)appModel;

@optional
-(void) appModelParsingWriteIsOk;

@end

NSString *docPath(void);

@interface avNewsEntry : NSObject

@property(nonatomic,retain) id<AppModelDelegate> delegate;
@property(nonatomic,readonly) NSArray* allNews;
@property(nonatomic,readonly) NSArray* dateArray;
@property(nonatomic,retain) NSError * errorWeb;

-(void)refresh;
-(void)saveToDisk;
-(void)readAndSetAllNewsformFile;
-(NSString*) docPath;

@end
