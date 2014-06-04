//
//  HPLanguageStrings.h
//  scade.com
//
//  Created by Michael on 05.08.13.
//  Copyright (c) 2013 scade. All rights reserved.
//

//==============================================================================

#pragma once

//==============================================================================

#import <Foundation/Foundation.h>

//==============================================================================

#define L(str) NSLocalizedString(str, nil)

#define LT(str, table) NSLocalizedStringFromTable(str, table, nil)

#define NL(str) str
