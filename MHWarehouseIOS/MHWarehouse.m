#import "MHWarehouse.h"
#import "MHBox.h"
#import "MHRoom.h"

@interface MHWarehouse ()

@property(nonatomic, strong) NSArray *rooms;

@end

@implementation MHWarehouse

- (id)initWithRooms:(NSArray *)rooms {
    if (self = [super init]) {
        self.rooms = rooms;
    }
    return self;
}

- (NSArray *)addBoxes:(NSArray *)boxes {
    NSMutableArray *rejected = [NSMutableArray array];
    for (MHBox *box in boxes) {
        BOOL addedBox = NO;
        for (MHRoom *room in self.rooms) {
            if ([self canAddBox:box toRoom:room]) {
                [room.boxes addObject:box];
                addedBox = YES;
                break;
            }
        }
        if (!addedBox) {
            [rejected addObject:box];
        }
    }
    return rejected.count ? rejected : nil;
}

- (BOOL)canAddBox:(MHBox *)box toRoom:(MHRoom *)room {
    int remainingCapacity = room.capacityInSquareMeters;
    for (MHBox *currentBox in room.boxes) {
        remainingCapacity -= currentBox.volumeInSquareMeters;
    }
    BOOL noRoom = box.volumeInSquareMeters > remainingCapacity;
    BOOL tooLarge = box.volumeInSquareMeters > 50 && room.requiresStairs;
    BOOL dangerous = ~room.hazmatFlags & box.hazmatFlags;
    return !(noRoom || tooLarge || dangerous);
}

@end
