                                                                                /*
    ****************************************************************************
    STATE_COMMENT_SL

    When entering this state, we point on the first char after the #-s

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
<STATE_COMMENT_SL>
{
    /*
     *      AOC
     */
.*                                                                              {
        FLEX_DBM("COMMENT_SL", "%s\n", "(text...)");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( sCOMMENT_SL_RT_color() );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      newline : exit state
     */
{nl}                                                                            {
        FLEX_DBM("COMMENT_SL", "%s\n", "{nl}");
        FLEX_LFLAGS_SET_SL();

        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( INITIAL, sMcp() + 1 );
    }
}
