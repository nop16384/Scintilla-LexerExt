/*
    *****************************************************************************
    *                                                                           *
    *   i386x64.flex                                                             *
    *                                                                           *
    *   --------------------------------------------------------------------    *
    *                                                                           *
    *   part of GNU as lexer for Scintilla                                      *
    *                                                                           *
    *   Copyright (C) 2011-2014 Guillaume Wardavoir                             *
    *                                                                           *
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

/*
 *
 *******************************************************************************
 *
 *                              DEFINITIONS
 *
 *******************************************************************************
 *
 */

%option backup nostdinit noyywrap never-interactive full ecs
%option 8bit backup

    // nodefault : supress default rule, and exit(2) when unmatched input
    // %option nodefault

    // pointer / array
%option pointer

    // keep yylineno valid
%option yylineno

    // use exclusive states ( why not ? )
%x  STATE_I1
%x  STATE_I2
%x  STATE_I3
%x  STATE_I4

%x  STATE_LABEL
%x  STATE_EXPRESSION
%x  STATE_DIRECTIVE
%x  STATE_INSTRUCTION


%x  STATE_COMMENT_SL
%x  STATE_COMMENT_ML

%x  STATE_STRING

%x  STATE_NEWLINE

%x  STATE_NIMPL
%x  STATE_ERROR

%x  STATE_XSTE

%x  STATE_COMMENT_BLOCK


%option header-file="liblexerext-flex.hh"

/*
 *
 *******************************************************************************
 *
 *                              PRECODE
 *
 *******************************************************************************
 *
 */
%{
//  ============================================================================
//  INCLUDES
//  ============================================================================

// For flex invocation
#include    <limits.h>
#include    <stdio.h>
#include    <stdlib.h>
#include    <string.h>
#include    <unistd.h>

#include    <string>

#include    "liblexerext-common.hh"
//  ============================================================================
//  LEX PARAMS
//  ============================================================================

//  ============================================================================
//  DEBUGGING
//  ============================================================================
#ifdef  LLG_DEBUG__FLEX_LOG
    #define FLEX_LOG( FORMAT, ... )                                             \
        {                                                                       \
            printf(FORMAT, __VA_ARGS__);                                        \
        }
#else
    #define FLEX_LOG( FORMAT, ... )
#endif
//  ............................................................................
#ifdef  LLG_DEBUG__FLEX_DBG
    #define FLEX_DBG( STATE, FORMAT, ... )                                                          \
        {                                                                                           \
            printf("[%05i][%5u] %-25s:" FORMAT, sScintillaLineno(), sMcp(), STATE, __VA_ARGS__);    \
        }
#else
    #define FLEX_DBG( STATE, FORMAT, ... )
#endif
//  ............................................................................
#ifdef  LLG_DEBUG__FLEX_RULE_MATCH
    #define FLEX_DBM( STATE, FORMAT, ... )                                                              \
        {                                                                                               \
            printf("[%05i][%5u] %-25s:Match:" FORMAT, sScintillaLineno(), sMcp(), STATE, __VA_ARGS__);  \
        }
#else
    #define FLEX_DBM( STATE, FORMAT, ... )
#endif
//  ............................................................................
#ifdef  LLG_DEBUG__FLEX_RULE_MISMATCH
    #define FLEX_DBM_ERR( STATE, FORMAT, ... )                                                                          \
        {                                                                                                               \
            printf("[%5i][%5u] %-25s:%sMatch%s:" FORMAT, sScintillaLineno(), sMcp(), STATE, LLGC9, LLGNA, __VA_ARGS__); \
        }
#else
    #define FLEX_DBM_ERR( STATE, FORMAT, ... )
#endif
//  ============================================================================
//  ENUMS
//  ============================================================================
enum
{
    eFlexState_INITIAL      =   1   ,

    eFlexState_I1           =   2   ,
    eFlexState_I2           =   3   ,
    eFlexState_I3           =   4   ,
    eFlexState_I4           =   5   ,

    eFlexState_LABEL        =   6   ,
    eFlexState_EXPRESSION   =   7   ,
    eFlexState_DIRECTIVE    =   8   ,
    eFlexState_INSTRUCTION  =   9   ,
    //  ........................................................................

    eFlexState_COMMENT_SL   =   10  ,
    eFlexState_COMMENT_ML   =   11  ,

    eFlexState_STRING       =   12  ,

    eFlexState_NEWLINE      =   29  ,
    eFlexState_NIMPL        =   30  ,
    eFlexState_Error        =   31
};
//  ============================================================================
//  GLOBAL FUNCTIONS / VARS
//  ============================================================================
        void    FlexReset(int _start_pos, int _first_line, int _first_line_flags);
//  ============================================================================
//U static  int     s_state_current                 =   eFlexState_INITIAL;

//U static  int     sStateCurrent()                 { return s_state_current;   }

void    state_begin(int _state, int _pos);
#define FLEX_BEGIN_STATE( STATE, POS )                                          \
    FLEX_FCP_PUSH( POS );                                                       \
    state_begin( eFlexState_ ## STATE, POS );

#define FLEX_BEGIN_STATE_INT( STATE, POS )                                      \
    FLEX_FCP_PUSH( POS );                                                       \
    state_begin( STATE, POS );
//  ============================================================================
static  int     s_flex_scintilla_start_pos      =   0;
static  int     s_flex_scintilla_line_start     =   0;

//  sScintillaLineno() is used only in some macros
#if     defined( LLG_DEBUG__FLEX_DBG            )   ||                          \
        defined( LLG_DEBUG__FLEX_RULE_MATCH     )   ||                          \
        defined( LLG_DEBUG__FLEX_RULE_MISMATCH  )

static  int     sScintillaLineno()
{
    return  ( yylineno + s_flex_scintilla_line_start + 1 );                     //  +1 for matching line number displayed within SCITE
}

#endif
//  ============================================================================
static  int     s_flex_start_positions          [5];
static  int     s_flex_match_positions          [5];
static  int     s_flex_start_positions_index    =   0;
static  int     s_flex_match_positions_index    =   0;
static  int     s_flex_states_positions_index   =   0;
static  int     s_flex_last_colourized_pos      =   -1;

//U static  int     sIdx();
//U static  int     sIdxFcp();
//U static  int     sIdxLcp();
static  void    sIdxRaz     ();
static  int     sFcp        (int _index);
static  int     sLcp        (int _index);
static  void    sFcpPush    (int _pos);
static  void    sLcpPush    (int _pos);
static  void    sPosDump();

static  void    sFlexAddToken( int _fcp, int _lcp, int _color)
{
    liblexerext::AddToken(_fcp, _lcp, _color);
    s_flex_last_colourized_pos  =   _lcp;
}

#define FLEX_FCP_PUSH( POS )    sFcpPush( POS );
#define FLEX_LCP_PUSH( POS )    sLcpPush( POS );

#define FLEX_POS_RAZ()          sIdxRaz();

#define FLEX_POS_RST( POS )                                                     \
    sIdxRaz();                                                                  \
    sFcpPush( POS );

#define FLEX_TOK_ADD( COLOR )               sFlexAddToken( sFcp(0)  ,   sLcp(0)  ,  COLOR );
#define FLEX_TOK_ADD_S( IX, COLOR )         sFlexAddToken( sFcp(IX) ,   sLcp(IX) ,  COLOR );
#define FLEX_TOK_ADD_F( IX1, IX2, COLOR )   sFlexAddToken( sFcp(IX1),   sFcp(IX2),  COLOR );
#define FLEX_TOK_ADD_L( IX1, IX2, COLOR )   sFlexAddToken( sLcp(IX1),   sLcp(IX2),  COLOR );
#define FLEX_TOK_ADD_D( IX1, IX2, COLOR )   sFlexAddToken( sFcp(IX1),   sLcp(IX2),  COLOR );
#define FLEX_TOK_ADD_R( IX1, IX2, COLOR )   sFlexAddToken( sFcp(IX1),   sLcp(IX2),  COLOR );
#define FLEX_TOK_ADD_A( COLOR )             sFlexAddToken( sFcp(0)  ,   sLcp( sIdxLcp() - 1 ),  COLOR );
//  ============================================================================
int     a_mcp;

int     sMcp()      {   return a_mcp;   }

#define FLEX_REWIND()                                                           \
{                                                                               \
    yyless(0);                                                                  \
    a_mcp = a_mcp - 1;      /* because of YY_USER_ACTION */                     \
}
//  ============================================================================
//  at each beginning of line ( {nl} match rule ), set the line flags with
//  these macros
#define FLEX_LFLAGS_SET_SL()                                                    \
{                                                                               \
    /* test yytext[0] for .|{nl} as well as {nl} rules */                       \
    if ( yytext[0] == '\n' )                                                    \
        liblexerext::SetLineFlags( yylineno, 0 );                               \
}
#define FLEX_LFLAGS_SET_ML(ML_STATE, ML_PREVIOUS_STATE)                         \
{                                                                               \
        liblexerext::SetLineFlags                                               \
        (                                                                       \
            yylineno                ,                                           \
            sLineFlagsFromFlexStates(                                           \
                ML_STATE            ,                                           \
                ML_PREVIOUS_STATE   )                                           \
        );                                                                      \
}

static  int     s_start_ml_state            =   0;
static  int     s_start_ml_previous_state   =   0;
//! \enum       eLineFlags
//! \brief      Used for memorizing lexing information in multiline operations
//! \details    It is an int ( only the 16 low-bits ) coding :
//!                 - the ml   state        ( 5 bits ) mask : 0b00000000 00011111  = 0x001f
//!                 - the flex state        ( 5 bits ) mask : 0b00000011 11100000  = 0x03e0
static  int     sLineFlagsToMLState(int _line_flags)
{
    return ( _line_flags & 0x0000001f );
}
static  int     sLineFlagsToMLPreviousState(int _line_flags)
{
    return ( ( _line_flags & 0x000003e0 ) >> 5 );
}
static  int     sLineFlagsFromFlexStates(int _ml_state, int _ml_previous_state)
{
    return ( _ml_state | ( _ml_previous_state << 5 ) );
}
//  ============================================================================
static  bool        s_flag_initial_local    =   false;

static  bool        sFlagILoc()     { return s_flag_initial_local;      }
static  void        sFlagILocSet()  { s_flag_initial_local  =   true;   }
static  void        sFlagILocRst()  { s_flag_initial_local  =   false;  }
//  ============================================================================
static  bool        s_flag_initial_dot      =   false;

static  bool        sFlagIDot()     { return s_flag_initial_dot;        }
static  void        sFlagIDotSet()  { s_flag_initial_dot    =   true;   }
static  void        sFlagIDotRst()  { s_flag_initial_dot    =   false;  }
//  ============================================================================
static  std::string sIWordSymbol;
//  ============================================================================
//  STATE_INITIAL ( I1 ), I2, I3, I4 variables & functions
//  ============================================================================
static  void    sBegin_state_INITIAL(int _pos);
static  void    sBegin_state_I1(int _pos);
static  void    sBegin_state_I2(int _pos);
static  void    sBegin_state_I3(int _pos);
static  void    sBegin_state_I4(int _pos);
//  ============================================================================
//  STATE_LABEL
//  ============================================================================
static  void    sBegin_state_LABEL(int _pos);
//  ============================================================================
//  STATE_EXPRESSION
//  ============================================================================
static  void    sBegin_state_EXPRESSION(int _pos);
//  ============================================================================
//  STATE_DIRECTIVE variables & functions
//  ============================================================================
static  void    sBegin_state_DIRECTIVE(int _pos);
//  ============================================================================
//  STATE_INSTRUCTION variables & functions
//  ============================================================================
static  void    sBegin_state_INSTRUCTION(int _pos);

static  void    sRT_state_INSTRUCTION_prepare();
//  ============================================================================
//  STATE_COMMENT_SL variables & functions
//  ============================================================================
static  int     s_comment_sl_rt_color;

static  void    sBegin_state_COMMENT_SL(int _pos);

static  int     sCOMMENT_SL_RT_color();
static  void    sCOMMENT_SL_RT_color_set(int _state);
//  ============================================================================
//  STATE_COMMENT_ML variables & functions
//  ============================================================================
static  int     s_comment_ml_rt_previous_state;

static  void    sBegin_state_COMMENT_ML(int _pos);

static  void    sCOMMENT_ML_RT_init(int _current_state);
static  int     sCOMMENT_ML_RT_previous_state();
static  void    sCOMMENT_ML_RT_previous_state_set(int _state);
//  ============================================================================
//  STATE_STRING variables & functions
//  ============================================================================
static  int     s_string_rt_previous_state;

static  void    sBegin_state_STRING(int _pos);

static  int     sSTRING_RT_previous_state();
static  void    sSTRING_RT_previous_state_set(int _state);
//  ============================================================================
//  STATE_NEWLINE variables & functions
//  ============================================================================
void    sBegin_state_NEWLINE(int _pos);
//  ============================================================================
//  STATE_NIMPL variables & functions
//  ============================================================================
void    sBegin_state_NIMPL(int _pos);
//  ============================================================================
//  STATE_ERROR variables & functions
//  ============================================================================
static  bool    a_st_error_token_added  =   false;

static  void    sStError_token_added_set(bool _b);
static  bool    sStError_token_added();

static  void    sBegin_st_error(int _pos);
//  ============================================================================
//  STATE_COMMENT_BLOCK variables & functions
//  ============================================================================
void    si_reset();
void    si_begin();
//  ============================================================================
//  GLOBAL defines, variables & functions
//  ============================================================================
#ifdef  LLG_DEBUG__FLEX_YY_USER_ACTION
    #define YY_USER_ACTION                                                          \
        {                                                                           \
            printf("=> [%i] + [%lu] => [%lu]\n", a_mcp, yyleng, a_mcp + yyleng );   \
            a_mcp = a_mcp + yyleng;                                                 \
        }
#else
    #define YY_USER_ACTION                                                      \
    {                                                                           \
        a_mcp = a_mcp + yyleng;                                                 \
    }
#endif
//  ............................................................................
char    flex_str_dummy[1024];


%}
                                                                                /*
    ============================================================================
                    FLEX REMARKS
    ============================================================================
    Notes :
    * Do not use name definitions ( {name} ) in character classes ( [] )
    * Regexps explanations:
        lstringdq       {dquote}(\\.|[^\"\n])*{dquote}
        \\.     for escaped characters within a string ex. "ABCD\"EFGH"
    ============================================================================
                    FOLLOWING IS FOR GAS version 2.25

    Remarks :

        - Octal numbers as constants are chars from [0-7], but escaped inside a
          string they are chars from [0-9]

    ============================================================================
    Notations:
        N   [0-9]
        n   [1-9]
        D   [n1][N+]
        B   C-B
        A   C-A
        V   [a-z0-9]
        I   [A-Za-Z0-9]
        i   [A-Za-z]
        S   [A-Za-z0-9_.$]
        s   [A-Za-z_.$]
    ----------------------------------------------------------------------------
    Symbols:
        Non-Local
            Usr                                 [wS]                            1
        Local
            Usr                                 [L1][wS]                        2

    Labels:
        Non-Local
            Usr                                 [wS][:1]                        3
        Local
            Gas                                 [L1][D1][B1][D1][:1]            4
            Gas Dollar                          [L1][D1][A1][D1][:1]            5
            Gas Undocumented-A                  [L1][D1][:1]                    13
            Usr Standard                        [L1][wS][:1]                    6
            Usr Numeric
            Usr     Declaration                 [D1][:1]                        7
            Usr     Reference                   [D1][b1] / [D1][f1]             8

    Directives:
        Gas                                     [.1][V+]                        9

    Instructions:
        Inst                                    [wI]                            10
        Inst   + Suffix / Prefix + Inst         [wI] [wI]                       11
        Prefix + Inst + Suffix                  [wI] [wI] [wI]                  12

    Comments:
        * Any '#' in the line
        * C-style multiline comment
        * If the --divide command line option has not been specified then the [/]
          character appearing anywhere on a line also introduces a line comment.

    Notes:
        * C-A and C-B exist for avoiding collisions between usr local symbols.
        * Two ways of differentiating (1) and (9) :
          - dictionnary of directives
          - scan for a [:] after the word
    ============================================================================
                                SYNTHESIS
    ============================================================================
    Statement parsing:

    ----------------------------------------------------------------------------
    INITIAL ( I1 )
    ----------------------------------------------------------------------------
    Get rid of [L1], and set a flag L. After that we have :

    Symbols:
        Non-Local
            Usr                                 [wS]                            1
        Local
            Usr                                 [wS]                            2   L

    Labels:
        Non-Local
            Usr                                 [wS][:1]                        3
        Local
            Gas                                 [D1][B1][D1][:1]                4   L
            Gas Dollar                          [D1][A1][D1][:1]                5   L
            Gas Undocumented-A                  [L1][D1][:1]                    13  L
            Usr Standard                        [wS][:1]                        6   L
            Usr Numeric
            Usr     Declaration                 [D1][:1]                        7

    Directives:
        Gas                                     [.1][V+]                        9

    Instructions:
        Inst                                    [wI]                            10
        Inst   + Suffix / Prefix + Inst         [wI] [wI]                       11
        Prefix + Inst + Suffix                  [wI] [wI] [wI]                  12
    ----------------------------------------------------------------------------
    I2
    ----------------------------------------------------------------------------
    * [wI], [V] are subsets of [wS]. So it is simplier to recognize a [wS] and
    work on yytext, settings dome flags :
        - D ( first char is dot )
    rather that defining specific flex states
    * 4, 5, 7 can be resolved easyly inside I2.

    After that we have :

    Symbols:                                                                        Flags
        Non-Local
            Usr                                 [wS]                            1       (D)
        Local
            Usr                                 [wS]                            2   L

    Labels:
        Non-Local
            Usr                                 [wS][:1]                        3       (D)
        Local
            Usr Standard                        [wS][:1]                        6   L   (D)

    Directives:
        Gas                                     [.1][V+]                        9       D

    Instructions:
        Inst                                    [wI]                            10
        Inst   + Suffix / Prefix + Inst         [wI] [wI]                       11
        Prefix + Inst + Suffix                  [wI] [wI] [wI]                  12
    ----------------------------------------------------------------------------
    I3
    ----------------------------------------------------------------------------
    Following next chars :
      - If immediate next char is [:]           ->  R(3 ,6)                 with L
      - If we get [ *][=] , symbol affectation  ->  R(1, 2)                 with L
      - If we get [ *], goto state I4 ( so we can count the number of spaces )

    After that we have :
                                                                                    Flags

    Directives:
        Gas                                     [.1][V+]                        9       D

    Instructions:
        Inst                                    [wI]                            10
        Inst   + Suffix / Prefix + Inst         [wI] [wI]                       11
        Prefix + Inst + Suffix                  [wI] [wI] [wI]                  12
    ----------------------------------------------------------------------------
    I4
    ----------------------------------------------------------------------------
    Easyly resloving of 9, 10, 11, 12
    ----------------------------------------------------------------------------
    INSTRUCTION
    ----------------------------------------------------------------------------
    Operands:

    Register:       %rax

    Immediate:      $0x16
                    movb $0x05, %al

    Memory:         displacement(base register, offset register, scalar multiplier)
                    movl    -4(%ebp, %edx, 4), %eax  # Full example: load *(ebp - 4 + (edx * 4)) into eax
                    movl    -4(%ebp), %eax           # Typical example: load a stack variable into eax
                    movl    (%ecx), %edx             # No offset: copy the target of a pointer into a register
                    leal    8(,%eax,4), %eax         # Arithmetic: multiply eax by 4 and add 8
                    leal    (%eax,%eax,2), %eax      # Arithmetic: multiply eax by 2 and add eax (i.e. multiply by 3)

    Numerical constants :

      - A binary integer is `0b' or `0B' followed by zero or more of the binary digits `01'.
      - An octal integer is `0' followed by zero or more of the octal digits (`01234567').
      - A decimal integer starts with a non-zero digit followed by zero or more digits (`0123456789').
      - A hexadecimal integer is `0x' or `0X' followed by one or more hexadecimal digits chosen from `0123456789abcdefABCDEF'.
      - Integers have the usual values. To denote a negative integer, use the prefix operator `-' discussed under expressions
    ============================================================================
                                                                                */

    //  ------------------------------------------------------------------------
    //  Numerical constants
    //  ------------------------------------------------------------------------
cNDec           [0-9]
cNdec           [1-9]
cNHex           [A-Fa-f0-9]
cNOct           [0-7]

    //  ------------------------------------------------------------------------

wNDecP          {cNdec}{cNDec}*
wNDecN          -{cNdec}{cNDec}*
wNDec           {wNDecN}|{wNDecP}

wNHex1          0x{cNHex}+
wNHex2          0X{cNHex}+
wNHex           {wNHex1}|{wNHex2}

wNBin1          0b[01]+
wNBin2          0B[01]+
wNBin           {wNBin1}|{wNBin2}

wNOct           0{cNOct}+

wNCst           {wNDec}|{wNHex}|{wNBin}|{wNOct}
    //  ------------------------------------------------------------------------
    //  Others
    //  ------------------------------------------------------------------------
nl              \n

cWsp            [ \t]

cLp             \(
cRp             \)
cComma          ,

cL              L
ca              C-A
cb              C-B

cS              [A-Za-z0-9_\\.$@]
cs              [A-Za-z_.$]

cI              [A-Za-z0-9]
ci              [A-Za-z]

cCol            :
cEqu            =
cDot            \.

cCtrlA          C-a
cCtrlB          C-b

    //  ------------------------------------------------------------------------

wS              {cs}{cS}*

wXste           ;

wLoc            {cDot}{cL}

wInst           {ci}{cI}+

wCtrlA          C-a
wCtrlB          C-b
    //  ------------------------------------------------------------------------
    //  Operands specific
    //  ------------------------------------------------------------------------
cReg            [A-Za-z0-9]
    //  ------------------------------------------------------------------------

wOPNCst         {wNCst}
wOPImm          ${wNCst}
wOPReg          %{cReg}+
    //  ------------------------------------------------------------------------
    //  Directive specific
    //      - no need to escape the '"' here, but in the rule yes
    //  ------------------------------------------------------------------------
cDIRTok         [^ "\n\t]
    //  ------------------------------------------------------------------------

wDIRTok         {cDIRTok}+
    //  ------------------------------------------------------------------------
    //  String specific
    //
    //  A string is written between double-quotes. It may contain double-quotes
    //  or null characters. The way to get special characters into a string is
    //  to escape these characters: precede them with a backslash `\' character.
    //      \b  Mnemonic for backspace; for ASCII this is octal code 010.
    //      \f  Mnemonic for FormFeed; for ASCII this is octal code 014.
    //      \n  Mnemonic for newline; for ASCII this is octal code 012.
    //      \r  Mnemonic for carriage-Return; for ASCII this is octal code 015.
    //      \t  Mnemonic for horizontal Tab; for ASCII this is octal code 011.
    //      \ digit digit digit
    //          An octal character code. The numeric code is 3 octal digits. For compatibility with other Unix systems, 8 and 9 are accepted as digits: for example, \008 has the value 010, and \009 the value 011.
    //      \x hex-digits...
    //          A hex character code. All trailing hex digits are combined.
    //          Either upper or lower case x works.
    //      \\  Represents one `\' character.
    //      \"  Represents one `"' character. Needed in strings to represent
    //          this character, because an unescaped `"' would end the string.
    //      \ anything-else
    //          Any other character when escaped by \ gives a warning,
    //          but assembles as if the `\' was not present. The idea is that
    //          if you used an escape sequence you clearly didn't want the
    //          literal interpretation of the following character.
    //          However as has no other interpretation, so as knows it is giving
    //          you the wrong code and warns you of the fact.
    //  Which characters are escapable, and what those escapes represent, varies
    //  widely among assemblers. The current set is what we think the BSD 4.2
    //  assembler recognizes, and is a subset of what most C compilers recognize.
    //  If you are in doubt, do not use an escape sequence.
    //
    //  _GWR_TODO_  multiline strings allowed ???
    //  ------------------------------------------------------------------------
    //  ------------------------------------------------------------------------
wSTREsc01   \\b
wSTREsc02   \\f
wSTREsc03   \\n
wSTREsc04   \\r
wSTREsc05   \\t
wSTREsc06   \\[0-9][0-9][0-9]
wSTREsc07   \\x[A-Fa-f0-9]+
wSTREsc08   \\\\
wSTREsc09   \\["]

wSTREsc     {wSTREsc01}|{wSTREsc02}|{wSTREsc03}|{wSTREsc04}|{wSTREsc05}|{wSTREsc06}|{wSTREsc07}|{wSTREsc08}|{wSTREsc09}
    //  ------------------------------------------------------------------------
    //  COMMENTs specific
    //  ------------------------------------------------------------------------
cCMTMLb         \*
cCMTMLbx        [^\*\n]
    //  ------------------------------------------------------------------------
wCMTSL1         #
wCMTSL2         ##
wCMTSL3         ###

wCMTMLa         \x2f\x2a
wCMTMLb         \x2a\x2f
%%
                                                                                /*
     ***************************************************************************
     *
     *                              RULES
     *
     * remember to use : styler.ColourTo(currentPos - ((currentPos > lengthDocument) ? 2 : 1), state);
     *
     *  Conventions :
     *
     *  - When a state begins, it first position has been initialized with the
     *    position of the first char that belongs to that state.
     *
     ***************************************************************************
                                                                                */
                                                                                /*
    ****************************************************************************
    STATE_INITIAL ( == STATE_I1 )

    Scan the beginning of a statement.

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
<INITIAL>
{
    /*
     *      comments
     */
{wCMTMLa}                                                                       {
        FLEX_DBM("INITIAL", "%s\n", "comment ml");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT_ML );
        FLEX_POS_RAZ    ();
        sCOMMENT_ML_RT_init( eFlexState_INITIAL );
        FLEX_BEGIN_STATE( COMMENT_ML, sMcp() + 1 );
}

{wCMTSL1}                                                                       {
        FLEX_DBM("INITIAL", "%s\n", "comment sl(#)");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT1 );

        sCOMMENT_SL_RT_color_set( SCE_GAS_COMMENT1 );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( COMMENT_SL, sMcp() + 1 );
}
{wCMTSL2}                                                                       {
        FLEX_DBM("INITIAL", "%s\n", "comment sl(##)");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT2 );

        sCOMMENT_SL_RT_color_set( SCE_GAS_COMMENT2 );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( COMMENT_SL, sMcp() + 1 );
}
{wCMTSL3}                                                                       {
        FLEX_DBM("INITIAL", "%s\n", "comment sl(###)");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT3 );

        sCOMMENT_SL_RT_color_set( SCE_GAS_COMMENT3 );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( COMMENT_SL, sMcp() + 1 );
}
    /*
     *      spaces
     */
{cWsp}+                                                                         {
        FLEX_DBM("INITIAL", "%s\n", "{cWsp}+");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DEFAULT );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      ".L" string
     */
{wLoc}                                                                          {
        FLEX_DBM("INITIAL", "%s\n", "{wLoc}");
        FLEX_LCP_PUSH   ( sMcp() );
        //  ( chaining positions, so no RAZ although state change )
        sFlagILocSet();                                                         //  set local flag
        FLEX_BEGIN_STATE( I2 , sMcp() + 1 );
    }
    /*
     *      xste, nexline
     */
{wXste}                                                                         {
        FLEX_DBG("INITIAL", "%s\n", "{wXste}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DEFAULT );
        FLEX_POS_RST    ( sMcp() + 1 );                                         //  _GWR_TODO_ xste should reset to INITIAL
    }
{nl}                                                                            {
        FLEX_DBM("INITIAL", "%s\n", "{nl}");
        FLEX_LFLAGS_SET_SL();

        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( NEWLINE, sMcp() + 1 );
    }
    /*
     *      AOC : jump to STAGE2
     */
.                                                                               {
        FLEX_DBM("INITIAL", "%s\n", "no {wLoc}");
        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( I2, sMcp() + 1 );
    }

}
                                                                                /*
    ****************************************************************************
    STATE_I2

    - on pos stack :  0          0
                     [i]    or  [i]  [k]
                                [j]
                                [.L]
    ****************************************************************************
                                                                                */
<STATE_I2>
{
    /*
     *      [D1][B1][D1][:1]                4   L
     */
{wNDecP}{wCtrlB}{wNDecP}{cCol}                                                  {   //  _GWR_TODO_ ensure .L
        FLEX_DBM("I2", "%s\n", "R4");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD_D  ( 0, 1, SCE_GAS_LABEL_GAS );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( LABEL, sMcp() + 1 );
    }
    /*
     *      [D1][A1][D1][:1]                5   L
     */
{wNDecP}{wCtrlA}{wNDecP}{cCol}                                                  {   //  _GWR_TODO_ ensure .L
        FLEX_DBM("I2", "%s\n", "R5");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD_D  ( 0, 1, SCE_GAS_LABEL_GAS );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( LABEL, sMcp() + 1 );
    }
    /*
     *      [D1][:1]                        7
     *      [L1][D1][:1]                    13  L
     */
{wNDecP}{cCol}                                                                  {   //  _GWR_TODO_ ensure no .L
        FLEX_DBM("I2", "%s\n", "R7, R13");
        if ( sFlagILoc() )
        {
            FLEX_DBM("I2", "%s\n", "R13");
            FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD_D  ( 0, 1, SCE_GAS_LABEL_GAS );                        //  [L1][D1][:1]
            FLEX_POS_RAZ    ();
            FLEX_BEGIN_STATE( LABEL, sMcp() + 1 );
        }
        else
        {
            FLEX_DBM("I2", "%s\n", "R7");
            FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD    ( SCE_GAS_LABEL_GAS );                              //  [D1][:1]
            FLEX_POS_RAZ    ();
            FLEX_BEGIN_STATE( LABEL, sMcp() + 1 );
        }
    }
    /*
     *      {wS} ; set D flag and go to I3
     */
{wS}                                                                            {
        FLEX_DBM("I2", "%s\n", "{wS}");

        if ( yytext[0] == '.' )
            sFlagIDotSet();

        sIWordSymbol.assign( yytext );

        FLEX_LCP_PUSH   ( sMcp() );
        //  ( chaining positions, so no RAZ although state change )
        FLEX_BEGIN_STATE( I3, sMcp() + 1 );
    }
    /*
     *      xste, newline, AOC : error
     */
.|{nl}                                                                          {
        FLEX_DBM_ERR("I2", "%s\n", "JAM");
        FLEX_LFLAGS_SET_SL();

        //  if ".L" colourize it
        if ( sFlagILoc() )
            FLEX_TOK_ADD    ( SCE_GAS_ERROR_SYNTAX_UNCOLORIZED );               //  [.L]

        FLEX_REWIND         ();
        FLEX_POS_RAZ        ();
        FLEX_BEGIN_STATE( Error, sMcp() + 1 );
    }
}
                                                                                /*
    ****************************************************************************
    STATE_I3

    - on pos stack :  0              0    1    2
                     [i] [k]    or  [i]  [k]  [m]
                     [j]            [j]  [l]
                     [wS]           [.L] [wS]
    ****************************************************************************
                                                                                */
<STATE_I3>
{
    /*
     *      [wS][:1]                        3       (D)
     *      [wS][:1]                        6   L   (D)
     */
{cCol}                                                                          {
        FLEX_DBM("I3", "%s\n", "R3,R6");

        if ( sFlagILoc() )
        {
            FLEX_DBM("I3", "%s\n", "R6");
            FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD_D  ( 0, 2, SCE_GAS_LABEL_GAS );                        //  [.L][wS][:1]
            FLEX_POS_RAZ    ();
            FLEX_BEGIN_STATE( LABEL, sMcp() + 1 );
        }
        else
        {
            FLEX_DBM("I3", "%s\n", "R3");
            FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD_D  ( 0, 1, SCE_GAS_LABEL_USR );                        //  [wS][:1]
            FLEX_POS_RAZ    ();
            FLEX_BEGIN_STATE( LABEL, sMcp() + 1 );
        }
    }
    /*
     *      [wS]                            1       (D)
     *      [wS]                            2   L
     */
{cWsp}*{cEqu}                                                                   {   //  _GWR_REM_ never empty token, even if 0 wsp
        FLEX_DBM("I3", "%s\n", "R1, R2");

        if ( sFlagILoc() )
        {
            FLEX_DBM("I3", "%s\n", "R2");
            FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD_D  ( 0, 1, SCE_GAS_LABEL_GAS );                        //  [.L][wS]
            FLEX_TOK_ADD_S  ( 2, SCE_GAS_DEFAULT );                             //  [ *][=1]
            //FLEX_BEGIN_STATE( Expression, sMcp() + 1 );
                FLEX_POS_RAZ    ();
                FLEX_BEGIN_STATE( NIMPL, sMcp() + 1 );                          //  _GWR_TODO_ Expression
        }
        else
        {
            FLEX_DBM("I3", "%s\n", "R1");
            FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD_S  ( 0, SCE_GAS_LABEL_USR );                           //  [wS]
            FLEX_TOK_ADD_S  ( 1, SCE_GAS_DEFAULT );                             //  [ *][=1]
            //FLEX_BEGIN_STATE( Expression, sMcp() + 1 );
                FLEX_POS_RAZ    ();
                FLEX_BEGIN_STATE( NIMPL, sMcp() + 1 );                          //  _GWR_TODO_ Expression
        }
    }
    /*
     *      9, 10, 11, 12 : count spaces and go to I4
     */
{cWsp}+                                                                         {   //  _GWR_TODO_ epurer, '.' superseeds 0 whitespace
        FLEX_DBM("I3", "%s\n", "R9, ( R10, R11, R12 )");
        //  ( chaining positions, so no RAZ although state change )
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_BEGIN_STATE( I4, sMcp() + 1 );
    }
    /*
     *      xste, AOC : error
     */
.                                                                                {
        FLEX_DBM_ERR("I3", "%s\n", "JAM");

        if ( sFlagILoc() )
        {
            ////FLEX_DBM("I3", "%s\n", "R6");
            ////FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD_D  ( 0, 1, SCE_GAS_ERROR_SYNTAX_UNCOLORIZED );         //  [.L][wS]
        }
        else
        {
            ////FLEX_DBM("I3", "%s\n", "R3");
            ////FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD    ( SCE_GAS_ERROR_SYNTAX_UNCOLORIZED );               //  [wS]
        }
        FLEX_REWIND         ();
        FLEX_POS_RAZ        ();
        FLEX_BEGIN_STATE( Error, sMcp() + 1 );
    }
    /*
     *      {nl} : error / directive / inst
     */
{nl}                                                                            {
        FLEX_LFLAGS_SET_SL();

        if ( sFlagILoc() )
        {
            FLEX_DBM_ERR("I3", "%s\n", "[.L][wS][nl]");
            ////FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD_D      ( 0, 1, SCE_GAS_ERROR_SYNTAX_UNCOLORIZED );     //  [.L][wS]

            FLEX_REWIND         ();
            FLEX_POS_RAZ        ();
            FLEX_BEGIN_STATE    ( Error, sMcp() + 1 );
        }
        else
        {
            if ( sFlagIDot() )
            {
                FLEX_DBM("I3", "%s\n", "[.DIRECTIVE][nl]");
                ////FLEX_LCP_PUSH   ( sMcp() );
                FLEX_TOK_ADD        ( SCE_GAS_DIRECTIVE );                      //  [wS]    D

                FLEX_REWIND         ();
                FLEX_POS_RAZ        ();
                FLEX_BEGIN_STATE    ( NEWLINE, sMcp() + 1 );
            }
            else
            {
                FLEX_DBM_ERR("I3", "%s\n", "[wS][nl]");

                FLEX_REWIND         ();
                ////FLEX_BEGIN_STATE    ( INSTRUCTION, sMcp() + 1 );

                FLEX_TOK_ADD        ( SCE_GAS_INSTRUCTION_GENERIC );            //  [wS]    //  _GWR_TODO_  colourize in STATE_INSTTRUCTION

                FLEX_POS_RAZ        ();
                FLEX_BEGIN_STATE    ( NEWLINE, sMcp() + 1 );

            }
        }
    }
}
                                                                                /*
    ****************************************************************************
    STATE_I4

    - on pos stack :  0                  0    1    2    3
                     [i] [k]  [m]   or  [i]  [k]  [m]  [p]
                     [j] [l]            [j]  [l]  [n]
                     [wS][ +]           [.L] [wS] [ +]
    ****************************************************************************
                                                                                */
<STATE_I4>
{
    /*
     *      [.1][V+]                        9       D
     *      [wI]                            10
     *      [wI] [wI]                       11
     *      [wI] [wI] [wI]                  12
     *
     *      Act accordingly to the first non-wsp char ( wsp chars have been
     *      handled by STATE_I3 )
     */
.|{nl}                                                                          {
        FLEX_DBM("I4", "%s\n", "R9, ( R10, R11, R12 )");
        FLEX_LFLAGS_SET_SL();

        if ( sFlagILoc() )
        {
            FLEX_DBM_ERR("I4", "%s\n", "R9 ERROR");
            FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD_D  ( 0, 2, SCE_GAS_ERROR_SYNTAX_UNCOLORIZED );         //  [.L][wS][ +]

            FLEX_REWIND         ();
            FLEX_POS_RAZ        ();
            FLEX_BEGIN_STATE( Error, sMcp() + 1 );
        }
        else
        {
            if ( sFlagIDot() )
            {
                FLEX_DBM("I4", "%s\n", "R9 (ok)");
                FLEX_TOK_ADD_S  ( 0, SCE_GAS_DIRECTIVE );                       //  [wS]
                FLEX_TOK_ADD_S  ( 1, SCE_GAS_DEFAULT );                         //  [ +]

                FLEX_REWIND();
                FLEX_POS_RAZ    ();
                FLEX_BEGIN_STATE( DIRECTIVE, sMcp() + 1 );
            }
            else
            {
                FLEX_DBM("I4", "%s\n", "R10, R11, R12 (ok)");

                FLEX_TOK_ADD_S  ( 0, SCE_GAS_INSTRUCTION_GENERIC );             //  [wS]
                FLEX_TOK_ADD_S  ( 1, SCE_GAS_DEFAULT );                         //  [ +]

                FLEX_REWIND();
                FLEX_POS_RAZ    ();
                FLEX_BEGIN_STATE( INSTRUCTION, sMcp() + 1 );                    //  _GWR_TODO_  colourize in STATE_INSTRUCTION
            }
        }
    }
}


























                                                                                /*
    ****************************************************************************
    STATE_LABEL

    Nothing is allowed after the [:] ( except spaces )

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
<STATE_LABEL>
{

{cWsp}+                                                                         {
        FLEX_DBM("LABEL", "%s\n", "{cWsp}+");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DEFAULT );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      xste, nexline
     */
{nl}                                                                            {
        FLEX_DBM("LABEL", "%s\n", "{nl}");
        FLEX_LFLAGS_SET_SL();

        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( NEWLINE, sMcp() + 1 );
    }
    /*
     *      any other char / string : error
     */
.                                                                               {
        FLEX_DBM_ERR("LABEL", "JAM [%02x] -> ERROR\n", yytext[0]);
        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( Error, sMcp() + 1 );                                  //  _GWR_TODO_ Memorization vs RAZ
    }

}
                                                                                /*
    ****************************************************************************
    STATE_DIRECTIVE

    Nothing is allowed after the [:] ( except spaces )

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
<STATE_DIRECTIVE>
{

{cWsp}+                                                                         {
        FLEX_DBM("DIRECTIVE", "%s\n", "{cWsp}+");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DEFAULT );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      xste
     *
    {wXste}                                                                         {
        FLEX_DBG("DIRECTIVE", "%s\n", "{wXste}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DEFAULT );
        FLEX_POS_RST    ( sMcp() + 1 );                                         //  _GWR_TODO_ xste should reset to INITIAL
    }
    */
    /*
     *      newline
     */
{nl}                                                                            {
        FLEX_DBM("DIRECTIVE", "%s\n", "{nl}");
        FLEX_LFLAGS_SET_SL();

        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( NEWLINE, sMcp() + 1 );
    }
    /*
     *      token
     */
{wDIRTok}                                                                       {
        FLEX_DBM("DIRECTIVE", "%s\n", "{wDIRTok}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DIRECTIVE_TOKEN );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      string start
     */
\"                                                                              {
        FLEX_DBM_ERR("DIRECTIVE", "%s\n", """");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_STRING );
        FLEX_POS_RAZ    ();
        sSTRING_RT_previous_state_set( eFlexState_DIRECTIVE );
        FLEX_BEGIN_STATE( STRING, sMcp() + 1);
    }
    /*
     *      AOC ( no free char so not matching rule for instant )
     */
    /*.                                                                               {
        FLEX_DBM_ERR("DIRECTIVE", "[%02x]", yytext[0]);
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DIRECTIVE_TOKEN );
        FLEX_POS_RST    ( sMcp() + 1 );
    }*/
}
                                                                                /*
    ****************************************************************************
    STATE_INSTRUCTION

    Scan the beginning of a statement.

    - on pos stack :  0   1   2
                     [i] [k] [m]    or      [i] [k]
                     [j] [l]                [j]      ( + nl immedately after )
                     [wS][ +]               [wS]

    - on pos stack :  0
                     [i]

    - wS is stored in sIWordSymbol
    ****************************************************************************
                                                                                */
<STATE_INSTRUCTION>
{
    /*
     *      comment sl
     */
{wCMTSL1}                                                                       {
        FLEX_DBM("INSTRUCTION", "%s\n", "comment sl(#)");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT1 );

        sCOMMENT_SL_RT_color_set( SCE_GAS_COMMENT1 );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( COMMENT_SL, sMcp() + 1 );
}
{wCMTSL2}                                                                       {
        FLEX_DBM("INSTRUCTION", "%s\n", "comment sl(#)");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT2 );

        sCOMMENT_SL_RT_color_set( SCE_GAS_COMMENT2 );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( COMMENT_SL, sMcp() + 1 );
}
{wCMTSL3}                                                                       {
        FLEX_DBM("INSTRUCTION", "%s\n", "comment sl(#)");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT3 );

        sCOMMENT_SL_RT_color_set( SCE_GAS_COMMENT3 );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( COMMENT_SL, sMcp() + 1 );
}

{cWsp}+                                                                         {
        FLEX_DBM("INSTRUCTION", "%s\n", "{cWsp}+");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DEFAULT );
        FLEX_POS_RST    ( sMcp() + 1 );
    }

{wOPImm}                                                                        {
        FLEX_DBM("INSTRUCTION", "%s\n", "{wOPImm}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_OPERAND_IMMEDIATE );
        FLEX_POS_RST    ( sMcp() + 1 );
    }

{wS}                                                                            {
        int n   =   SCE_GAS_OPERAND_SYMBOL;

        FLEX_DBM("INSTRUCTION", "%s\n", "{wInst}");
        FLEX_LCP_PUSH   ( sMcp() );

        //FLEX_TOK_ADD    ( SCE_GAS_INSTRUCTION_GENERIC );
        if ( liblexerext::IsInstruction( yytext, &n ) )
        {
            FLEX_DBG( "INSTRUCTION", "INST => [%s][%i]\n", yytext, n);
            FLEX_TOK_ADD    ( n );
        }
        else
        {
            FLEX_DBG( "INSTRUCTION", "SYM => [%s]\n", yytext);
            FLEX_TOK_ADD    ( n );
        }

        FLEX_POS_RST    ( sMcp() + 1 );
    }

{wOPNCst}                                                                       {
        FLEX_DBM("INSTRUCTION", "%s\n", "{wOPNcst}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_OPERAND_SCALAR );
        FLEX_POS_RST    ( sMcp() + 1 );
    }

{wOPReg}                                                                        {
        FLEX_DBM("INSTRUCTION", "%s %s\n", "{wOPReg}", yytext);
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_OPERAND_REGISTER );
        FLEX_POS_RST    ( sMcp() + 1 );
    }

{cLp}                                                                           {
        FLEX_DBM("INSTRUCTION", "%s\n", "{cLp}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_REVERSE );
        FLEX_POS_RST    ( sMcp() + 1 );
    }

{cRp}                                                                           {
        FLEX_DBM("INSTRUCTION", "%s\n", "{cRp}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_REVERSE );
        FLEX_POS_RST    ( sMcp() + 1 );
    }

{cComma}                                                                        {
        FLEX_DBM("INSTRUCTION", "%s\n", "{cComma}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_REVERSE );
        FLEX_POS_RST    ( sMcp() + 1 );
    }

.                                                                               {
        FLEX_DBM_ERR("INSTRUCTION", "[%02x]\n", yytext[0]);
        //FLEX_LCP_PUSH   ( sMcp() );
        //FLEX_TOK_ADD    ( SCE_GAS_ERROR_SYNTAX_UNCOLORIZED );

        FLEX_REWIND         ();
        FLEX_POS_RAZ        ();
        FLEX_BEGIN_STATE( Error, sMcp() + 1 );
    }

{nl}                                                                            {
        FLEX_DBM("INSTRUCTION", "%s\n", "{nl}");
        FLEX_LFLAGS_SET_SL();

        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( NEWLINE, sMcp() + 1 );
    }

}
                                                                                /*
    ****************************************************************************
    STATE_COMMENT_SL

    When entering this state, we point on the first char after the #-s

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
<STATE_COMMENT_SL>
{
    /*
     *      AOC
     */
.*                                                                              {
        FLEX_DBM("COMMENT_SL", "%s\n", "(text...)");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( sCOMMENT_SL_RT_color() );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      newline : exit state
     */
{nl}                                                                            {
        FLEX_DBM("COMMENT_SL", "%s\n", "{nl}");
        FLEX_LFLAGS_SET_SL();

        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( INITIAL, sMcp() + 1 );
    }
}
                                                                                /*
    ****************************************************************************
    STATE_COMMENT_ML

    When entering this state, we point on the first char after the '/''*'

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
<STATE_COMMENT_ML>
{
    /*
     *      AOC except '*'
     */
{cCMTMLbx}+                                                                     {
        FLEX_DBM("COMMENT_ML", "[%s][%s]\n","{cCMTMLbx}+", yytext);

        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT_ML );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      '*'( will be superseeded by following rule )
     */
{cCMTMLb}                                                                       {
        FLEX_DBM("COMMENT_ML", "[%s]\n", "isolated '*'");

        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT_ML );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      end string
     */
{wCMTMLb}                                                                       {
        FLEX_DBM("COMMENT_ML", "[%s]\n", "*/");

        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT_ML );
        FLEX_POS_RAZ    ()
        FLEX_BEGIN_STATE( INITIAL, sMcp() + 1 );
    }
    /*
     *      nl ( warning, flex has inc-ed yylineno ! )
     */
{nl}                                                                            {
        FLEX_DBM("COMMENT_ML", "%s\n", "{nl}");

        FLEX_LOG("ML NL:lineno[%05i]\n", yylineno);
        FLEX_LFLAGS_SET_ML(
                    eFlexState_COMMENT_ML           ,
                    sCOMMENT_ML_RT_previous_state() );

        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT_ML );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      exit state
     */
        /*{wCMTMLb}                                                                       {
        FLEX_DBM("COMMENT_ML", "%s\n", "");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT_ML );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( INITIAL, sMcp() + 1 );
    }*/
}
                                                                                /*
    ****************************************************************************
    STATE_STRING

    When entering this state, a '"' has been encountered

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
<STATE_STRING>
{
    /*
     *      Escape sequences
     *
     */
{wSTREsc}                                                                       {
        FLEX_DBM("STRING", "%s\n", "{wSTREsc}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_STRING_ESCAPE_SEQUENCE );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      Isolated '\' : allow multiline strings ???                          //  _GWR_TODO_ multiline strings ?
     */
    /*
\\                                                                              {
    }
    */
    /*
     *      Isolated '"' : string end
     */
\"                                                                              {
        FLEX_DBM("STRING", "%s\n", """");
        FLEX_LCP_PUSH       ( sMcp() );
        FLEX_TOK_ADD        ( SCE_GAS_STRING );
        FLEX_POS_RAZ        ();
        FLEX_BEGIN_STATE_INT( sSTRING_RT_previous_state(), sMcp() + 1 );
    }
    /*
     *      no xste inside string
     *
     */
    /*
     *      AOC ( no free char so not matching rule for instant )
     */
.                                                                               {
        FLEX_DBM_ERR("STRING", "[%02x]\n", yytext[0]);
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_STRING );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      newline : error                                                     //  _GWR_TODO_ multiline strings ?
     */
{nl}                                                                            {
        FLEX_DBM("STRING", "%s\n", "{nl}");
        FLEX_LFLAGS_SET_SL();

        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( Error, sMcp() + 1 );
    }
}
                                                                                /*
    ****************************************************************************
    STATE_NEWLINE

    When entering this state, we point on the first newline encountered

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
<STATE_NEWLINE>
{
    /*
     *      newline
     */
{nl}                                                                            {
        FLEX_DBM("NEWLINE", "%s\n", "{nl}+");
        FLEX_LFLAGS_SET_SL();

        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DEFAULT );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( INITIAL, sMcp() + 1 );
    }
    /*
     *      any other : finish state
     */
.                                                                               {
        FLEX_DBM("NEWLINE", "%s\n", ".");
        FLEX_REWIND     ();
        FLEX_POS_RAZ    ()
        FLEX_BEGIN_STATE( INITIAL, sMcp() + 1 );
    }
}
                                                                                /*
    ****************************************************************************
    STATE_ERROR

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
<STATE_ERROR>
{
    /*
     *      xste, newline : no xste here, just newline ( avoid strings problem )
     */
{nl}                                                                            {
        FLEX_LFLAGS_SET_SL();

        if ( sStError_token_added() )
        {
            FLEX_DBM("ERROR", "%s\n", "{nl} - ok");

            FLEX_REWIND     ();
            FLEX_POS_RAZ    ();
            FLEX_BEGIN_STATE( NEWLINE, sMcp() + 1 );
        }
        /*  char that caused error is '\n'                                      */
        else
        {
            FLEX_DBM("ERROR", "%s\n", "{nl} ( but no token added ! )");

            FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD    ( SCE_GAS_ERROR_SYNTAX );
            FLEX_POS_RAZ    ();
            FLEX_BEGIN_STATE( INITIAL, sMcp() + 1 );
        }
    }
    /*
     *      any other -> colorize as error
     */
.*                                                                              {
        FLEX_DBM("ERROR", "[%i:%s]\n", (int)yyleng, yytext);
        sStError_token_added_set(true);
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_ERROR_SYNTAX );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
}

                                                                                /*
    ****************************************************************************
    STATE_NIMPL

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
    /*
     *  anything except newline
     */
<STATE_NIMPL>
{
    /*
     *  anything except newline
     */
.+                                                                              {
        FLEX_DBM("NIMPL", "%s\n", "---");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_STATE_NIMPL );
        FLEX_POS_RST    ( sMcp() + 1 );
    }

    /*
     *  newline
     */
{nl}                                                                            {
        FLEX_DBM("NIMPL", "%s\n", "{nl}");
        FLEX_LFLAGS_SET_SL();

        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( INITIAL, sMcp()  + 1);
    }
}
                                                                               /*
    ****************************************************************************
    <<EOF>>

    - <<EOF>> is handled identically everywhere

    - Strangely the general <<EOF>> rule has to be put after specialized <<EOF>>
    rules, else flex complains about <<EOF>> multiple rules.

    - Each lex ends here ( due to scintilla lex concept ) ; we have to
      BEGIN( INITIAL ) in case of buggy lexer which dont colorize the
      entire document : in this case scintilla re-lex, but the state would not
      be reinitialized !
    ****************************************************************************
                                                                                */
<<EOF>>                                                                         {
        int pos_lcc =   -1;
        int pos_eof =   -1;
        //  ....................................................................
        YY_USER_ACTION;                                                         //  at <<EOF>>, YY_USER_ACTION is not called

        pos_lcc =   s_flex_last_colourized_pos;
        pos_eof =   sMcp();

        FLEX_DBG("EOF", "%s\n", "<EOF>");

        FLEX_DBG("EOF", "last colourized pos[%i] sMcp()[%i]\n", pos_lcc, pos_eof);

        //  some chars are not colourized
        if ( ( pos_lcc + 1 ) != pos_eof )
        {
            //  no char at all was colorourized
            if ( pos_lcc == -1 )
            {
                pos_lcc =   s_flex_scintilla_start_pos - 1;                     //  -1 for +1 below
            }
            FLEX_POS_RAZ    ();
            FLEX_FCP_PUSH   ( pos_lcc + 1 );
            FLEX_LCP_PUSH   ( pos_eof - 1 );
            FLEX_TOK_ADD    ( SCE_GAS_ERROR_SYNTAX );
        }

        BEGIN( INITIAL );
        return 0;
    }

%%
/*
 *
 *******************************************************************************
 *
 *                              POSTCODE
 *
 *******************************************************************************
 *
 */

//  ============================================================================
//  GLOBAL FUNCTIONS
//  ============================================================================
void    FlexReset(int _start_pos, int _first_line, int _first_line_flags)
{
    yylineno                        =   0;
    s_flex_scintilla_start_pos      =   _start_pos;
    a_mcp                           =   _start_pos - 1;                         //  flex & scite char offsets differs from 1
    s_flex_last_colourized_pos      =   -1;                                     //  no token yet, set -1 as an 'invalid pos' marker
    s_flex_scintilla_line_start     =   _first_line;

    s_start_ml_state                =   sLineFlagsToMLState(_first_line_flags);
    s_start_ml_previous_state       =   sLineFlagsToMLPreviousState(_first_line_flags);

    FLEX_POS_RST( sMcp() + 1 );

    FLEX_LOG("Flex_reset():ml state[%03i] - previous [%03i]\n"  ,
        s_start_ml_state            ,
        s_start_ml_previous_state   );

    if ( s_start_ml_state == eFlexState_COMMENT_ML )
    {
        sCOMMENT_ML_RT_previous_state_set( s_start_ml_previous_state );
        sBegin_state_COMMENT_ML( 0 );
    }
}
//  ============================================================================
void    state_begin(int _state, int _pos)
{
    #ifdef  LLG_DEBUG__FLEX_ANNOUNCE_STATE_CHANGE
    printf("--------------------------------------------------------------------\n");
    printf("Beginning state [%i] @ [%5i][%5i]\n", _state, yylineno, _pos);
    #endif
    sPosDump();

    switch ( _state )
    {

    case    eFlexState_INITIAL          :   sBegin_state_INITIAL    ( _pos );   break;
    case    eFlexState_I1               :   sBegin_state_I1         ( _pos );   break;
    case    eFlexState_I2               :   sBegin_state_I2         ( _pos );   break;
    case    eFlexState_I3               :   sBegin_state_I3         ( _pos );   break;
    case    eFlexState_I4               :   sBegin_state_I4         ( _pos );   break;

    case    eFlexState_LABEL            :   sBegin_state_LABEL      ( _pos );   break;
    case    eFlexState_EXPRESSION       :   sBegin_state_EXPRESSION ( _pos );   break;
    case    eFlexState_DIRECTIVE        :   sBegin_state_DIRECTIVE  ( _pos );   break;
    case    eFlexState_INSTRUCTION      :   sBegin_state_INSTRUCTION( _pos );   break;

    case    eFlexState_COMMENT_SL       :   sBegin_state_COMMENT_SL ( _pos );   break;
    case    eFlexState_COMMENT_ML       :   sBegin_state_COMMENT_ML ( _pos );   break;

    case    eFlexState_STRING           :   sBegin_state_STRING     ( _pos );   break;

    case    eFlexState_NEWLINE          :   sBegin_state_NEWLINE    ( _pos );   break;

    case    eFlexState_NIMPL            :   sBegin_state_NIMPL      ( _pos );   break;

    case    eFlexState_Error            :   sBegin_st_error( _pos );    break;


    default:
    break;

    }

    //U s_state_current =   _state;
}
//  ============================================================================
//U int             sIdx()                      {   return s_flex_states_positions_index;   }
//U int             sIdxFcp()                   {   return s_flex_start_positions_index;    }
//U int             sIdxLcp()                   {   return s_flex_match_positions_index;    }

static  void    sIdxRaz()
{
    s_flex_start_positions_index    =   0;
    s_flex_match_positions_index    =   0;
    s_flex_states_positions_index   =   0;
}

static  int     sFcp        (int _index)    {   return  s_flex_start_positions[_index]; }
static  int     sLcp        (int _index)    {   return  s_flex_match_positions[_index]; }

static  void    sFcpPush    (int _pos)
{
    s_flex_start_positions[ s_flex_start_positions_index ++    ]   =   _pos;
}
static  void    sLcpPush    (int _pos)
{
    s_flex_match_positions[ s_flex_match_positions_index ++    ]   =   _pos;
    s_flex_states_positions_index++;
}
static  void    sPosDump()
{
    #ifdef  LLG_DEBUG__FLEX__DUMP_POSITIONS_AT_STATE_CHANGE
        printf("Dumping positions:");
        for ( int i = 0 ; i != s_flex_start_positions_index ; i++ )
            {   printf("[%03i]", sFcp(i));  }
        printf("\n");
        printf("                  ");
        for ( int i = 0 ; i != s_flex_match_positions_index ; i++ )
            {   printf("[%03i]", sLcp(i));  }
        printf("\n");
    #endif
}
//  ============================================================================
//  STATE_INITIAL variables & functions
//  ============================================================================
void    sBegin_state_INITIAL(int _pos)
{
    sFlagILocRst();
    sFlagIDotRst();
    BEGIN( INITIAL );
}
//  ============================================================================
//  STATE_I1
//  ============================================================================
void    sBegin_state_I1(int _pos)
{
    sBegin_state_INITIAL(_pos);
}
//  ============================================================================
//  STATE_I2
//  ============================================================================
void    sBegin_state_I2(int _pos)
{
    BEGIN( STATE_I2 );
}
//  ============================================================================
//  STATE_I3
//  ============================================================================
void    sBegin_state_I3(int _pos)
{
    BEGIN( STATE_I3 );
}
//  ============================================================================
//  STATE_I4
//  ============================================================================
void    sBegin_state_I4(int _pos)
{
    BEGIN( STATE_I4 );
}
//  ============================================================================
//  STATE_LABEL
//  ============================================================================
void    sBegin_state_LABEL(int _pos)
{
    BEGIN( STATE_LABEL );
}
//  ============================================================================
//  STATE_EXPRESSION
//  ============================================================================
void    sBegin_state_EXPRESSION(int _pos)
{
    BEGIN( STATE_EXPRESSION );
}
//  ============================================================================
//  STATE_DIRECTIVE
//  ============================================================================
void    sBegin_state_DIRECTIVE(int _pos)
{
    BEGIN( STATE_DIRECTIVE );
}
//  ============================================================================
//  STATE_INSTRUCTION
//  ============================================================================
void    sBegin_state_INSTRUCTION(int _pos)
{
    sRT_state_INSTRUCTION_prepare();

    BEGIN( STATE_INSTRUCTION );
}

void    sRT_state_INSTRUCTION_prepare()
{
}
//  ============================================================================
//  STATE_COMMENT_SL variables & functions
//  ============================================================================
static  void    sBegin_state_COMMENT_SL(int _pos)
{
    BEGIN( STATE_COMMENT_SL );
}

int     sCOMMENT_SL_RT_color()                  { return s_comment_sl_rt_color;     }
void    sCOMMENT_SL_RT_color_set(int _color)    { s_comment_sl_rt_color = _color;   }
//  ============================================================================
//  STATE_COMMENT_ML variables & functions
//  ============================================================================
void    sBegin_state_COMMENT_ML(int _pos)
{
    BEGIN( STATE_COMMENT_ML );
}

void    sCOMMENT_ML_RT_init(int _current_state)
{
    sCOMMENT_ML_RT_previous_state_set( _current_state );
    //liblexergas::SetLineFlags(yylineno, 0x1234);
}

int     sCOMMENT_ML_RT_previous_state()
{
    return s_comment_ml_rt_previous_state;
}
void    sCOMMENT_ML_RT_previous_state_set(int _state)
{
    s_comment_ml_rt_previous_state  = _state;
}
//  ============================================================================
//  STATE_STRING variables & functions
//  ============================================================================
void    sBegin_state_STRING(int _pos)
{
    BEGIN( STATE_STRING );
}

int     sSTRING_RT_previous_state()
{
    return s_string_rt_previous_state;
}
void    sSTRING_RT_previous_state_set(int _state)
{
    s_string_rt_previous_state  = _state;
}
//  ============================================================================
//  STATE_NEWLINE variables & functions
//  ============================================================================
void    sBegin_state_NEWLINE(int _pos)
{
    BEGIN( STATE_NEWLINE );
}
//  ============================================================================
//  STATE_NIMPL variables & functions
//  ============================================================================
void    sBegin_state_NIMPL(int _pos)
{
    BEGIN( STATE_NIMPL );
}
//  ============================================================================
//  STATE_ERROR variables & functions
//  ============================================================================
void    sStError_token_added_set(bool _b)
{
    a_st_error_token_added    =   _b;
}
bool    sStError_token_added()
{
    return a_st_error_token_added;
}

void    sBegin_st_error(int _pos)
{
    sStError_token_added_set(false);
    BEGIN( STATE_ERROR );
}
//  ============================================================================
//  STATE_COMMENT_BLOCK variables & functions
//  ============================================================================
void    scb_reset()
{
    //scb_color   = SCE_GAS_SYNTAX_UNKNOWN;
    //scb_type    =   0;
}
void    scb_begin(int _scb_type)
{
    //printf("> LGF():%4i +++ ( STATE_COMMENT_BLOCK [%i] ) +++\n", LexerGas::FlexCharPos(yytext), _scb_type);

    scb_reset();
    //scb_type    =   _scb_type;
    //if ( _scb_type == eLexGasFlexScb1 )
    {
        //scb_color   = SCE_GAS_COMMENT1;
    }
    //if ( _scb_type == eLexGasFlexScb2 )
    {
        //scb_color   = SCE_GAS_COMMENT2;
    }
    //if ( _scb_type == eLexGasFlexScb3 )
    {
        //scb_color   = SCE_GAS_COMMENT3;
    }

    BEGIN(STATE_COMMENT_BLOCK);
}

