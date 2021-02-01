//
//  Switcher.h
//  PowerMate Control Center
//
// https://stackoverflow.com/questions/8161737/can-objective-c-switch-on-nsstring
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CaseBlock)(void);

@interface Switcher : NSObject

+ (void)switchOnString:(NSString *)tString
      using:(NSDictionary<NSString *, CaseBlock> *)tCases
withDefault:(CaseBlock)tDefaultBlock;

@end

NS_ASSUME_NONNULL_END
