#import <XCTest/XCTest.h>
#import "MHWarehouse.h"
#import "MHRoom.h"
#import "MHBox.h"
#import "MHHazmatFlags.h"

#define XCTAssertEqualContents(FIRST__, SECOND__) XCTAssertEqualObjects([NSSet setWithArray:FIRST__], [NSSet setWithArray:SECOND__])

@interface MHWarehouseIOS_Tests : XCTestCase

@end

@implementation MHWarehouseIOS_Tests

- (void)testWhenOneBoxIsAddedToOneRoomThenTheRoomContainsTheBox {
    MHRoom *loadingDock = [[MHRoom alloc] initWithVolumeInSquareMeters:100];
    
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock]];
    
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10];
    
    [testObject addBoxes:@[box1]];
    XCTAssertEqualContents(loadingDock.boxes, @[box1]);
}

- (void)testWhenBoxesAreAddedThenTheyAreAddedToFirstRoomFirstUntilCapacityIsReached {
    MHRoom *loadingDock = [[MHRoom alloc] initWithVolumeInSquareMeters:100];
    MHRoom *mainStorage = [[MHRoom alloc] initWithVolumeInSquareMeters:1000];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:70];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:15];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:10];
    
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock, mainStorage]];
    
    [testObject addBoxes:@[box1, box2, box3, box4]];
    
    NSArray *expected = @[box1, box2, box3];
    XCTAssertEqualContents(loadingDock.boxes, expected);
    XCTAssertEqualContents(mainStorage.boxes, @[box4]);
}

- (void)testWhenBoxOver50VolumeIsLoadedThenItIsNotLoadedInARoomRequiringStairs {
    MHRoom *basement = [[MHRoom alloc] initWithVolumeInSquareMeters:1000 andStairs:YES];
    MHRoom *mainStorage = [[MHRoom alloc] initWithVolumeInSquareMeters:1000 andStairs:NO];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:50];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:51];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:10];
    
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[basement, mainStorage]];
    
    [testObject addBoxes:@[box1, box2, box3, box4]];
    
    NSArray *expected = @[box1, box2, box4];
    XCTAssertEqualContents(basement.boxes, expected);
    XCTAssertEqualContents(mainStorage.boxes, @[box3]);
}

- (void)testWhenBoxesExceedCapacityThenFinalBoxesAreRejected {
    MHRoom *loadingDock = [[MHRoom alloc] initWithVolumeInSquareMeters:100];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:40];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:40];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:40];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:10];
    
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock]];
    
    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4]];
    
    NSArray *expected = @[box1, box2, box4];
    XCTAssertEqualContents(loadingDock.boxes, expected);
    XCTAssertEqualContents(rejectedBoxes, @[box3]);
}

- (void)testWhenChemicalBoxIsLoadedItIsLoadedInSafeRoom {
    MHRoom *loadingDock = [[MHRoom alloc] initWithVolumeInSquareMeters:100 andStairs:NO andHazmatFlags:MHHazmatFlagsNone];
    MHRoom *chemStorage = [[MHRoom alloc] initWithVolumeInSquareMeters:100 andStairs:NO andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];
    
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock, chemStorage]];
    
    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3]];
    
    NSArray *expected = @[box1, box3];
    XCTAssertEqualContents(loadingDock.boxes, expected);
    XCTAssertEqualContents(chemStorage.boxes, @[box2]);
    XCTAssertTrue(rejectedBoxes.count == 0);
}

- (void)testWhenHazmatHasNoSafeRoomThenItIsRejected {
    MHRoom *loadingDock = [[MHRoom alloc] initWithVolumeInSquareMeters:100 andStairs:NO andHazmatFlags:MHHazmatFlagsNone];
    MHRoom *mainStorage = [[MHRoom alloc] initWithVolumeInSquareMeters:1000 andStairs:NO andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];
    
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock, mainStorage]];
    
    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3]];
    
    NSArray *expected = @[box1, box3];
    XCTAssertEqualContents(loadingDock.boxes, expected);
    XCTAssertEqualContents(mainStorage.boxes, @[]);
    XCTAssertEqualContents(rejectedBoxes, @[box2]);
}

- (void)testDifferentHazmatBoxesCanBeStoredInDifferentRoomsWhileStillRespectingSizeAndStairs {
    MHRoom *loadingDock = [[MHRoom alloc] initWithVolumeInSquareMeters:100 andStairs:NO andHazmatFlags:MHHazmatFlagsNone];
    MHRoom *chemLoft = [[MHRoom alloc] initWithVolumeInSquareMeters:100 andStairs:YES andHazmatFlags:MHHazmatFlagsChemical];
    MHRoom *vault = [[MHRoom alloc] initWithVolumeInSquareMeters:150 andStairs:NO andHazmatFlags:MHHazmatFlagsChemical | MHHazmatFlagsNuclear];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNuclear];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNuclear | MHHazmatFlagsChemical];
    MHBox *box5 = [[MHBox alloc] initWithName:@"box5" andVolumeInSquareMeters:50 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box6 = [[MHBox alloc] initWithName:@"box6" andVolumeInSquareMeters:50 andHazmatFlags:MHHazmatFlagsChemical];
    
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock, chemLoft, vault]];
    
    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4, box5, box6]];
    
    XCTAssertEqualContents(loadingDock.boxes, @[]);
    NSArray *expected = @[box1, box5];
    XCTAssertEqualContents(chemLoft.boxes, expected);
    expected = @[box2, box3, box4, box6];
    XCTAssertEqualContents(vault.boxes, expected);
    XCTAssertTrue(rejectedBoxes.count == 0);
}

- (void)testBoxesAreNotPlacedSuchThatAHazmatWillHaveNoPlaceToGoWhenThereIsEnoughRoom {
    MHRoom *vault = [[MHRoom alloc] initWithVolumeInSquareMeters:150 andStairs:NO andHazmatFlags:MHHazmatFlagsChemical | MHHazmatFlagsNuclear];
    MHRoom *mainStorage = [[MHRoom alloc] initWithVolumeInSquareMeters:1000 andStairs:NO andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box5 = [[MHBox alloc] initWithName:@"box5" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsChemical];
    
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[vault, mainStorage]];
    
    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4, box5]];
    
    NSArray *expected = @[box1, box5];
    XCTAssertEqualContents(vault.boxes, expected);
    expected = @[box2, box3, box4];
    XCTAssertEqualContents(mainStorage.boxes, expected);
    XCTAssertTrue(rejectedBoxes.count == 0);
}

- (void)testOrderForBoxesIsPreservedWhenThereIsEnoughRoom {
    MHRoom *vault = [[MHRoom alloc] initWithVolumeInSquareMeters:150 andStairs:NO andHazmatFlags:MHHazmatFlagsChemical | MHHazmatFlagsNuclear];
    MHRoom *mainStorage = [[MHRoom alloc] initWithVolumeInSquareMeters:1000 andStairs:NO andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:30 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box5 = [[MHBox alloc] initWithName:@"box5" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsChemical];
    
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[vault, mainStorage]];
    
    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4, box5]];
    
    NSArray *expected = @[box1, box4, box5];
    XCTAssertEqualContents(vault.boxes, expected);
    expected = @[box2, box3];
    XCTAssertEqualContents(mainStorage.boxes, expected);
    XCTAssertTrue(rejectedBoxes.count == 0);
}

@end
