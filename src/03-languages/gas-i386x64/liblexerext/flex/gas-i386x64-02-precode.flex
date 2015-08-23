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
