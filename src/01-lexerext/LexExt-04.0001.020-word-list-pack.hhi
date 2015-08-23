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
