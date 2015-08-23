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

