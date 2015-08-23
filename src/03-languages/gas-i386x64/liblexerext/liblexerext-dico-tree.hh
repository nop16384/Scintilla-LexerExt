/*
    *****************************************************************************
    *                                                                           *
    *   liblexergas-dico-tree.hh                                                *
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

#ifndef     __LLG_DICO_TREE_HH__
#define     __LLG_DICO_TREE_HH__
//  ............................................................................
#include    "liblexerext-common.hh"
#include    <vector>
//  ............................................................................
namespace liblexerext
{

class   DTreeNode;
class   DTreeLeaf;

class   DTreeNode
{
    protected:
        void                                dump();
    //  ------------------------------------------------------------------------
    //   chr
    //  ------------------------------------------------------------------------
    private:
            char                            a_chr;

    inline  char                            chr()               { return a_chr; }
    //  ------------------------------------------------------------------------
    //   flags
    //  ------------------------------------------------------------------------
    private:
    enum
    {
        eFlagLeaf               =   0x01
    };

    private:
            char                            a_flags;

    inline  void                            flags_set(char _f)  { a_flags = _f;     }
    inline  char                            flags()             { return a_flags;   }
    //  ------------------------------------------------------------------------
    //   children
    //  ------------------------------------------------------------------------
    private:
    std::vector < DTreeNode* >              a_children;

    private:
            std::vector < DTreeNode* >  *   children()          { return & a_children;  }
            DTreeNode                   *   p0_child_find   (char _c);
            void                            p0_child_insert (DTreeNode* _n);

    public:
            bool                            store   (const char* _word, int  _data = 0  , int _level = 0);
            bool                            search  (const char* _word, int* _data      , int _level = 0);

    inline  bool                            leaf()  { return ! a_children.empty();  }
    //  ------------------------------------------------------------------------
    //   ()~()
    //  ------------------------------------------------------------------------
    public:
    DTreeNode();
    DTreeNode(char _chr);
    ~DTreeNode();
};

class   DTreeLeaf   :   public DTreeNode
{
    //  ------------------------------------------------------------------------
    //   data
    //  ------------------------------------------------------------------------
    private:
            int                             a_data;

    public:
    inline  int                             data()  { return a_data;    }
    //  ------------------------------------------------------------------------
    //   ()~()
    //  ------------------------------------------------------------------------
    DTreeLeaf(char, int);
    ~DTreeLeaf();

};


}

#endif                                                                          //  __LLG_DICO_TREE_HH__
