                                                                                /*
    ****************************************************************************
    STATE_STRING

    When entering this state, a '"' has been encountered

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
<STATE_STRING>
{
    /*
     *      Escape sequences
     *
     */
{wSTREsc}                                                                       {
        FLEX_DBM("STRING", "%s\n", "{wSTREsc}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_STRING_ESCAPE_SEQUENCE );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      Isolated '\' : allow multiline strings ???                          //  _GWR_TODO_ multiline strings ?
     */
    /*
\\                                                                              {
    }
    */
    /*
     *      Isolated '"' : string end
     */
\"                                                                              {
        FLEX_DBM("STRING", "%s\n", """");
        FLEX_LCP_PUSH       ( sMcp() );
        FLEX_TOK_ADD        ( SCE_GAS_STRING );
        FLEX_POS_RAZ        ();
        FLEX_BEGIN_STATE_INT( sSTRING_RT_previous_state(), sMcp() + 1 );
    }
    /*
     *      no xste inside string
     *
     */
    /*
     *      AOC ( no free char so not matching rule for instant )
     */
.                                                                               {
        FLEX_DBM_ERR("STRING", "[%02x]\n", yytext[0]);
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_STRING );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      newline : error                                                     //  _GWR_TODO_ multiline strings ?
     */
{nl}                                                                            {
        FLEX_DBM("STRING", "%s\n", "{nl}");
        FLEX_LFLAGS_SET_SL();

        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( Error, sMcp() + 1 );
    }
}
