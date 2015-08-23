                                                                                /*
    ****************************************************************************
    STATE_ERROR

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
<STATE_ERROR>
{
    /*
     *      xste, newline : no xste here, just newline ( avoid strings problem )
     */
{nl}                                                                            {
        FLEX_LFLAGS_SET_SL();

        if ( sStError_token_added() )
        {
            FLEX_DBM("ERROR", "%s\n", "{nl} - ok");

            FLEX_REWIND     ();
            FLEX_POS_RAZ    ();
            FLEX_BEGIN_STATE( NEWLINE, sMcp() + 1 );
        }
        /*  char that caused error is '\n'                                      */
        else
        {
            FLEX_DBM("ERROR", "%s\n", "{nl} ( but no token added ! )");

            FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD    ( SCE_GAS_ERROR_SYNTAX );
            FLEX_POS_RAZ    ();
            FLEX_BEGIN_STATE( INITIAL, sMcp() + 1 );
        }
    }
    /*
     *      any other -> colorize as error
     */
.*                                                                              {
        FLEX_DBM("ERROR", "[%i:%s]\n", (int)yyleng, yytext);
        sStError_token_added_set(true);
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_ERROR_SYNTAX );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
}

