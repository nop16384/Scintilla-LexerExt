/*
    *****************************************************************************
    *                                                                           *
    *   liblexerext-common.hh                                                   *
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

#ifndef     __LLEXT_COMMON_HH__
#define     __LLEXT_COMMON_HH__
//  ............................................................................
//#define     LLG_DEBUG__FLEX_LOG
//#define     LLG_DEBUG__FLEX_DBG
//#define     LLG_DEBUG__FLEX_RULE_MATCH
//#define     LLG_DEBUG__FLEX_RULE_MISMATCH
//#define     LLG_DEBUG__FLEX_YY_USER_ACTION

//#define     LLG_DEBUG__FLEX_ANNOUNCE_STATE_CHANGE
//#define     LLG_DEBUG__FLEX__DUMP_POSITIONS_AT_STATE_CHANGE
//  ............................................................................
#define     LLG_DEBUG__VERIFY_TOKENS_CHAINING
//#define     LLG_DEBUG__PARSING_DUMP_ADDED_TOKENS
//  ............................................................................
//#define     LLG_DEBUG__DTREE_STORE
//#define     LLG_DEBUG__DTREE_SEARCH
//#define     LLG_DEBUG__DTREE_DUMP
//  ............................................................................
//#define     LLG_DEBUG__MEMORY
//  ............................................................................
//  Colors
#define     LLGRV   "\033[7m"                                                   //  attribute reverse video
#define     LLGNA   "\033[0m"                                                   //  no attributes
#define     LLGC0   "\033[0;37m"                                                //  white
#define     LLGC1   "\033[0;33m"                                                //  yellow
#define     LLGC2   "\033[0;32m"                                                //  green
#define     LLGC9   "\033[0;31m"                                                //  red
//  ............................................................................
#ifdef  LLG_DEBUG__MEMORY

    #define     LLG_MEM(CLASS, METHOD, FORMAT, ... )                            \
        printf("%s[%s @ %i] %s::%s():" FORMAT "%s",                             \
        LLGC0 , __FILE__, __LINE__,                                             \
        CLASS, METHOD, __VA_ARGS__, LLGNA );
#else
    #define     LLG_MEM(CLASS, METHOD, FORMAT, ... )
#endif
//  ............................................................................
#define     LLG_ERR(CLASS, METHOD, FORMAT, ... )                                \
    printf("%sERR:[%s @ %i] %s::%s():" FORMAT "%s",                             \
    LLGC9 , __FILE__, __LINE__,                                                 \
    CLASS, METHOD, __VA_ARGS__, LLGNA );
//  ............................................................................
#define     LLG_TKE(CLASS, METHOD, FORMAT, ... )                                \
    printf("%sTKE:[%s @ %i] %s::%s():" FORMAT "%s",                             \
    LLGC9 , __FILE__, __LINE__,                                                 \
    CLASS, METHOD, __VA_ARGS__, LLGNA );
//  ............................................................................
extern  int     SCE_GAS_DEFAULT                         ;

extern  int     SCE_GAS_LABEL_GAS                       ;
extern  int     SCE_GAS_LABEL_USR                       ;

extern  int     SCE_GAS_DIRECTIVE                       ;
extern  int     SCE_GAS_DIRECTIVE_TOKEN                 ;

extern  int     SCE_GAS_INSTRUCTION_GENERIC             ;
extern  int     SCE_GAS_INSTRUCTION_PREFIX              ;
extern  int     SCE_GAS_INSTRUCTION_SUFFIX              ;
extern  int     SCE_GAS_INSTRUCTION_CPU                 ;
extern  int     SCE_GAS_INSTRUCTION_FPU                 ;
extern  int     SCE_GAS_INSTRUCTION_EXT                 ;

extern  int     SCE_GAS_OPERAND_SCALAR                  ;
extern  int     SCE_GAS_OPERAND_SCALAR_DISPLACEMENT     ;
extern  int     SCE_GAS_OPERAND_REGISTER                ;
extern  int     SCE_GAS_OPERAND_IMMEDIATE               ;
extern  int     SCE_GAS_OPERAND_SYMBOL                  ;

extern  int     SCE_GAS_STRING                          ;
extern  int     SCE_GAS_STRING_ESCAPE_SEQUENCE          ;

extern  int     SCE_GAS_COMMENT_ML                      ;
extern  int     SCE_GAS_COMMENT1                        ;
extern  int     SCE_GAS_COMMENT2                        ;
extern  int     SCE_GAS_COMMENT3                        ;

extern  int     SCE_GAS_REVERSE                         ;
extern  int     SCE_GAS_STATE_NIMPL                     ;
extern  int     SCE_GAS_ERROR_SYNTAX_UNCOLORIZED        ;
extern  int     SCE_GAS_ERROR_SYNTAX                    ;
//  ############################################################################
//
//  liblexerext
//
//  ############################################################################
namespace liblexerext
{

extern          void                    AddToken(int,int,int);
extern          void                    SetLineFlags(int,int);

extern          int                     IsInstruction                   (const char*, int* _data);
extern          bool                    IsDirective                     (const char*);

}

#endif                                                                          // __LLEXT_COMMON_HH__




