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
    NSMutableArray *rejectedBoxes = [NSMutableArray array];
    for (MHBox *box in boxes) {
        BOOL foundRoom = NO;
        for (MHRoom *room in self.rooms) {
            BOOL roomIsFull = room.remainingVolumeInSquareMeters < box.volumeInSquareMeters;
            BOOL tooLargeForStairs = room.requiresStairs && box.volumeInSquareMeters > 50;
            BOOL unsafe = ~room.hazmatFlags & box.hazmatFlags;
            if (!roomIsFull && !tooLargeForStairs && !unsafe) {
                [room.boxes addObject:box];
                foundRoom = YES;
                break;
            }
        }
        if (!foundRoom) {
            [rejectedBoxes addObject:box];
        }
    }
    return rejectedBoxes;
}

@end
