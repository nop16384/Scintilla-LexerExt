/*
    *****************************************************************************
    *                                                                           *
    *   llg-iface.hhi                                                           *
    *                                                                           *
    *   --------------------------------------------------------------------    *
    *                                                                           *
    *   part of LexerExt                                                        *
    *                                                                           *
    *   Copyright (C) 2011-2013 Guillaume Wardavoir                             *
    *                                                                           *
    *   --------------------------------------------------------------------    *
    *                                                                           *
    *   This program is free software; you can redistribute it and/or modify    *
    *   it under the terms of the GNU General Public License as published by    *
    *   the Free Software Foundation; either version 2 of the License, or       *
    *   (at your option) any later version.                                     *
    *                                                                           *
    *   This program is distributed in the hope that it will be useful,         *
    *   but WITHOUT ANY WARRANTY; without even the implied warranty of          *
    *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           *
    *   GNU General Public License for more details.                            *
    *                                                                           *
    *   You should have received a copy of the GNU General Public License       *
    *   along with this program; if not, write to the Free Software             *
    *   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301,   *
    *   USA.                                                                    *
    *                                                                           *
    *****************************************************************************
*/

//  ############################################################################
//
//  liblexerext interface for LexerExt
//
//  ############################################################################
namespace liblexerext
{

//  ============================================================================
//  INITIAIZATION
//  ============================================================================
typedef     void        (*FnInit)               (void);
//  ============================================================================
//  LEXING CORE
//  ============================================================================
//  ............................................................................
//  reset the lexer before each lexing
typedef     void        (*FnReset)              (void*,int,int,int, void*,int);
typedef     bool        (*FnLexBuffer)          ();

//  ............................................................................
//  retrieve tokens computed by the lexer
typedef     int         (*FnGetTokensCount)     (void);
typedef     void    *   (*FnGetTokens)          (void);
//  ============================================================================
//  LEXING ACCESSORIES
//  ============================================================================
//  set special words, useful for token's colorization

//  these values _MUST_ correspond to the order of the strings from the variable
//  static const char * const extWordListDesc[] = { ... }
//  defined in the file "LexExt-02.0001.001-options.hhi"
enum
{
    eWordListInstructionsPrefix     =   0   ,
    eWordListInstructionsSuffix     =   1   ,
    eWordListInstructionsCPU        =   2   ,
    eWordListInstructionsFPU        =   3   ,
    eWordListInstructionsEXT        =   4   ,
    eWordListRegisters              =   7   ,
    eWordListDirectives             =   8   ,

    eWordListCard                   =   7
};

//  set a keyword
typedef     void        (*FnKeywordSet)         (int _n, const char* _w);
//  set a list of keywords
typedef     void        (*FnKeywordListSet)     (int _n, const char* _w);

//  ............................................................................
//  struct containing pointers on all liblexerext functions
typedef     struct      _tFunctionsPack         tFunctionsPack;
struct  _tFunctionsPack
{
    //  LexExt can call library
    FnInit              init;

    FnReset             reset;

    FnLexBuffer         lex_buffer;

    FnGetTokensCount    get_tokens_count;
    FnGetTokens         get_tokens;

    FnKeywordSet        keyword_set;
    FnKeywordListSet    keyword_list_set;
};

typedef     void        (*FnGetFunctionsPack)   (void*);


}

//  one call ( C binding, so no C++ name mangling ) for retrieving all
//  liblexerext functions
extern "C"
{
    void    liblexerext__GetFunctionsPack(void*);
}


