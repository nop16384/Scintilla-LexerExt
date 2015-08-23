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
