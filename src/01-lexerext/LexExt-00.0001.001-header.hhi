//  ############################################################################
//  § LexExt-00-header.cci
//  ############################################################################
// Scintilla source code edit control
/** @file LexExt.cxx
 ** Lexer for x86 Assembler, just for the GNU as syntax, by gwr
 ** Inspired / Copied & Pasted from :
 **     LexAsm.cxx by The Black Horus & Kein-Hong Man & "Udo Lechner" <dlchnr(at)gmx(dot)net>
 **     LexCPP.cxx by Neil Hodgson <neilh@scintilla.org>
 **
 **     v.fb-001
 **/
// Copyright 1998-2003 by Neil Hodgson <neilh@scintilla.org>
// The License.txt file describes the conditions under which this software may be distributed.

#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <assert.h>
#include <ctype.h>
#include <dlfcn.h>

#include <string>
#include <map>
#include <set>

#include "ILexer.h"
#include "Scintilla.h"
#include "SciLexer.h"

#include "WordList.h"
#include "LexAccessor.h"
#include "StyleContext.h"
#include "CharacterSet.h"
#include "LexerModule.h"
#include "OptionSet.h"

#include    "Platform.h"

#include <list>
#include <vector>
#include <stack>
#include <queue>

#ifdef SCI_NAMESPACE
using namespace Scintilla;
#endif
