/*
    *****************************************************************************
    *                                                                           *
    *   liblexerext.cc                                                          *
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

#include    <stdio.h>
#include    <stdlib.h>
#include    <string.h>

#include    "liblexerext-common.hh"
#include    "liblexerext-iface.hhi"
#include    "liblexerext.hh"
#include    "liblexerext-dico-tree.hh"
#include    "liblexerext-lexer.hh"
//  ============================================================================
int SCE_GAS_DEFAULT                     =   0;

int SCE_GAS_LABEL_GAS                   =   1;
int SCE_GAS_LABEL_USR                   =   2;

int SCE_GAS_DIRECTIVE                   =   3;
int SCE_GAS_DIRECTIVE_TOKEN             =   4;

int SCE_GAS_INSTRUCTION_GENERIC         =   5;
int SCE_GAS_INSTRUCTION_PREFIX          =   6;
int SCE_GAS_INSTRUCTION_SUFFIX          =   7;
int SCE_GAS_INSTRUCTION_CPU             =   8;
int SCE_GAS_INSTRUCTION_FPU             =   9;
int SCE_GAS_INSTRUCTION_EXT             =   10;

int SCE_GAS_OPERAND_SCALAR              =   15;
int SCE_GAS_OPERAND_SCALAR_DISPLACEMENT =   16;
int SCE_GAS_OPERAND_REGISTER            =   17;
int SCE_GAS_OPERAND_IMMEDIATE           =   18;
int SCE_GAS_OPERAND_SYMBOL              =   19;

int SCE_GAS_STRING                      =   20;
int SCE_GAS_STRING_ESCAPE_SEQUENCE      =   21;

int SCE_GAS_COMMENT_ML                  =   25;
int SCE_GAS_COMMENT1                    =   24;
int SCE_GAS_COMMENT2                    =   25;
int SCE_GAS_COMMENT3                    =   26;

int SCE_GAS_REVERSE                     =   28;
int SCE_GAS_STATE_NIMPL                 =   29;
int SCE_GAS_ERROR_SYNTAX_UNCOLORIZED    =   30;
int SCE_GAS_ERROR_SYNTAX                =   31;
//  ============================================================================
namespace liblexerext
{
//  ############################################################################
//
//                          VARS - DECLs
//
//  ############################################################################
//  ============================================================================
//   INIT
//  ============================================================================
static      void                Init();
//  ============================================================================
//   RESET
//  ============================================================================
static      void                Reset(void*, int, int, int, void*, int);
//  ============================================================================
//   ERRORS
//  ============================================================================
static      bool                a_error_malloc      =   false;
static      bool                a_error_lexer       =   false;
//  ----------------------------------------------------------------------------
static      void                ErrorMalloc()
    {
        a_error_malloc  =   true;
    }
static      bool                Errors()
    {
        return ( ( a_error_malloc ) || ( a_error_lexer ) );
    }
//  ============================================================================
//   KEYWORDS
//  ============================================================================
static      DTreeNode           a_dtn_instructions;
static      DTreeNode           a_dtn_directives;

static      DTreeNode       *   sDtnInst()
    {
        return & a_dtn_instructions;
    }
//  ----------------------------------------------------------------------------
static      void                KeywordSet      (int _n, const char* _keyword);
static      void                KeywordListSet  (int _n, const char* _keyword_list);
            int                 IsInstruction   (const char* _word, int* _data);
            bool                IsDirective     (const char* _word);
//  ============================================================================
//   TOKENS
//  ============================================================================
typedef struct _Token   Token; struct  _Token
{
    int         a_fcp;
    int         a_lcp;
    int         a_color;
};
//  ----------------------------------------------------------------------------
void    *   d_tokens            =   NULL;

int         a_tokens_allocated  =   0;
int         a_tokens_added      =   0;

int         a_last_token_lcp    =   0;
//  ----------------------------------------------------------------------------
        static  bool            AllocTokens(int);
inline  static  Token       *   GetToken(int _ix);
inline  static  Token       *   GetCurrentToken();
inline  static  void            NextToken();
                void            AddToken(int _u, int _v, int _c);
        static  int             GetTokensCount();
        static  void        *   GetTokens();
//  ============================================================================
//   LINE FLAGS
//  ============================================================================
void    *   a_lines_flags       =   NULL;
int         a_lines_flags_card  =   0;
int         a_first_line_index  =   0;
int         a_first_line_flags  =   0;
//  ----------------------------------------------------------------------------
            void                SetLineFlags(int _lix,int _flags);
//  ############################################################################
//
//                          FUNCTIONS
//
//  ############################################################################
//  ============================================================================
//  INITIALIZATION
//  ============================================================================
        void                    Init()
{
    if ( ! AllocTokens(16) )
        ErrorMalloc();
}
//  ============================================================================
//  RESET
//  ============================================================================
        void                    Reset(
            void    *   _lex_buffer                         ,
            int         _lex_length                         ,
            int         _lex_scintilla_start_pos            ,
            int         _lex_scintilla_first_line_index     ,
            void    *   _lex_scintilla_line_flags           ,
            int         _lex_scintilla_line_flags_card      )
{
    a_error_lexer       =   false;

    a_tokens_added      =   0;
    a_last_token_lcp    =   _lex_scintilla_start_pos - 1;

    a_lines_flags       =   _lex_scintilla_line_flags;
    a_lines_flags_card  =   _lex_scintilla_line_flags_card;
    a_first_line_index  =   _lex_scintilla_first_line_index;
    a_first_line_flags  =   *( (int*)a_lines_flags );

    liblexerext::lexer::Reset(
        _lex_buffer                     ,
        _lex_length                     ,
        _lex_scintilla_start_pos        ,
        _lex_scintilla_first_line_index ,
        a_first_line_flags              );
}
//  ============================================================================
//  KEYWORDS
//  ============================================================================
        void                    KeywordSet(int _n, const char* _keyword)
{
    int c   =   0;
    //  ........................................................................
    c   =   SCE_GAS_INSTRUCTION_GENERIC;

    switch ( _n )
    {

    case    liblexerext::eWordListInstructionsPrefix    :   c   =   SCE_GAS_INSTRUCTION_PREFIX;     break;
    case    liblexerext::eWordListInstructionsSuffix    :   c   =   SCE_GAS_INSTRUCTION_SUFFIX;     break;
    case    liblexerext::eWordListInstructionsCPU       :   c   =   SCE_GAS_INSTRUCTION_CPU;        break;
    case    liblexerext::eWordListInstructionsFPU       :   c   =   SCE_GAS_INSTRUCTION_FPU;        break;
    case    liblexerext::eWordListInstructionsEXT       :   c   =   SCE_GAS_INSTRUCTION_EXT;        break;

    }

    sDtnInst()->store(_keyword, c);

}
        void                    KeywordListSet(int _n, const char* _keyword_list)
{
    /*
    int c   =   0;
    //  ........................................................................
    c   =   SCE_GAS_INSTRUCTION_GENERIC;

    switch ( _n )
    {

    case    liblexerext::eWordListInstructionsPrefix    :   c   =   SCE_GAS_INSTRUCTION_PREFIX;     break;
    case    liblexerext::eWordListInstructionsSuffix    :   c   =   SCE_GAS_INSTRUCTION_SUFFIX;     break;
    case    liblexerext::eWordListInstructionsCPU       :   c   =   SCE_GAS_INSTRUCTION_CPU;        break;
    case    liblexerext::eWordListInstructionsFPU       :   c   =   SCE_GAS_INSTRUCTION_FPU;        break;
    case    liblexerext::eWordListInstructionsEXT       :   c   =   SCE_GAS_INSTRUCTION_EXT;        break;

    }

    sDtnInst()->store(_word, c);
    */
}

        int                     IsInstruction           (const char* _word, int* _data)
{
    return sDtnInst()->search(_word, _data);
}

        bool                    IsDirective             (const char* _word)
{
    return  false;//  sWlp()->wl_is_word_in( liblexerext::eWordListDirectives         , _word );
}
//  ============================================================================
//  TOKENS
//  ============================================================================
        bool                    AllocTokens(int _n)
{
    size_t  size    =   sizeof(liblexerext::Token) * _n;
    //  ........................................................................
    //  realloc
    if ( d_tokens )
    {
        //  Sor each file lexer, there is one LexerGas instance, but there
        //  is only one liblexer(...).so in memory. So each LexerGas call
        //  AllocTokens().
        //  If LexerGas1 needs 200, allocs 200, then LexerGas2 needs 100,
        //  the token copy corrupts memory, copying 200 bytes into 100
        //  allocated bytes
        //  => So only realloc, when more memory is needed.
        if ( _n <= a_tokens_allocated )                                         //  enough memory for this request
            return true;

        void    *   temp    =   malloc(  size );

        if ( ! temp )
        {
            LLG_TKE("NC", "AllocTokens", "malloc(%lu) failed\n", size);
            return false;
        }

        memcpy(temp, d_tokens, sizeof(liblexerext::Token) * a_tokens_allocated );

        free( d_tokens );

        LLG_MEM("NC", "AllocTokens", "Re-allocated [%lu] [%p]->[%p] bytes\n", size, d_tokens, temp);

        d_tokens                =   temp;
        a_tokens_allocated      =   _n;

        return true;
    }

    //  first alloc
    d_tokens    =   malloc( size );

    if ( ! d_tokens )
    {
        LLG_TKE("NC", "AllocTokens", "malloc(%lu) failed\n", size);
        return false;
    }

    a_tokens_allocated  =   _n;

    LLG_MEM("NC", "AllocTokens", "Allocated [%lu]@[%p] bytes\n", size, d_tokens);
    return true;
}

inline  Token               *   GetToken(int _ix)
{
    return  ((Token*)d_tokens) + _ix;
}

inline  Token               *   GetCurrentToken()
{
    return  GetToken(a_tokens_added);
}

inline  void                    NextToken()
{
    a_tokens_added ++;

    if  ( a_tokens_added != a_tokens_allocated )
        return;

    if ( ! AllocTokens( a_tokens_allocated + 16 ) )
    {
        ErrorMalloc();
        return;
    }
}

        void                    AddToken(int _u, int _v, int _c)
{
            Token   *   tok =   NULL;
    //  ........................................................................
    if ( Errors() )
        return;

    tok =   GetCurrentToken();

    tok->a_fcp      =   _u;
    tok->a_lcp      =   _v;
    tok->a_color    =   _c;

    NextToken();

    #ifdef  LLG_DEBUG__PARSING_DUMP_ADDED_TOKENS
    printf("%sparsing::AddToken(%5i):[%5i,%5i : %2i]%s\n", LLGC1, a_tokens_added, _u, _v, _c, LLGNA);
    #endif

    #ifdef  LLG_DEBUG__VERIFY_TOKENS_CHAINING
    if ( _u != ( a_last_token_lcp + 1 ) )
    {
        asm ( "int $3");
    }

    a_last_token_lcp = _v;
    #endif
}

        int                     GetTokensCount()
{
    return a_tokens_added;
}

        void                *   GetTokens()
{
    return d_tokens;
}
//  ============================================================================
//  LEXING
//  ============================================================================
        bool                    LexBuffer()
{
    return ( liblexerext::lexer::Lex() && ( ! Errors() ) );
}
//  ============================================================================
//  LINE FLAGS
//  ============================================================================
        void                    SetLineFlags(int _lix,int _flags)
{
    if ( Errors() )
        return;

    if ( ( _lix >= 0 ) && ( _lix < a_lines_flags_card ) )
    {
        ( (int*)a_lines_flags )[ _lix ] =   _flags;
        return;
    }

    //  case of last char of document beeing newline : no error
    if ( ( _lix == a_lines_flags_card ) && ( liblexerext::lexer::IsLexingLastChar() ) )
    {
        return;
    }

    //  error
    LLG_ERR("liblexerext", "SetLineFlags", "lix[%i] card[%i]\n", _lix, a_lines_flags_card);
    a_error_lexer   =   true;
}
//  ============================================================================
//  INTERFACE
//  ============================================================================
        void                    GetFunctionsPack(tFunctionsPack *   _fp)
{
    _fp->init                   =   &( liblexerext::Init                );

    _fp->reset                  =   &( liblexerext::Reset               );

    _fp->lex_buffer             =   &( liblexerext::LexBuffer           );

    _fp->get_tokens_count       =   &( liblexerext::GetTokensCount      );
    _fp->get_tokens             =   &( liblexerext::GetTokens           );

    _fp->keyword_set            =   &( liblexerext::KeywordSet          );
    _fp->keyword_list_set       =   &( liblexerext::KeywordListSet      );
}

}

extern "C"
{
    void    liblexerext__GetFunctionsPack(void* _p)
    {
        return liblexerext::GetFunctionsPack((liblexerext::tFunctionsPack*)_p);
    }
}







