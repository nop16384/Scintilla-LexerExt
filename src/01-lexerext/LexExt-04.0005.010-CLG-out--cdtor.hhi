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

