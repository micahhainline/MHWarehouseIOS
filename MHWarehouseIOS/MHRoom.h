#import <Foundation/Foundation.h>
#import "MHBox.h"
#import "MHHazmatFlags.h"

@interface MHRoom : NSObject

@property (nonatomic, strong) NSMutableArray *boxes;
@property (nonatomic, readonly) int volumeInSquareMeters;
@property (nonatomic, readonly) MHHazmatFlags hazmatFlags;
@property (nonatomic, readonly) BOOL hasStairs;

- (id)initWithVolumeInSquareMeters:(int)volume;

- (id)initWithVolumeInSquareMeters:(int)volume andStairs:(BOOL)stairs;

- (id)initWithVolumeInSquareMeters:(int)volume andStairs:(BOOL)stairs andHazmatFlags:(MHHazmatFlags)hazmatFlags;

@end
