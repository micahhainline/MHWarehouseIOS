#import <Foundation/Foundation.h>
#import "MHBox.h"
#import "MHHazmatFlags.h"

@interface MHRoom : NSObject

@property (nonatomic, strong) NSMutableArray *boxes;
@property (nonatomic, readonly) int capacityInSquareMeters;
@property (nonatomic, readonly) MHHazmatFlags hazmatFlags;
@property (nonatomic, readonly) BOOL requiresStairs;

- (id)initWithName:(NSString *)name andCapacityInSquareMeters:(int)capacity andHazmatFlags:(MHHazmatFlags)hazmatFlags requiresStairs:(BOOL)requiresStairs;

@end
