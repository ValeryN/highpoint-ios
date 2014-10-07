//
// Created by Eugene on 02.10.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "User+NameForms.h"

@implementation User (NameForms)

- (NSString*) getNameForm:(NSUInteger) form{
    if(self.nameForms && ![self.nameForms isEqualToString:@""]) {
        NSArray *nameForms = [self.nameForms componentsSeparatedByString:@";"];
        if (nameForms.count > form)
            return nameForms[form];
    }

    return self.name;
}
@end