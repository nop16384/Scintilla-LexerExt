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
