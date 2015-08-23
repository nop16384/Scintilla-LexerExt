                                                                                /*
    ****************************************************************************
    STATE_NEWLINE

    When entering this state, we point on the first newline encountered

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
<STATE_NEWLINE>
{
    /*
     *      newline
     */
{nl}                                                                            {
        FLEX_DBM("NEWLINE", "%s\n", "{nl}+");
        FLEX_LFLAGS_SET_SL();

        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DEFAULT );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( INITIAL, sMcp() + 1 );
    }
    /*
     *      any other : finish state
     */
.                                                                               {
        FLEX_DBM("NEWLINE", "%s\n", ".");
        FLEX_REWIND     ();
        FLEX_POS_RAZ    ()
        FLEX_BEGIN_STATE( INITIAL, sMcp() + 1 );
    }
}
