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
