/*
    *****************************************************************************
    *                                                                           *
    *   llg-lexer.cc                                                            *
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

#include    <stdlib.h>

#include    "liblexerext-lexer.hh"
#include    "liblexerext-flex.hh"                                               //  for yy_size_t, yy_buffer_state, yy_scan_buffer()

//  ............................................................................
extern  void    FlexReset(int _start_pos, int _first_line, int _first_line_flags);
extern  int     sMcp();
//  ............................................................................
namespace   liblexerext
{
namespace   lexer
{
//  ****************************************************************************
//   Vars / Funcs
//  ****************************************************************************
static  void        *   a_lex_buffer                        =   0;
static  int             a_lex_length                        =   0;
static  int             a_lex_scintilla_start_pos           =   0;
static  int             a_lex_scintilla_end_pos             =   0;
static  int             a_lex_scintilla_first_line_index    =   0;
static  int             a_lex_scintilla_first_line_flags    =   0;
//  ============================================================================
        void            Reset(
                            void    *   _lex_buffer                     ,
                            int         _lex_length                     ,
                            int         _lex_scintilla_start_pos        ,
                            int         _lex_scintilla_first_line_index ,
                            int         _lex_scintilla_first_line_flags )
{
    a_lex_buffer                        =   _lex_buffer;
    a_lex_length                        =   _lex_length;
    a_lex_scintilla_start_pos           =   _lex_scintilla_start_pos;
    a_lex_scintilla_end_pos             =   _lex_scintilla_start_pos + ( _lex_length - 2 ) - 1;
    a_lex_scintilla_first_line_index    =   _lex_scintilla_first_line_index;
    a_lex_scintilla_first_line_flags    =   _lex_scintilla_first_line_flags;
}
//  ============================================================================
        bool            Lex()
{
    char            *   buf     =   NULL;
    yy_size_t           bfs     =   0;
    yy_buffer_state *   ybs     =   NULL;
    //  ........................................................................
    //  prepare the buffer
    buf                     =   (char*)a_lex_buffer;
    buf[ a_lex_length - 1 ] =   0;                                              //  YY_END_OF_BUFFER_CHAR;
    buf[ a_lex_length - 2 ] =   0;                                              //  YY_END_OF_BUFFER_CHAR;
    bfs                     =   (yy_size_t)a_lex_length;

    //  lex the buffer
    FlexReset(
        a_lex_scintilla_start_pos           ,
        a_lex_scintilla_first_line_index    ,
        a_lex_scintilla_first_line_flags    );

    ybs =   yy_scan_buffer(buf, bfs);

    int t = yylex();

    yy_delete_buffer( ybs );                                                    //  very important, flex get confused else

    return  ( t == 0 );
}
//  ============================================================================
        bool            IsLexingLastChar()
{
    return  ( sMcp() == a_lex_scintilla_end_pos );
}

}
}






