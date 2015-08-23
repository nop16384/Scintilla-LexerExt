/*
    *****************************************************************************
    *                                                                           *
    *   liblexergas-dico-tree.cc                                                *
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

#include    <stdio.h>
#include    <stdlib.h>
#include    <string.h>

#include    "liblexerext-common.hh"
#include    "liblexerext-dico-tree.hh"
//  ............................................................................
#ifdef      LLG_DEBUG__DTREE_STORE

    #define     LLG_DTT_DBG(FORMAT, ... )                                       \
    printf("DTreeNode::store()  :[%05i]:" FORMAT, _level, __VA_ARGS__);

#else

    #define     LLG_DTT_DBG(FORMAT, ... )

#endif
//  ............................................................................
#ifdef      LLG_DEBUG__DTREE_SEARCH

    #define     LLG_DTE_DBG(FORMAT, ... )                                       \
    printf("DTreeNode::search():[%05i]:" FORMAT, _level, __VA_ARGS__);

#else

    #define     LLG_DTE_DBG(FORMAT, ... )

#endif
//  ............................................................................
namespace   liblexerext
{

//  ############################################################################
//
//                              DTREENODE
//
//  ############################################################################
DTreeNode::DTreeNode(char _chr)
    :   a_chr       (_chr   )   ,
        a_flags     (0      )
{

}
DTreeNode::DTreeNode()
    :   a_chr       (0) ,
        a_flags     (0)
{
}
DTreeNode::~DTreeNode()
{
    for ( size_t i = 0 ; i != children()->size() ; i++ )
    {
        DTreeNode   *   child   =   children()->at(i);
        delete child;
    }
}
//  ----------------------------------------------------------------------------
void
DTreeNode::dump()
{
    #ifdef  LLG_DEBUG__DTREE_DUMP
    printf("-->");
    for ( size_t i = 0 ; i != children()->size() ; i++ )
    {
        DTreeNode   *   child   =   children()->at(i);
        printf("%c", child->chr() );
    }
    printf("\n");
    #endif
}
//  ----------------------------------------------------------------------------
DTreeNode*
DTreeNode::p0_child_find(char _c)
{
    for ( size_t i = 0 ; i != children()->size() ; i++ )
    {
        DTreeNode   *   child   =   children()->at(i);
        if ( child->chr() == _c )
            return child;
    }

    return NULL;
}
void
DTreeNode::p0_child_insert(DTreeNode* _child)
{
    for ( size_t i = 0 ; i != children()->size() ; i++ )
    {
        DTreeNode   *   child   =   children()->at(i);
        if  (   static_cast < unsigned char > ( child->chr() )
                    <
                static_cast < unsigned char > ( _child->chr() ) )
            continue;

        children()->insert( children()->begin() + i, _child );
        dump();
        return;
    }


    children()->push_back( _child);
    dump();
}
//  ----------------------------------------------------------------------------
bool
DTreeNode::store(const char* _word, int _data, int _level)
{
    DTreeNode   *   child   =   NULL;
    size_t l                =   0;
    //  ........................................................................
    if ( ! _word )
        return false;

    if ( _level == 0 )
        LLG_DTT_DBG( "DTreeNode::store():[%s]\n", _word);

    l   =   strlen(_word);
    if ( ! l )  return false;

    child   =   p0_child_find( _word[0] );

    //  eventually create child
    if ( ! child )
    {
        if ( l == 1 )
        {
            //LLG_DTT_DBG( "creating leaf [%s]\n", _word);
            child   =   new DTreeLeaf( _word[0], _data );
            child->flags_set( eFlagLeaf );
        }
        else
        {
            //LLG_DTT_DBG( "creating node [%s]\n", _word);
            child   =   new DTreeNode( _word[0] );
        }
        p0_child_insert(child);
    }

    if ( l == 1 )
    {
        return true;
    }
    else
    {
        return child->store( (char const *)( _word + 1 ), _data, _level + 1 );
    }

}
bool
DTreeNode::search(const char* _word, int* _data, int _level)
{
    DTreeNode   *   child   =   NULL;
    size_t l                =   0;
    //  ........................................................................
    if ( ! _word )
        return false;

    l   =   strlen(_word);
    if ( ! l )
        return false;

    child   =   p0_child_find( _word[0] );

    //  no child : not found
    if ( ! child )
    {
        LLG_DTE_DBG( "[%s] not found\n", _word);
        return false;
    }

    //  child with search of len 1 : found
    if ( l == 1 )
    {
        //  word was stored : ok
        if ( child->flags() & eFlagLeaf )
        {
            LLG_DTE_DBG( "[%s] found\n", _word);
            *_data = ( reinterpret_cast< DTreeLeaf* >( child ) )->data();
            return true;
        }
        //  word was not stored : error
        return false;
    }

    return child->search( (char const *)( _word + 1 ), _data, _level + 1 );
}
//  ############################################################################
//
//                              DTREELEAF
//
//  ############################################################################
DTreeLeaf::DTreeLeaf(char _c, int _data)
    :   DTreeNode(_c)   ,
        a_data  (_data)
{

}
DTreeLeaf::~DTreeLeaf()
{
}



}

