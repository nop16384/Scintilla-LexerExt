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


