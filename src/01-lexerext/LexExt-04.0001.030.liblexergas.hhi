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




