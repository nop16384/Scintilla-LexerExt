//  ############################################################################
//  § LexExt-00-header.cci
//  ############################################################################
// Scintilla source code edit control
/** @file LexExt.cxx
 ** Lexer for x86 Assembler, just for the GNU as syntax, by gwr
 ** Inspired / Copied & Pasted from :
 **     LexAsm.cxx by The Black Horus & Kein-Hong Man & "Udo Lechner" <dlchnr(at)gmx(dot)net>
 **     LexCPP.cxx by Neil Hodgson <neilh@scintilla.org>
 **
 **     v.fb-001
 **/
// Copyright 1998-2003 by Neil Hodgson <neilh@scintilla.org>
// The License.txt file describes the conditions under which this software may be distributed.

#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <assert.h>
#include <ctype.h>
#include <dlfcn.h>

#include <string>
#include <map>
#include <set>

#include "ILexer.h"
#include "Scintilla.h"
#include "SciLexer.h"

#include "WordList.h"
#include "LexAccessor.h"
#include "StyleContext.h"
#include "CharacterSet.h"
#include "LexerModule.h"
#include "OptionSet.h"

#include    "Platform.h"

#include <list>
#include <vector>
#include <stack>
#include <queue>

#ifdef SCI_NAMESPACE
using namespace Scintilla;
#endif
//  ############################################################################
//  § LexExt-01-pre.cci
//  ############################################################################

//#define     LXG_UCHAR(X)    (static_cast< unsigned char >( X ))
//#define     LXG_TID8(TID)   (static_cast< LexerExt::eTokenId8 >( TID ))
#define     LXG_SIZE_T_MAX  (static_cast< size_t >(-1))
//  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define     LXG_MEMBER_AUTO( TYPE, NAME, METHODNAME )                           \
    private:                                                                    \
    TYPE        a_##NAME;                                                       \
    public:                                                                     \
    TYPE        METHODNAME()                                                    \
                {                                                               \
                    return a_##NAME;                                            \
                }                                                               \
    void        METHODNAME##_set(TYPE _T)                                       \
                {                                                               \
                    a_##NAME = _T;                                              \
                }
//  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Colors
#define     LXGRV   "\033[7m"                                                   //  attribute reverse video
#define     LXGNA   "\033[0m"                                                   //  no attributes
#define     LXGC0   "\033[0;37m"                                                //  white
#define     LXGC1   "\033[0;33m"                                                //  yellow
#define     LXGC2   "\033[0;32m"                                                //  green
#define     LXGC9   "\033[0;31m"                                                //  red
//  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Errors
#define     LXG_ERR(FORMAT, ...)        printf(LXGC9 FORMAT LXGC0, __VA_ARGS__)
#define     LXG_INTERRUPT                                                       \
            {                                                                   \
                LXG_ERR("EXPLICIT INTERRUPT 'int $3' [%s][%u]\n",               \
                __FILE__, __LINE__ );                                           \
                __asm__ ( "int $3" );                                           \
            }
#define     LXG_INTERRUPT_MSG(FORMAT, ...)                                      \
            {                                                                   \
                LXG_ERR(FORMAT, __VA_ARGS__);                                   \
                LXG_ERR("EXPLICIT INTERRUPT 'int $3' [%s][%u]\n",               \
                __FILE__, __LINE__ );                                           \
                __asm__ ( "int $3" );                                           \
            }
//  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  All these macros for avoiding unused-but-set warnings because my debugs
//  use specific variables
//  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Generic debug
#define     LXG_DEBUG_LEXING
//#define     LXG_DEBUG_FOLDING
#define     LXG_DEBUG_LLG
//  ............................................................................
//  LEXING
#ifdef      LXG_DEBUG_LEXING
    #define     LXGLDB(FORMAT, ...)     printf(FORMAT, __VA_ARGS__)
    #define     LXGLDC(CODE)            CODE
#else
    #define     LXGLDB(FORMAT, ...)
    #define     LXGLDC(CODE)
#endif
//  ............................................................................
//  FOLDING
#ifdef      LXG_DEBUG_FOLDING
    #define     LXGFDB(FORMAT, ...)     printf(FORMAT, __VA_ARGS__)
    #define     LXGFDC(CODE)            CODE
#else
    #define     LXGFDB(FORMAT, ...)
    #define     LXGFDC(CODE)
#endif
//  ............................................................................
//  LIBLEXEREXT
#ifdef      LXG_DEBUG_LLG
    #define     LXG_LLG_DBG(FORMAT, ...)     printf("LexerExt::liblexerext::" FORMAT, __VA_ARGS__)
    #define     LXG_LLG_DBC(CODE)            CODE
#else
    #define     LXG_LLG_DBG(FORMAT, ...)
    #define     LXG_LLG_DBC(CODE)
#endif
//  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  For cross-referencing, declare all classes
class   LexerExt;
class   LexerGas_i386;
class   LexerGas_arm;
class   DynamicLibraryImpl;
//  ############################################################################
//  § LexExt-02-options.cci
//  ############################################################################
static const char * const extWordListDesc[] =
{
	"instruction prefix"        ,
	"instruction suffix"        ,
	"CPU instruction"           ,
	"FPU instructions"          ,
	"Extended instructions"     ,
	"--- free ---"              ,
	"--- free ---"              ,
	"Registers"                 ,
	"Directives"                ,
    0
};

class   OptionsExt
{
    public:
    std::string language;
    bool        fold_extra;
    std::string fold_extra_start;
    std::string fold_extra_end;

    std::string comment1_mark;
    std::string comment2_mark;
    std::string comment3_mark;

	OptionsExt(
        std::string     _language           ,
        bool            _fold_extra         ,
        std::string     _fold_extra_start   ,
        std::string     _fold_extra_end     ,
        std::string     _comment1_mark      ,
        std::string     _comment2_mark      ,
        std::string     _comment3_mark      )
        :   language        ( _language         )   ,
            fold_extra      ( _fold_extra       )   ,
            fold_extra_start( _fold_extra_start )   ,
            fold_extra_end  ( _fold_extra_end   )   ,
            comment1_mark   ( _comment1_mark    )   ,
            comment2_mark   ( _comment2_mark    )   ,
            comment3_mark   ( _comment3_mark    )
    {
	}
};

struct OptionSetExt : public OptionSet<OptionsExt>
{
	OptionSetExt()
    {
		DefineProperty("lexer.ext.language", &OptionsExt::language,
			"This option specify the language to use");

		DefineProperty("fold.ext.extra", &OptionsExt::fold_extra,
			"This option enables extra folding when using the ext lexer. "
			"Extra folding is done by inserting special strings in the code.");

		DefineProperty("fold.ext.extra.start", &OptionsExt::fold_extra_start,
			"The string to use for explicit fold start points, replacing the standard.");

		DefineProperty("fold.ext.extra.end", &OptionsExt::fold_extra_end,
			"The string to use for explicit fold end points, replacing the standard.");
        //  ....................................................................
		DefineProperty("fold.ext.comment.mark.1", &OptionsExt::comment1_mark,
			"The string to use for starting a block comment.");

		DefineProperty("fold.ext.comment.mark.2", &OptionsExt::comment2_mark,
			"Alternate string to use for starting a block comment.");

		DefineProperty("fold.ext.comment.mark.3", &OptionsExt::comment3_mark,
			"Alternate string to use for starting a block comment.");
        //  ....................................................................
		DefineWordListSets(extWordListDesc);
	}
};

//  ############################################################################
//  § LexExt-03-utils.cci
//  ############################################################################

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


//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
//
//  LexExt-04.0001.001-class-LexerGas-in--open.cci
//
//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
class   LexerExt : public ILexer
{
//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
//
//  LexExt-04.0001.010-spacer.cci
//
//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
    public:
    //! \class      Spacer
    //! \brief      For debug indentations
    class Spacer
    {
        private:
        std::string     a_spaces;

        public:
        const   char    *   cstr()  { return a_spaces.c_str();  }

        void                inc()   { a_spaces.append("  ");    }
        void                dec()
            {
                if ( ! a_spaces.length() )
                {
                    LXG_INTERRUPT_MSG("%s\n", "Spacer::dec():spaces std::string is empty");
                }
                a_spaces.erase( 0, 2);
            }

        public:
        Spacer()
        {
        }
        ~Spacer()
        {
        }
    };
    //  ########################################################################
    //! \class  Chrono
    //! \brief  For measuring time
    class Chrono
    {

    //  int clock_gettime(clockid_t clk_id, struct timespect *tp);

    private:
        timespec    a_t_start;
        timespec    a_t_timed;
        timespec    a_t_diff;

        bool        a_started;
        bool        a_timed;

    private:
    //  Guy rutenberg
    void    p_diff()
    {
        if ( ( a_t_timed.tv_nsec - a_t_start.tv_nsec ) < 0 )
        {
            a_t_diff.tv_sec     = a_t_timed.tv_sec  -   a_t_start.tv_sec    -   1;
            a_t_diff.tv_nsec    = 1000000000        +   a_t_timed.tv_nsec   -   a_t_start.tv_nsec;
        }
        else
        {
            a_t_diff.tv_sec     = a_t_timed.tv_sec  -   a_t_start.tv_sec;
            a_t_diff.tv_nsec    = a_t_timed.tv_nsec -   a_t_start.tv_nsec;
        }
    }


    bool    p_get_time( timespec* _tspc)
        {
            if ( clock_gettime( CLOCK_MONOTONIC_RAW, _tspc ) != 0 )
            {
                LXG_ERR( "%s [%s]\n", "Chrono::p_get_time():clock_gettime failed", strerror(errno));
                return false;
            }
            return true;
        }
    public:
    void    start()
        {
            a_started   =   false;
            a_timed     =   false;

            if ( p_get_time(&a_t_start) )
            {
                a_started   =   true;
            }
        }
    void    time()
        {
            if ( ! a_started )
                return;

            if ( ! p_get_time(&a_t_timed) )
            {
                return;
            }
            a_timed =   true;

            p_diff();
        }

    time_t  es()
    {
        if ( a_timed )
            return a_t_diff.tv_sec;

        return 0;
    }
    long    ens()
    {
        if ( a_timed )
            return a_t_diff.tv_nsec;

        return 0;
    }

    public:
        Chrono()
        {
        }
        virtual ~Chrono()   {}
    };
    //  ########################################################################



//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
//
//  LexExt-04.0001.010-word-list-pack.cci
//
//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
    //! \class      WordListPack
    //! \brief      Pack all lists of keywords allowed by scintilla into one object.
    private:
    class   WordListPack
    {
        public:
        static  const   int                     s_card_max  =   16;
        private:
                        WordList        *       a_word_lists    [WordListPack::s_card_max];
        //  --------------------------------------------------------------------
        public:
        WordList        *       wl(int _n)
            {
                if ( _n <  0                        )   return NULL;
                if ( _n >= WordListPack::s_card_max )   return NULL;

                return a_word_lists[_n];
            }

        void                    wl_set(int _n, WordList* _wl)
            {
                if ( _n <  0                        )   return;
                if ( _n >= WordListPack::s_card_max )   return;

                a_word_lists[_n] = _wl;
            }
        //  --------------------------------------------------------------------
        public:
        WordListPack()
        {
            memset(
                (void*)a_word_lists                             ,
                0                                               ,
                WordListPack::s_card_max * sizeof(WordList*)    );
        }
        virtual ~WordListPack()                                                 {}
    };
//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
//
//  LexExt-04.0001.030-liblexerext.cci
//
//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
    public:
    //! \class      LibLexerExt
    //! \brief      Load and run the external lexer contained in shared library
    class LibLexerExt
    {
        //  --------------------------------------------------------------------
        //  lexer results
        //  --------------------------------------------------------------------
        template < typename S >   class   StructsArray
        {
            private:
            int                 a_card;
            void            *   a_mem;

            int                 a_index_current;
            S               *   a_struct_current;
            S               *   a_struct_last;

            public:
            int         card()  { return    a_card;             }

            public:
            bool        in()    { return a_struct_current <= a_struct_last;     }
            void        next()  { a_struct_current++; a_index_current++;        }
            int         ix()    { return a_index_current;                       }
            S       *   get()   { return a_struct_current;                      }

            public:
            StructsArray( int _card, void* _mem)
                :   a_card          (_card  )   ,
                    a_mem           (_mem   )   ,
                    a_index_current (0      )
                {
                    a_struct_current    =   static_cast < S* > ( a_mem );
                    a_struct_last       =   a_struct_current + ( a_card - 1 );
                }
            ~StructsArray()                                                     {}
        };
        //  --------------------------------------------------------------------
        public:
        struct _Token
        {
            int     a_fcp;
            int     a_lcp;
            int     a_color;
        };
        //  --------------------------------------------------------------------
        public:
        struct _LineFlags
        {
            int     a_flags;
        };
        //  --------------------------------------------------------------------
        //  ( simple ) memory allocations
        //  --------------------------------------------------------------------
        private:
        class   MAllocator
        {
            private:
            int                 a_size;
            void            *   d_mem;

            public:
            int                 size()  { return a_size;    }
            void            *   mem()   { return d_mem;     }

            public:
            bool    realloc( int _bytes)
                {
                    if ( ! d_mem )
                        return false;

                    if ( a_size >= _bytes )
                        return true;

                    if ( ! dealloc() )
                        return false;

                    return alloc(_bytes);
                }
            bool    alloc(int _bytes)
                {
                    if ( d_mem )
                        return realloc(_bytes);

                    d_mem           =   malloc(_bytes);
                    if ( ! d_mem )
                        return false;

                    a_size          =   _bytes;
                    return true;
                }
            bool    dealloc()
                {
                    if ( ! d_mem )
                        return false;

                    free( d_mem );
                    d_mem           =   NULL;
                    a_size          =   0;

                    return true;
                }

            void    mset(char _c, int _count)
                {
                    if ( ! d_mem )
                        return;

                    if ( a_size < _count )
                        return;

                    memset(d_mem, (int)_c, _count);
                }

            public:
            MAllocator()
                :   a_size  (0          )   ,
                    d_mem   (NULL       )
            {
            }
            ~MAllocator()
            {
                if ( d_mem )
                    dealloc();
            }
        };
        //  --------------------------------------------------------------------
        private:
        MAllocator          a_ma_colourization;
        MAllocator          a_ma_line_flags;

        private:
        MAllocator      *   mac()   { return &a_ma_colourization;   }
        MAllocator      *   maf()   { return &a_ma_line_flags;      }
        //  --------------------------------------------------------------------
        private:
        bool    p0_alloc()
            {
                int needed  =   0;
                //  ............................................................
                //  * alloc 2 supplementary bytes for flex's finals 2 chr(0)
                //  * for avoiding too much reallocs, alloc more bytes.
                needed  =   flx_len() * 2;
                //D LXG_LLG_DBG("mac alloc(%i -> %i)\n", flx_len(), needed);

                if ( ! mac()->alloc(needed) )
                    return false;
                //  ............................................................
                //  * for avoiding too much reallocs, alloc more bytes.
                needed  =   scl_lf_lines_card() * sizeof(int) * 2;
                //D LXG_LLG_DBG("maf alloc(%i -> %i)\n", scl_lf_lines_card(), needed);

                if ( ! maf()->alloc(needed) )
                    return false;

                return true;
            }
        //  --------------------------------------------------------------------
        //  loading
        //  --------------------------------------------------------------------
        class   SharedLibrary
        {
            private:
            std::string             a_name;
            DynamicLibrary      *   d_scintilla_lib;                            //  multiplatform dynamic library
            void                *   a_hlib_get_functions_pack;                  //  extern "C" ( no mangling ) function

            public:
            std::string         &   name()
                {
                    return a_name;
                }
            void                    get_fpack(liblexerext::tFunctionsPack* _fpack)
                {
                    ((liblexerext::FnGetFunctionsPack)a_hlib_get_functions_pack)((void*)_fpack);
                }

            public:
            SharedLibrary(  const char      *   _language                   ,
                            DynamicLibrary  *   _hlib                       ,
                            void            *   _hlib_get_functions_pack)
                :   a_name                      ( _language   )   ,
                    d_scintilla_lib             ( _hlib       )   ,
                    a_hlib_get_functions_pack   ( _hlib_get_functions_pack )
                {
                }
            ~SharedLibrary(){}
        };
        //  --------------------------------------------------------------------
        static  std::list < SharedLibrary* >    s_shared_libraries;

        static  SharedLibrary   *   SharedLibrary_load  (const char* _language_name)
            {
                //  example : lib-scintilla-lexer-ext__gas_i386x64.so
                //  ............................................................
                DynamicLibrary      *   dl                      =   NULL;
                SharedLibrary       *   so                      =   NULL;
                Function                hlib_get_functions_pack =   NULL;
                std::string             path("/usr/lib/codeblocks/lexers/");
                //  ............................................................
                path.append("lib-scintilla-lexer-");
                path.append(_language_name);

                LXG_LLG_DBG("SharedLibrary_load():[%s]\n", path.c_str());
                //  ............................................................
                dl      =   DynamicLibrary::Load( path.c_str() );

                if ( ! dl )
                {
                    LXG_ERR("%s\n", "SharedLibrary_load():library not loaded ! (NULL )");
                    return NULL;
                }
                if ( ! dl->IsValid() )
                {
                    LXG_ERR("%s\n", "SharedLibrary_load():library not loaded ! (INVALID)");
                    return NULL;
                }
                //  ............................................................
                //  get main function
                hlib_get_functions_pack = dl->FindFunction("liblexerext__GetFunctionsPack");
                if ( ! hlib_get_functions_pack )
                {
                    LXG_ERR("SharedLibrary_load():dlsym failed [%s]:[%s]\n", "load functions pack", dlerror());
                    return NULL;
                }
                //  ............................................................
                //  create & return SharedLibrary object
                //so = new SharedLibrary( _language_name, hlib, hlib_get_functions_pack );
                so = new SharedLibrary( _language_name, dl, hlib_get_functions_pack );
                return so;
            }

        static  SharedLibrary   *   SharedLibrary_get   (const char* _language_name)
            {
                std::list < SharedLibrary* >::iterator      it ;
                SharedLibrary                           *   so  =   NULL;
                //  ............................................................
                for (
                        it  =   s_shared_libraries.begin()  ;
                        it  !=  s_shared_libraries.end()    ;
                        ++it                                )
                {
                    so  =   *it;

                    if ( ! so->name().compare(_language_name) )
                    {
                        LXG_LLG_DBG("SharedLibrary_get():[%s] already loaded\n", _language_name);
                        return so;
                    }
                }

                so = SharedLibrary_load(_language_name);

                if ( ! so )
                    return NULL;

                s_shared_libraries.push_back(so);

                return so;
            }
        //  --------------------------------------------------------------------
        private:
        liblexerext::tFunctionsPack     a_functions_pack;
        bool                            a_is_loaded;
        bool                            a_is_valid;

        private:
        liblexerext::tFunctionsPack *   fpack()     { return & a_functions_pack;    }

        public:
        bool                            loaded()    { return a_is_loaded;           }
        bool                            valid()     { return a_is_valid;            }

        public:
        void                            load(const char* _language_name, WordListPack* _wlp)
            {
                SharedLibrary   *   so  =   NULL;
                WordList        *   wl  =   NULL;
                //  ................................................................
                if ( loaded() )
                    return;

                a_is_loaded =   true;

                if ( ! _language_name )
                {
                    LXG_ERR("%s\n", "LibLexerExt::load():NULL _language_name\n");
                    return;
                }

                so = SharedLibrary_get(_language_name);

                if ( ! so )
                {
                    LXG_ERR("LibLexerExt::load():[%s] load failed\n", _language_name);
                    return;
                }

                so->get_fpack( &a_functions_pack );                             //  get all library functions

                fpack()->init();                                                //  library initialization

                for ( int i = 0 ; i != WordListPack::s_card_max; i++ )          //  set all keywords
                {
                    wl = _wlp->wl(i);

                    if ( ! wl )
                        continue;

                    for ( int j = 0 ; j != wl->Length() ; j++ )
                    {
                        fpack()->keyword_list_set( i, wl->WordAt(i) );
                    }
                }

                a_is_valid  =   true;
            }
        //  --------------------------------------------------------------------
        //  setup
        //  --------------------------------------------------------------------
        private:
        LexAccessor     *   a_la;
        StyleContext    *   a_sc;

        int                 a_sc_lex_len;

        int                 a_sc_lex_pos_start;
        int                 a_sc_lex_pos_end;
        int                 a_sc_doc_pos_end;

        int                 a_sc_lex_line_start;
        int                 a_sc_lex_line_end;
        int                 a_sc_lex_lines_card;
        int                 a_sc_lex_lines_flags__line_start;
        int                 a_sc_lex_lines_flags__line_end;
        int                 a_sc_lex_lines_flags__lines_card;

        private:
        int                 scl_len()                   { return a_sc_lex_len;                              }
        int                 scl_lines_card()            { return a_sc_lex_lines_card;                       }
        int                 scl_lf_lines_card()         { return a_sc_lex_lines_flags__lines_card;          }
        int                 flx_len()                   { return a_sc_lex_len + 2;                          }


        private:
        LexAccessor     *   la()                { return a_la;          }
        StyleContext    *   sc()                { return a_sc;          }

        public:
        void    lex_setup(
                    LexAccessor     *   _la         ,
                    StyleContext    *   _sc         ,
                    int                 _start_pos  ,
                    int                 _length     )
            {
                LXG_LLG_DBG("setup():[%05i] chars to lex\n", _length);

                a_la    =   _la;
                a_sc    =   _sc;

                a_sc_lex_len        =   _length;

                a_sc_lex_pos_start  =   _start_pos;
                a_sc_lex_pos_end    =   a_sc_lex_pos_start + a_sc_lex_len - 1;
                a_sc_doc_pos_end    =   la()->Length() - 1;

                a_sc_lex_line_start =   la()->GetLine(a_sc_lex_pos_start);
                a_sc_lex_line_end   =   la()->GetLine(a_sc_lex_pos_end);
                a_sc_lex_lines_card =   a_sc_lex_line_end - a_sc_lex_line_start + 1;

                a_sc_lex_lines_flags__line_start    =   a_sc_lex_line_start;
                a_sc_lex_lines_flags__line_end      =                           //  cf remark 4 in LexerExt::Lex()
                    ( a_sc_doc_pos_end > a_sc_lex_pos_end ) ?
                    a_sc_lex_line_end + 1                   :
                    a_sc_lex_line_end                       ;
                a_sc_lex_lines_flags__lines_card    =
                    a_sc_lex_lines_flags__line_end      -
                    a_sc_lex_lines_flags__line_start    +   1;
            }
        //  --------------------------------------------------------------------
        //  flex imports ( before lexing )
        //  --------------------------------------------------------------------
        private:
        void    p0_import_from_scintilla__text()
            {
                char    *   p   =   NULL;
                int         s   =   0;
                //  ............................................................
                if ( ! mac()->mem() )
                    LXG_INTERRUPT;

                p   =   static_cast < char * > ( mac()->mem() );

                //  If lexed text contain the last character of the document :  _GWR_REM_
                //    - scintilla will append EOF char ( the last _sc.More()
                //      above will return EOF )
                //    - else no EOF will be appended
                while ( sc()->More() )
                {
                    //D LXG_LLG_DBG("[%03i] [%02x]\n", s, _sc.ch);
                    s++;
                    *(p++)  =   sc()->ch;
                    sc()->Forward();
                }

                //  add 2 chr(0) for flex
                *(p++)  =   0;                                                  //  1st chr(0) for flex
                *(p)    =   0;                                                  //  2nd chr(0) for flex pb pb

                LXG_LLG_DBG("LibLexerExt::p0_import_from_scintilla__text():[%03i] bytes copied\n", s);
            }

        void    p0_import_from_scintilla__lines_flags()
            {
                int     *   blob    =   NULL;
                int         i       =   0;
                //  ............................................................
                blob    =   (int*)( maf()->mem() );

                for (   i   =   a_sc_lex_lines_flags__line_start    ;
                        i   <=  a_sc_lex_lines_flags__line_end      ;
                        i++                                         )
                {
                    *( blob++ ) = get_clf(i);
                }
                //LXG_LLG_DBG("LibLexerExt::p0_import_from_scintilla__lines_flags():[%05i][%08x]\n", i,  get_clf(i));
            }
        //  --------------------------------------------------------------------
        //  lexing
        //  --------------------------------------------------------------------
        private:
        bool    p0_lex()
            {
                fpack()->reset(
                            mac()->mem()            ,
                            flx_len()               ,
                            a_sc_lex_pos_start      ,
                            a_sc_lex_line_start     ,
                            maf()->mem()            ,
                            scl_lf_lines_card()     );

                return fpack()->lex_buffer();
            }
        //  --------------------------------------------------------------------
        //  colourization
        //  --------------------------------------------------------------------
        public:
        void    colourize()
            {
                StructsArray < struct _Token > tks(
                    fpack()->get_tokens_count()     ,
                    fpack()->get_tokens()           );

                LXG_LLG_DBG("LibLexerExt::colourize():[%05i] tokens\n", tks.card());

                while ( tks.in() )
                {
                    la()->ColourTo(
                            tks.get()->a_lcp    ,
                            tks.get()->a_color  );

                    tks.next();
                }
            }
        void    colourize_on_failure()
            {
                la()->ColourTo( a_sc_lex_pos_end, 28 );
            }
        //  --------------------------------------------------------------------
        //  line flags
        //  --------------------------------------------------------------------
        private:
        int                 get_clf(int _lpos)
            {
                int _flags  =   la()->LevelAt( _lpos );

                _flags  = _flags & 0xffff0000;
                _flags  = _flags >> 16;

                //D LXG_LLG_DBG("get_clf():[%05i] [%08x]\n", _lpos, _flags);

                return _flags;
            }
        void                set_clf(int _lpos, int _flags)
            {
                int level   = la()->LevelAt( _lpos );

                //D LXG_LLG_DBG("set_clf():[%05i] [%08x]\n", _lpos, _flags);

                _flags  = _flags & 0x0000ffff;
                _flags  = _flags << 16;

                level   = level & 0x0000ffff;
                level   = level | _flags;

                la()->SetLevel( _lpos, level );
            }
        public:
        void    set_lines_flags()
            {
                StructsArray < struct _LineFlags > tks(
                    scl_lf_lines_card()     ,
                    maf()->mem()            );

                while ( tks.in() )
                {
                    set_clf(
                        tks.ix()            ,
                        tks.get()->a_flags  );

                    tks.next();
                }
            }
        //  --------------------------------------------------------------------
        //  main call from LexerExt
        //  --------------------------------------------------------------------
        public:
        bool    lex_run()
            {
                if ( ! p0_alloc() )
                    return false;

                p0_import_from_scintilla__text();
                p0_import_from_scintilla__lines_flags();

                return p0_lex();
            }
        //  --------------------------------------------------------------------
        //  ()~()
        //  --------------------------------------------------------------------
        public:
        LibLexerExt()
            :   a_is_loaded (false) ,
                a_is_valid  (false)
            {
            }
        ~LibLexerExt()
            {
            }
    };




//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
//
//  LexExt-04.0001.050-ocode.cci
//
//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
    private:
	OptionsExt      options;
	OptionSetExt    osExt;

    WordList        instructionsPrefix;
    WordList        instructionsSuffix;
    WordList        instructionsCPU;
    WordList        instructionsFPU;
    WordList        instructionsEXT;
    WordList        registers;
    WordList        directives;
    //  ------------------------------------------------------------------------
    public:

	void            SCI_METHOD  Release()                           {   delete this;                    }

	int             SCI_METHOD  Version() const                     {   return lvOriginal;              }

	const char *    SCI_METHOD  PropertyNames    ()                 {   return osExt.PropertyNames();   }
	int             SCI_METHOD  PropertyType     (const char *name) {   return osExt.PropertyType(name);        }
	const char *    SCI_METHOD  DescribeProperty (const char *name) {   return osExt.DescribeProperty(name);    }
	int             SCI_METHOD  PropertySet      (const char *key, const char *val);

	const char *    SCI_METHOD  DescribeWordListSets()              {   return osExt.DescribeWordListSets();    }
	int             SCI_METHOD  WordListSet(int n, const char *wl);

	void            SCI_METHOD  Lex  (unsigned int startPos, int length, int initStyle, IDocument *pAccess);
	void            SCI_METHOD  Fold (unsigned int startPos, int length, int initStyle, IDocument *pAccess);

	void *          SCI_METHOD  PrivateCall(int, void *)            {   return 0;   }
    //  ------------------------------------------------------------------------
	static  ILexer  *           LexerFactory_ext__gas_i386x64();                //  for scite
	static  ILexer  *           LexerFactory_ext__gas_arm_generic();            //  for scite
	static  ILexer  *           LexerFactoryExt();                              //  for codeblocks
    //  ------------------------------------------------------------------------
    protected:
                                LexerExt(const char*);                          //  for scite
                                LexerExt();                                     //  for codeblocks
	virtual                     ~LexerExt();
//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
//
//  LexExt-04.0001.060-decl-cst.cci
//
//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
    //  ------------------------------------------------------------------------
    //  classes declarations
    //  ------------------------------------------------------------------------
    //  ------------------------------------------------------------------------
    //  classes id
    //  ------------------------------------------------------------------------
    protected:
    typedef int eLexExtTarget;
    enum
    {
        eLexExtTarget_i386  =   1,
        eLexExtTarget_arm   =   2
    };
    //  ------------------------------------------------------------------------
    //  Methods
    //  ------------------------------------------------------------------------
    protected:
    LexAccessor         *   a_lex_accessor;

    public:
    LexAccessor         *   la()            { return a_lex_accessor;    }
    //  ------------------------------------------------------------------------
    protected:
    WordListPack            a_word_list_pack;

    protected:
    WordListPack        *   wlp()           { return &a_word_list_pack; }

    void                    wlp_set()
        {
            wlp()->wl_set( liblexerext::eWordListInstructionsPrefix  , &instructionsPrefix  );
            wlp()->wl_set( liblexerext::eWordListInstructionsSuffix  , &instructionsSuffix  );
            wlp()->wl_set( liblexerext::eWordListInstructionsCPU     , &instructionsCPU     );
            wlp()->wl_set( liblexerext::eWordListInstructionsFPU     , &instructionsFPU     );
            wlp()->wl_set( liblexerext::eWordListInstructionsEXT     , &instructionsEXT     );
            wlp()->wl_set( liblexerext::eWordListRegisters           , &registers           );
            wlp()->wl_set( liblexerext::eWordListDirectives          , &directives          );
        }
    //  ------------------------------------------------------------------------
    protected:
    LibLexerExt         *   d_liblexerext;

    protected:
    LibLexerExt         *   liblexerext()   { return d_liblexerext;     }

    //  ------------------------------------------------------------------------
    protected:
    void                    set_fold_level(int _line, int _level)
        {
            int level   =   la()->LevelAt( _line );

            level       =   level & ( ~SC_FOLDLEVELNUMBERMASK );
            level       =   level | _level;
            la()->SetLevel( _line, level );
        }
    int                     get_fold_level(int _line)
        {
            return  ( la()->LevelAt( _line ) & SC_FOLDLEVELNUMBERMASK );
        }


//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
//
//  LexExt-04.0001.090-dl-loader.cci
//
//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
    public:
    //! \class      DlLoader
    //! \brief      Load the assembly-specific parser dynamic library
    class DlLoader
    {

    };
//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
//
//  LexExt-04.0001.001-class-LexerGas-in--close.cci
//
//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
};
//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
//
//  LexExt-04.0005.010-CLG-out-cdtor.cci
//
//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
LexerExt::LexerExt(const char* _language_name)
:   options( "undefined", 1, "#>>", "#<<", "#", "##", "###" )
{
    wlp_set();

    d_liblexerext   =   new LexerExt::LibLexerExt();

    if ( _language_name )
        liblexerext()->load( _language_name, wlp() );
    else
        LXG_ERR( "%s\n", "LexerExt::LexerExt()::NULL _language_name - no lexing will be available");
}
LexerExt::LexerExt()
:   options( "undefined", 1, "#>>", "#<<", "#", "##", "###" )
{
    wlp_set();

    d_liblexerext   =   new LexerExt::LibLexerExt();
}
LexerExt::~LexerExt()
{
}

//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
//
//  LexExt-04.0005.020-CLG-out-set.cci
//
//  §§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§
int SCI_METHOD LexerExt::PropertySet(const char *key, const char *val)
{
    //LXGLDB( "LexerExt::PropertySet():[%s][%s]\n", key, val);
    //LXGLDB( "PropertySet:[%p]\n", &options);

	if (osExt.PropertySet(&options, key, val))
    {
		return 0;
	}
	return -1;
}

int SCI_METHOD LexerExt::WordListSet(int n, const char *wl)
{
	WordList    *   wordListN   =   NULL;
    //  ........................................................................
    //printf("LexerExt::WordListSet():[%3i] [%s]\n",n,wl);

	switch (n)
    {
	case 0  :   wordListN   = &instructionsPrefix;                      break;
	case 1  :   wordListN   = &instructionsSuffix;		                break;
	case 2  :   wordListN   = &instructionsCPU;		                    break;
	case 3  :	wordListN   = &instructionsFPU;		                    break;
	case 4  :	wordListN   = &instructionsEXT;		                    break;
	case 7  :	wordListN   = &registers;		                        break;
	case 8  :   wordListN   = &directives;                              break;
	}

	int firstModification = -1;
	if ( ! wordListN )
        return firstModification;

    WordList wlNew;
    wlNew.Set(wl);

    if (*wordListN != wlNew)
    {
        wordListN->Set(wl);
        firstModification = 0;
    }

	return firstModification;
}

//  ############################################################################
//  § LexExt-05.03-lex.cci
//  ############################################################################
//  ............................................................................
void SCI_METHOD LexerExt::Lex(
    unsigned    int             _startPos   ,
                int             _length     ,                                   //  chars to lex
                int             _initStyle  ,
                IDocument   *   _pAccess    )
{
    //  ........................................................................
    //  a few general remarks :
    //  ........................................................................
    //  0)  scintilla & lua & properties etc...
    //    - LexerModule :
    //      LexerModule lmToto(SCLEX_XXX, ILexer::LexerFactoryTata , "name" , totoWordListDesc);
    //      - SCLEX_XXX                 : ?
    //      - ILexer::LexerFactoryTata  : see below
    //      - "name"                    : add an available lexer named "name"
    //        in the catalog.
    //
    //    - Mechanism of lexer selection :
    //      - file's extension -> "lexer.(pattern)=name"
    //      - "name" -> catalog -> Factory
    //      - "name" -> "name.properties" -> properties
    //         with properties associated to file patterns, not to "name"
    //      - Seems that all properties files are parsed ( when : ??? ), because
    //        "lexer.(pattern)=name" is inside "name.properties" : impossible
    //        to open a specific file when the specific name is inside it !
    //        I made a test with a separate file "dummy.properties", and it
    //        works.
    //  ........................................................................
    //  1)  strings can only exist within an AS_DIRECTIVE
    //  ........................................................................
    //  2)  scintilla colorization & states :
    //
    //          at each moment we have sc.ch and sc.State :
    //          ( for example sc.ch='A' and sc.State=S1 )
    //
    //          +---+---+---+---+...
    //          | A | B | C | D | ...
    //          +---+---+---+---+...
    //          ^   ^   ^   ^
    //          |   |   |   |
    //          S1  S2  S2  S3
    //
    //          A will be colorized with S1 style
    //          B will be colorized with S2 style
    //          C will be colorized with S2 style
    //          D will be colorized with S3 style
    //  ........................................................................
    //  3)  initStyle is the coloring style of previous EOL
    //  ........................................................................
    //  4)  When
    //    - you move cursor down in an scintilla-based editor
    //      and
    //    - the cursor at the bottom of the editor
    //  it can happend that scintilla lexs just one line, so you always need to
    //  set the _NEXT_ line flags ( for example within a multiline comment ).
    //  ........................................................................
    //  5) If lexed text contain the last character of the document :
    //    - scintilla will append EOF char ( the last _sc.More() will return
    //      EOF )
    //    - else no EOF will be appended
    //  ........................................................................
    //  vars
    LexAccessor             la(_pAccess);
    StyleContext            sc(_startPos, _length, _initStyle, la);
    //  ........................................................................
    LXGLDB("%s\n", "#################################################################################");

    LXGLDB("  LexExt::Lex():sp[%i] ep[%i] line[%i][%i] flags[0x%4x] style[%i] Length[%i]/[%i]\n",
        _startPos                   ,
        _startPos + _length - 1     ,
        la.GetLine(_startPos)                   ,
        la.GetLine(_startPos + _length - 1)     ,
        0                           ,
        _initStyle                  ,
        _length                     ,                                           //  chars to lex
        la.Length()                 );                                          //  total document lentgh

    LXGLDB("%s\n", "#################################################################################");
    //  ........................................................................
    //  go
    ////v_entry_point_lex();
    //  ........................................................................
    //  colourization
    Chrono  ch;

    ch.start();

    liblexerext()->lex_setup(&la, &sc, _startPos, _length );

    if ( ! liblexerext()->loaded() )
        liblexerext()->load( options.language.c_str(), wlp() );

    if ( ! liblexerext()->valid() )
        goto lab_failure;

    if ( ! liblexerext()->lex_run() )                                           //  compute colourisation
        goto lab_failure;

    ch.time();

    LXGLDB("Lexing (ok) took %li:%li (s:ns )\n", ch.es(), ch.ens());

    liblexerext()->colourize();                                                 //  apply colourisation
    liblexerext()->set_lines_flags();                                           //  set lines flags

    //  all colourization is done, dont call sc.Complete(), just call :
    la.Flush();
    return;
    //  ........................................................................
lab_failure:

    ch.time();

    LXGLDB("Lexing (fail )took %li:%li (s:ns )\n", ch.es(), ch.ens());

    liblexerext()->colourize_on_failure();                                      //  apply dummy colourisation & dont set lines flags

    //  all colourization is done, dont call sc.Complete(), just call :
    la.Flush();
}
//  ############################################################################
//  § LexExt-06-fold.cci
//  ############################################################################
void SCI_METHOD LexerExt::Fold(
    unsigned    int             _startPos   ,
                int             _length     ,
                int                         ,                                   //  I dont use _initStyle parameter
                IDocument   *   pAccess     )
{
    //  Folding schematic line levels ( missing in scintilla doc :( ) :
    //
    //  AAA     l
    //  AAA     l
    //  #>>     l       |   SC_FOLDHEADERFLAG
    //  AAA     l + 1
    //  AAA     l + 1
    //  AAA     l + 1
    //  AAA     l + 1
    //  #<<     l + 1
    //  AAA     l
    //  ........................................................................
    //  What is this anyway : SC_FOLDLEVELWHITEFLAG ?
    //  ........................................................................
    //  The SetLevel(...) call for a line __MUST__ be done when i is in that line
    //  ........................................................................
	LexAccessor     styler(pAccess);
    //StyleContext    sc(_startPos, _length, _initStyle, styler);               //  induces infinite calls to Lex() !!!
    a_lex_accessor  =   & styler;

	unsigned    int             endPos      = _startPos + _length;
                //int             visibleChars    = 0;
                int             lc          =   0;                              //  line count
                int             lvp         =   0;                              //  level of previous line
                int             lvc         =   0;                              //  level of current line
                int             lvn         =   0;                              //  level of next line
                char            ch          =   0;
                char            chNext      =   0;
                int             lce         =   0;                              //  Line Current End pos
                bool            atEol       =   false;
    //  ........................................................................
    LXGFDC(     int             lcd;                                            //  line count display ( = lc + 1 )
                int             lco;
                int             lcs;    )
    //  ........................................................................
            lc      =   styler.GetLine( _startPos );
    LXGFDC( lcd     =   lc  +   1;                                              )

    lvp =   SC_FOLDLEVELBASE;                                                   //  default values ( if linestart == 0 )
    lvc =   lvp;

    if ( lc > 0 )                                                               //  get the values we previously set ( linestart != 0 )
    {
		LXGFDC( lvp =   LexerExt::get_fold_level( lc - 1 );                     )
                lvc =   LexerExt::get_fold_level( lc );
    }

    lvn = lvc;

    LXGFDC( lcs     =   styler.LineStart  ( lc );                               )
            lce     =   styler.LineEnd    ( lc );

            ch      =   styler.SafeGetCharAt( _startPos );

    //D printf("> [%i]\n", options.fold_extra);
    //D printf("> [%s]\n", options.fold_extra_start.c_str());
    //D printf("> [%s]\n", options.fold_extra_end.c_str());
    //D printf("> [%s]\n", options.comment1_mark.c_str());
    //D printf("> [%s]\n", options.comment2_mark.c_str());
    //D printf("> [%s]\n", options.comment3_mark.c_str());

    LXGFDB("%s\n", "++++++++++++++++++++++++++");
    LXGFDB("LexerExt::Fold():lc[%5i] sp[%5u] ep[%5u] lcs[%5i] lce[%5i] lvp[%5i] lvp[%5i] lvp[%5i]\n", lcd, _startPos, endPos, lcs, lce, lvp, lvc, lvn);

	for ( unsigned int i = _startPos ; i < endPos; i++ )
    {
        LXGFDC( lco     =   i - lcs;                                            )
                chNext  =   styler.SafeGetCharAt( 1 + i );
                atEol   =   ( i == static_cast< unsigned int >( lce ) );        //(ch == '\r' && chNext != '\n') || (ch == '\n');
        //  ....................................................................
        //  fold mark
        if ( options.fold_extra )
        {
            if ( ch == options.fold_extra_start[0] )
                if ( styler.Match( i, options.fold_extra_start.c_str() ) )
                {
                    LXGFDB("  line[%5i] Match +[%5i]\n", lcd, lco);
                    lvn =   lvn +   1;
                }
            if ( ch == options.fold_extra_end[0] )
                if ( styler.Match( i, options.fold_extra_end.c_str() ) )
                {
                    LXGFDB("  line[%5i] Match -[%5i]\n", lcd, lco);
                    lvn =   lvn -   1;
                }
        }
        //  ....................................................................
        //  fold some gnu as macros
        /*
        if ( ch == '.' )
        {
            if  (   styler.Match(i, ".if")          ||
                    styler.Match(i, ".macro")       )
            {
                LXGFDB("  line[%5i] .if\n", lcd);
                lvn =   lvn +   1;
            }
            if  (   styler.Match(i, ".endif")       ||
                    styler.Match(i, ".endm")        )
            {
                LXGFDB("  line[%5i] .endif\n", lcd);
                lvn =   lvn -   1;
            }
        }
        */
        //  ....................................................................
        //  EOL
        if ( atEol )
        {
            LXGFDB("%s\n", "++++++++++");
            LXGFDB("  line[%5i]:EOL1[%5i] [%5i] [%5i]\n", lcd, lvp, lvc, lvn);

            //  set current line level
            if ( lvc < lvn )
            {
                LXGFDB("c+line[%5i][%5u] [%5i]\n", lcd, i, lvc);
                LexerExt::set_fold_level( lc, lvc | SC_FOLDLEVELHEADERFLAG );
            }
            else
            {
                LXGFDB("c line[%5i][%5u] [%5i]\n", lcd, i, lvc);
                LexerExt::set_fold_level(lc, lvc);
            }
            //  ................................................................
            //  next line stuff
            lc      =   lc  +   1;                                              //  inc line count
    LXGFDC( lcs     =   styler.LineStart( lc );                                 )
            lce     =   styler.LineEnd  ( lc );
            lvc     =   lvn;
            //D LXGFDB("  line[%5i]:EOL2[%5i] [%5i] [%5i]\n", lcd + 1, lvp, lvc, lvn);
            LXGFDB("%s\n", "----------");
        }
        ch  =   chNext;
    }

    //  the last line of a text file dont have an EOL ( else we would have a
    //  next line, etc, etc... ) ; so the last line wont be treated in
    //  the loop ; we do it here
    if ( lvc < lvn )
    {
        LXGFDB("c+line[%5i][%5u] [%5i]\n", lcd, endPos, lvc);
        LexerExt::set_fold_level( lc, lvc | SC_FOLDLEVELHEADERFLAG);
    }
    else
    {
        LXGFDB("c line[%5i][%5u] [%5i]\n", lcd, endPos, lvc);
        LexerExt::set_fold_level(lc, lvc);
    }

    LXGFDB("%s\n", "--------------------------");

    return;
}
//  ############################################################################
//  § LexExt-07-post.cci
//  ############################################################################
std::list < LexerExt::LibLexerExt::SharedLibrary* >    LexerExt::LibLexerExt::s_shared_libraries;

ILexer*
LexerExt::LexerFactory_ext__gas_i386x64()
{
    printf("LexerFactory_ext__gas_i386x64\n");
    return new LexerExt("ext__gas_i386x64");
}
ILexer*
LexerExt::LexerFactory_ext__gas_arm_generic()
{
    printf("LexerFactory_ext__gas_arm_generic\n");
    return new LexerExt("ext__gas_arm_generic");
}
ILexer*
LexerExt::LexerFactoryExt()
{
    printf("LexerFactoryExt\n");
    return new LexerExt();
}


//  ----------------------------------------------------------------------------
//  wether the build is done for scite / codeblocks, tag SCITE_OR_CODEBLOCKS...
//  is replaced by the good lexer module(s)
//  - scite linkage : many lexer modules
//    lm_ext__LANGUAGE(SCLEX_EXT, LexerExt::LexerFactory_ext__LANGUAGE, "ext__LANGUAGE", extWordListDesc);
//  - codeblocks linkage : one lexer module
//    lmExt(SCLEX_EXT, LexerExt::LexerFactoryExt, "ext", extWordListDesc);

SCITE_OR_CODEBLOCKS_MODULE_LINKAGE
