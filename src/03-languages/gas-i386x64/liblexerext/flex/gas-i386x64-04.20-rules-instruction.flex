                                                                                /*
    ****************************************************************************
    STATE_INSTRUCTION

    Scan the beginning of a statement.

    - on pos stack :  0   1   2
                     [i] [k] [m]    or      [i] [k]
                     [j] [l]                [j]      ( + nl immedately after )
                     [wS][ +]               [wS]

    - on pos stack :  0
                     [i]

    - wS is stored in sIWordSymbol
    ****************************************************************************
                                                                                */
<STATE_INSTRUCTION>
{
    /*
     *      comment sl
     */
{wCMTSL1}                                                                       {
        FLEX_DBM("INSTRUCTION", "%s\n", "comment sl(#)");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT1 );

        sCOMMENT_SL_RT_color_set( SCE_GAS_COMMENT1 );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( COMMENT_SL, sMcp() + 1 );
}
{wCMTSL2}                                                                       {
        FLEX_DBM("INSTRUCTION", "%s\n", "comment sl(#)");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT2 );

        sCOMMENT_SL_RT_color_set( SCE_GAS_COMMENT2 );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( COMMENT_SL, sMcp() + 1 );
}
{wCMTSL3}                                                                       {
        FLEX_DBM("INSTRUCTION", "%s\n", "comment sl(#)");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT3 );

        sCOMMENT_SL_RT_color_set( SCE_GAS_COMMENT3 );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( COMMENT_SL, sMcp() + 1 );
}

{cWsp}+                                                                         {
        FLEX_DBM("INSTRUCTION", "%s\n", "{cWsp}+");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DEFAULT );
        FLEX_POS_RST    ( sMcp() + 1 );
    }

{wOPImm}                                                                        {
        FLEX_DBM("INSTRUCTION", "%s\n", "{wOPImm}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_OPERAND_IMMEDIATE );
        FLEX_POS_RST    ( sMcp() + 1 );
    }

{wS}                                                                            {
        int n   =   SCE_GAS_OPERAND_SYMBOL;

        FLEX_DBM("INSTRUCTION", "%s\n", "{wInst}");
        FLEX_LCP_PUSH   ( sMcp() );

        //FLEX_TOK_ADD    ( SCE_GAS_INSTRUCTION_GENERIC );
        if ( liblexerext::IsInstruction( yytext, &n ) )
        {
            FLEX_DBG( "INSTRUCTION", "INST => [%s][%i]\n", yytext, n);
            FLEX_TOK_ADD    ( n );
        }
        else
        {
            FLEX_DBG( "INSTRUCTION", "SYM => [%s]\n", yytext);
            FLEX_TOK_ADD    ( n );
        }

        FLEX_POS_RST    ( sMcp() + 1 );
    }

{wOPNCst}                                                                       {
        FLEX_DBM("INSTRUCTION", "%s\n", "{wOPNcst}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_OPERAND_SCALAR );
        FLEX_POS_RST    ( sMcp() + 1 );
    }

{wOPReg}                                                                        {
        FLEX_DBM("INSTRUCTION", "%s %s\n", "{wOPReg}", yytext);
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_OPERAND_REGISTER );
        FLEX_POS_RST    ( sMcp() + 1 );
    }

{cLp}                                                                           {
        FLEX_DBM("INSTRUCTION", "%s\n", "{cLp}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_REVERSE );
        FLEX_POS_RST    ( sMcp() + 1 );
    }

{cRp}                                                                           {
        FLEX_DBM("INSTRUCTION", "%s\n", "{cRp}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_REVERSE );
        FLEX_POS_RST    ( sMcp() + 1 );
    }

{cComma}                                                                        {
        FLEX_DBM("INSTRUCTION", "%s\n", "{cComma}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_REVERSE );
        FLEX_POS_RST    ( sMcp() + 1 );
    }

.                                                                               {
        FLEX_DBM_ERR("INSTRUCTION", "[%02x]\n", yytext[0]);
        //FLEX_LCP_PUSH   ( sMcp() );
        //FLEX_TOK_ADD    ( SCE_GAS_ERROR_SYNTAX_UNCOLORIZED );

        FLEX_REWIND         ();
        FLEX_POS_RAZ        ();
        FLEX_BEGIN_STATE( Error, sMcp() + 1 );
    }

{nl}                                                                            {
        FLEX_DBM("INSTRUCTION", "%s\n", "{nl}");
        FLEX_LFLAGS_SET_SL();

        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( NEWLINE, sMcp() + 1 );
    }

}
