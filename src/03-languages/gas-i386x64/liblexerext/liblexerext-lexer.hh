/*
    *****************************************************************************
    *                                                                           *
    *   llg-lexer.hh                                                            *
    *                                                                           *
    *   --------------------------------------------------------------------    *
    *                                                                           *
    *   part of LexerGas                                                        *
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

#ifndef     __LLG_LEXER_HH__
#define     __LLG_LEXER_HH__

#include    "liblexerext-common.hh"

//  ............................................................................
namespace   liblexerext
{
namespace   lexer
{
//  ****************************************************************************
//   Enums / typedef
//  ****************************************************************************
//  ****************************************************************************
//   Vars / Funcs
//  ****************************************************************************

extern  void                Reset(
                                void    *   _lex_buffer                 ,
                                int         _lex_length                 ,
                                int         _lex_scintilla_start_pos    ,
                                int         _first_line_index           ,
                                int         _first_line_flags           );

extern  bool                Lex();

extern  bool                IsLexingLastChar();

}
}



#endif                                                                          // #define __LLG_LEXER_HH__
