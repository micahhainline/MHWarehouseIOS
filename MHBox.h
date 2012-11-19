#import <Foundation/Foundation.h>
#import "MHHazmatFlags.h"

@interface MHBox : NSObject

@property (nonatomic, readonly) int volumeInSquareMeters;
@property (nonatomic, readonly) MHHazmatFlags hazmatFlags;

- (id)initWithName:(NSString *)name andVolumeInSquareMeters:(int)volume andHazmatFlags:(MHHazmatFlags)hazmatFlags;

@end
