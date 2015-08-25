#import "MHRoom.h"

@interface MHRoom ()

@property (nonatomic, readwrite) int volumeInSquareMeters;
@property (nonatomic, readwrite) MHHazmatFlags hazmatFlags;
@property (nonatomic, readwrite) BOOL hasStairs;

@end

@implementation MHRoom

- (id)initWithVolumeInSquareMeters:(int)volume {
    return [self initWithVolumeInSquareMeters:volume andStairs:NO];
}

- (id)initWithVolumeInSquareMeters:(int)volume andStairs:(BOOL)stairs {
    return [self initWithVolumeInSquareMeters:volume andStairs:stairs andHazmatFlags:MHHazmatFlagsNone];
}

- (id)initWithVolumeInSquareMeters:(int)volume andStairs:(BOOL)stairs andHazmatFlags:(MHHazmatFlags)hazmatFlags {
    if (self = [super init]) {
        self.boxes = [NSMutableArray array];
        self.volumeInSquareMeters = volume;
        self.hazmatFlags = hazmatFlags;
        self.hasStairs = stairs;
    }
    return self;
}

@end
