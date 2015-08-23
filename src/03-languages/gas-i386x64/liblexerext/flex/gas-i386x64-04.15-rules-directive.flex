                                                                                /*
    ****************************************************************************
    STATE_DIRECTIVE

    Nothing is allowed after the [:] ( except spaces )

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
<STATE_DIRECTIVE>
{

{cWsp}+                                                                         {
        FLEX_DBM("DIRECTIVE", "%s\n", "{cWsp}+");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DEFAULT );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      xste
     *
    {wXste}                                                                         {
        FLEX_DBG("DIRECTIVE", "%s\n", "{wXste}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DEFAULT );
        FLEX_POS_RST    ( sMcp() + 1 );                                         //  _GWR_TODO_ xste should reset to INITIAL
    }
    */
    /*
     *      newline
     */
{nl}                                                                            {
        FLEX_DBM("DIRECTIVE", "%s\n", "{nl}");
        FLEX_LFLAGS_SET_SL();

        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( NEWLINE, sMcp() + 1 );
    }
    /*
     *      token
     */
{wDIRTok}                                                                       {
        FLEX_DBM("DIRECTIVE", "%s\n", "{wDIRTok}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DIRECTIVE_TOKEN );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      string start
     */
\"                                                                              {
        FLEX_DBM_ERR("DIRECTIVE", "%s\n", """");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_STRING );
        FLEX_POS_RAZ    ();
        sSTRING_RT_previous_state_set( eFlexState_DIRECTIVE );
        FLEX_BEGIN_STATE( STRING, sMcp() + 1);
    }
    /*
     *      AOC ( no free char so not matching rule for instant )
     */
    /*.                                                                               {
        FLEX_DBM_ERR("DIRECTIVE", "[%02x]", yytext[0]);
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DIRECTIVE_TOKEN );
        FLEX_POS_RST    ( sMcp() + 1 );
    }*/
}
