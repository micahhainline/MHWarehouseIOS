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
        int index = [boxes indexOfObject:box];
        NSArray *remainingBoxes = [boxes subarrayWithRange:NSMakeRange(index, boxes.count - index)];
        BOOL addedBox = NO;
        for (MHRoom *room in self.rooms) {
            if ([self canAddBox:box toRoom:room withRemaining:remainingBoxes]) {
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

- (BOOL)canAddBox:(MHBox *)box toRoom:(MHRoom *)room withRemaining:(NSArray *)remainingBoxes {
    BOOL noRoom = box.volumeInSquareMeters > [self remainingCapacity:room];
    BOOL tooLarge = box.volumeInSquareMeters > 50 && room.requiresStairs;
    BOOL dangerous = ~room.hazmatFlags & box.hazmatFlags;
    if (room.hazmatFlags && !box.hazmatFlags) {
        int remainingHazmat = [self remainingHazmatCapacity];
        for (MHBox *currentBox in remainingBoxes) {
            if (currentBox.hazmatFlags) {
                remainingHazmat -= currentBox.volumeInSquareMeters;
            }
        }
        if (remainingHazmat - box.volumeInSquareMeters < 0) {
            noRoom = YES;
        }
    }
    return !(noRoom || tooLarge || dangerous);
}

- (int)remainingHazmatCapacity {
    int capacity = 0;
    for (MHRoom *room in self.rooms) {
        if (room.hazmatFlags) {
            capacity += [self remainingCapacity:room];
        }
    }
    return capacity;
}

- (int)remainingCapacity:(MHRoom *)room {
    int capacity = room.capacityInSquareMeters;
    for (MHBox *box in room.boxes) {
        capacity -= box.volumeInSquareMeters;
    }
    return capacity;
}

@end
