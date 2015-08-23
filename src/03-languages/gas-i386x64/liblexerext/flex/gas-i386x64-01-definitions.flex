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

