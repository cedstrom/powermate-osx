//
//  Switcher.m
//  PowerMate Control Center
//
// https://stackoverflow.com/questions/8161737/can-objective-c-switch-on-nsstring
//

#import "Switcher.h"

@implementation Switcher

+ (void)switchOnString:(NSString *)tString
                 using:(NSDictionary<NSString *, CaseBlock> *)tCases
           withDefault:(CaseBlock)tDefaultBlock
{
    CaseBlock blockToExecute = tCases[tString];
    if (blockToExecute) {
        blockToExecute();
    } else {
        tDefaultBlock();
    }
}

@end
