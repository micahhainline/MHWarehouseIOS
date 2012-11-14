#import "MHRoom.h"

@interface MHRoom ()

@property (nonatomic, readwrite) int capacityInSquareMeters;
@property (nonatomic, readwrite) MHHazmatFlags hazmatFlags;
@property (nonatomic, readwrite) BOOL requiresStairs;

@end

@implementation MHRoom

- (id)initWithName:(NSString *)name andCapacityInSquareMeters:(int)capacity andHazmatFlags:(MHHazmatFlags)hazmatFlags requiresStairs:(BOOL)requiresStairs {
    if (self = [super init]) {
        self.boxes = [NSMutableArray array];
        self.capacityInSquareMeters = capacity;
        self.hazmatFlags = hazmatFlags;
        self.requiresStairs = requiresStairs;
    }
    return self;
}

@end
