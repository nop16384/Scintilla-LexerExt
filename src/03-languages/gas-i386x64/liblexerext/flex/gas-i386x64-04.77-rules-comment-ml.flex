                                                                                /*
    ****************************************************************************
    STATE_COMMENT_ML

    When entering this state, we point on the first char after the '/''*'

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
<STATE_COMMENT_ML>
{
    /*
     *      AOC except '*'
     */
{cCMTMLbx}+                                                                     {
        FLEX_DBM("COMMENT_ML", "[%s][%s]\n","{cCMTMLbx}+", yytext);

        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT_ML );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      '*'( will be superseeded by following rule )
     */
{cCMTMLb}                                                                       {
        FLEX_DBM("COMMENT_ML", "[%s]\n", "isolated '*'");

        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT_ML );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      end string
     */
{wCMTMLb}                                                                       {
        FLEX_DBM("COMMENT_ML", "[%s]\n", "*/");

        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT_ML );
        FLEX_POS_RAZ    ()
        FLEX_BEGIN_STATE( INITIAL, sMcp() + 1 );
    }
    /*
     *      nl ( warning, flex has inc-ed yylineno ! )
     */
{nl}                                                                            {
        FLEX_DBM("COMMENT_ML", "%s\n", "{nl}");

        FLEX_LOG("ML NL:lineno[%05i]\n", yylineno);
        FLEX_LFLAGS_SET_ML(
                    eFlexState_COMMENT_ML           ,
                    sCOMMENT_ML_RT_previous_state() );

        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT_ML );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      exit state
     */
        /*{wCMTMLb}                                                                       {
        FLEX_DBM("COMMENT_ML", "%s\n", "");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT_ML );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( INITIAL, sMcp() + 1 );
    }*/
}
