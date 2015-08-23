                                                                                /*
    ****************************************************************************
    STATE_LABEL

    Nothing is allowed after the [:] ( except spaces )

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
<STATE_LABEL>
{

{cWsp}+                                                                         {
        FLEX_DBM("LABEL", "%s\n", "{cWsp}+");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DEFAULT );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      xste, nexline
     */
{nl}                                                                            {
        FLEX_DBM("LABEL", "%s\n", "{nl}");
        FLEX_LFLAGS_SET_SL();

        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( NEWLINE, sMcp() + 1 );
    }
    /*
     *      any other char / string : error
     */
.                                                                               {
        FLEX_DBM_ERR("LABEL", "JAM [%02x] -> ERROR\n", yytext[0]);
        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( Error, sMcp() + 1 );                                  //  _GWR_TODO_ Memorization vs RAZ
    }

}
