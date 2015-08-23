                                                                                /*
    ****************************************************************************
    STATE_INITIAL ( == STATE_I1 )

    Scan the beginning of a statement.

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
<INITIAL>
{
    /*
     *      comments
     */
{wCMTMLa}                                                                       {
        FLEX_DBM("INITIAL", "%s\n", "comment ml");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT_ML );
        FLEX_POS_RAZ    ();
        sCOMMENT_ML_RT_init( eFlexState_INITIAL );
        FLEX_BEGIN_STATE( COMMENT_ML, sMcp() + 1 );
}

{wCMTSL1}                                                                       {
        FLEX_DBM("INITIAL", "%s\n", "comment sl(#)");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT1 );

        sCOMMENT_SL_RT_color_set( SCE_GAS_COMMENT1 );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( COMMENT_SL, sMcp() + 1 );
}
{wCMTSL2}                                                                       {
        FLEX_DBM("INITIAL", "%s\n", "comment sl(##)");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT2 );

        sCOMMENT_SL_RT_color_set( SCE_GAS_COMMENT2 );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( COMMENT_SL, sMcp() + 1 );
}
{wCMTSL3}                                                                       {
        FLEX_DBM("INITIAL", "%s\n", "comment sl(###)");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_COMMENT3 );

        sCOMMENT_SL_RT_color_set( SCE_GAS_COMMENT3 );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( COMMENT_SL, sMcp() + 1 );
}
    /*
     *      spaces
     */
{cWsp}+                                                                         {
        FLEX_DBM("INITIAL", "%s\n", "{cWsp}+");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DEFAULT );
        FLEX_POS_RST    ( sMcp() + 1 );
    }
    /*
     *      ".L" string
     */
{wLoc}                                                                          {
        FLEX_DBM("INITIAL", "%s\n", "{wLoc}");
        FLEX_LCP_PUSH   ( sMcp() );
        //  ( chaining positions, so no RAZ although state change )
        sFlagILocSet();                                                         //  set local flag
        FLEX_BEGIN_STATE( I2 , sMcp() + 1 );
    }
    /*
     *      xste, nexline
     */
{wXste}                                                                         {
        FLEX_DBG("INITIAL", "%s\n", "{wXste}");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_DEFAULT );
        FLEX_POS_RST    ( sMcp() + 1 );                                         //  _GWR_TODO_ xste should reset to INITIAL
    }
{nl}                                                                            {
        FLEX_DBM("INITIAL", "%s\n", "{nl}");
        FLEX_LFLAGS_SET_SL();

        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( NEWLINE, sMcp() + 1 );
    }
    /*
     *      AOC : jump to STAGE2
     */
.                                                                               {
        FLEX_DBM("INITIAL", "%s\n", "no {wLoc}");
        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( I2, sMcp() + 1 );
    }

}
                                                                                /*
    ****************************************************************************
    STATE_I2

    - on pos stack :  0          0
                     [i]    or  [i]  [k]
                                [j]
                                [.L]
    ****************************************************************************
                                                                                */
<STATE_I2>
{
    /*
     *      [D1][B1][D1][:1]                4   L
     */
{wNDecP}{wCtrlB}{wNDecP}{cCol}                                                  {   //  _GWR_TODO_ ensure .L
        FLEX_DBM("I2", "%s\n", "R4");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD_D  ( 0, 1, SCE_GAS_LABEL_GAS );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( LABEL, sMcp() + 1 );
    }
    /*
     *      [D1][A1][D1][:1]                5   L
     */
{wNDecP}{wCtrlA}{wNDecP}{cCol}                                                  {   //  _GWR_TODO_ ensure .L
        FLEX_DBM("I2", "%s\n", "R5");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD_D  ( 0, 1, SCE_GAS_LABEL_GAS );
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( LABEL, sMcp() + 1 );
    }
    /*
     *      [D1][:1]                        7
     *      [L1][D1][:1]                    13  L
     */
{wNDecP}{cCol}                                                                  {   //  _GWR_TODO_ ensure no .L
        FLEX_DBM("I2", "%s\n", "R7, R13");
        if ( sFlagILoc() )
        {
            FLEX_DBM("I2", "%s\n", "R13");
            FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD_D  ( 0, 1, SCE_GAS_LABEL_GAS );                        //  [L1][D1][:1]
            FLEX_POS_RAZ    ();
            FLEX_BEGIN_STATE( LABEL, sMcp() + 1 );
        }
        else
        {
            FLEX_DBM("I2", "%s\n", "R7");
            FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD    ( SCE_GAS_LABEL_GAS );                              //  [D1][:1]
            FLEX_POS_RAZ    ();
            FLEX_BEGIN_STATE( LABEL, sMcp() + 1 );
        }
    }
    /*
     *      {wS} ; set D flag and go to I3
     */
{wS}                                                                            {
        FLEX_DBM("I2", "%s\n", "{wS}");

        if ( yytext[0] == '.' )
            sFlagIDotSet();

        sIWordSymbol.assign( yytext );

        FLEX_LCP_PUSH   ( sMcp() );
        //  ( chaining positions, so no RAZ although state change )
        FLEX_BEGIN_STATE( I3, sMcp() + 1 );
    }
    /*
     *      xste, newline, AOC : error
     */
.|{nl}                                                                          {
        FLEX_DBM_ERR("I2", "%s\n", "JAM");
        FLEX_LFLAGS_SET_SL();

        //  if ".L" colourize it
        if ( sFlagILoc() )
            FLEX_TOK_ADD    ( SCE_GAS_ERROR_SYNTAX_UNCOLORIZED );               //  [.L]

        FLEX_REWIND         ();
        FLEX_POS_RAZ        ();
        FLEX_BEGIN_STATE( Error, sMcp() + 1 );
    }
}
                                                                                /*
    ****************************************************************************
    STATE_I3

    - on pos stack :  0              0    1    2
                     [i] [k]    or  [i]  [k]  [m]
                     [j]            [j]  [l]
                     [wS]           [.L] [wS]
    ****************************************************************************
                                                                                */
<STATE_I3>
{
    /*
     *      [wS][:1]                        3       (D)
     *      [wS][:1]                        6   L   (D)
     */
{cCol}                                                                          {
        FLEX_DBM("I3", "%s\n", "R3,R6");

        if ( sFlagILoc() )
        {
            FLEX_DBM("I3", "%s\n", "R6");
            FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD_D  ( 0, 2, SCE_GAS_LABEL_GAS );                        //  [.L][wS][:1]
            FLEX_POS_RAZ    ();
            FLEX_BEGIN_STATE( LABEL, sMcp() + 1 );
        }
        else
        {
            FLEX_DBM("I3", "%s\n", "R3");
            FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD_D  ( 0, 1, SCE_GAS_LABEL_USR );                        //  [wS][:1]
            FLEX_POS_RAZ    ();
            FLEX_BEGIN_STATE( LABEL, sMcp() + 1 );
        }
    }
    /*
     *      [wS]                            1       (D)
     *      [wS]                            2   L
     */
{cWsp}*{cEqu}                                                                   {   //  _GWR_REM_ never empty token, even if 0 wsp
        FLEX_DBM("I3", "%s\n", "R1, R2");

        if ( sFlagILoc() )
        {
            FLEX_DBM("I3", "%s\n", "R2");
            FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD_D  ( 0, 1, SCE_GAS_LABEL_GAS );                        //  [.L][wS]
            FLEX_TOK_ADD_S  ( 2, SCE_GAS_DEFAULT );                             //  [ *][=1]
            //FLEX_BEGIN_STATE( Expression, sMcp() + 1 );
                FLEX_POS_RAZ    ();
                FLEX_BEGIN_STATE( NIMPL, sMcp() + 1 );                          //  _GWR_TODO_ Expression
        }
        else
        {
            FLEX_DBM("I3", "%s\n", "R1");
            FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD_S  ( 0, SCE_GAS_LABEL_USR );                           //  [wS]
            FLEX_TOK_ADD_S  ( 1, SCE_GAS_DEFAULT );                             //  [ *][=1]
            //FLEX_BEGIN_STATE( Expression, sMcp() + 1 );
                FLEX_POS_RAZ    ();
                FLEX_BEGIN_STATE( NIMPL, sMcp() + 1 );                          //  _GWR_TODO_ Expression
        }
    }
    /*
     *      9, 10, 11, 12 : count spaces and go to I4
     */
{cWsp}+                                                                         {   //  _GWR_TODO_ epurer, '.' superseeds 0 whitespace
        FLEX_DBM("I3", "%s\n", "R9, ( R10, R11, R12 )");
        //  ( chaining positions, so no RAZ although state change )
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_BEGIN_STATE( I4, sMcp() + 1 );
    }
    /*
     *      xste, AOC : error
     */
.                                                                                {
        FLEX_DBM_ERR("I3", "%s\n", "JAM");

        if ( sFlagILoc() )
        {
            ////FLEX_DBM("I3", "%s\n", "R6");
            ////FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD_D  ( 0, 1, SCE_GAS_ERROR_SYNTAX_UNCOLORIZED );         //  [.L][wS]
        }
        else
        {
            ////FLEX_DBM("I3", "%s\n", "R3");
            ////FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD    ( SCE_GAS_ERROR_SYNTAX_UNCOLORIZED );               //  [wS]
        }
        FLEX_REWIND         ();
        FLEX_POS_RAZ        ();
        FLEX_BEGIN_STATE( Error, sMcp() + 1 );
    }
    /*
     *      {nl} : error / directive / inst
     */
{nl}                                                                            {
        FLEX_LFLAGS_SET_SL();

        if ( sFlagILoc() )
        {
            FLEX_DBM_ERR("I3", "%s\n", "[.L][wS][nl]");
            ////FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD_D      ( 0, 1, SCE_GAS_ERROR_SYNTAX_UNCOLORIZED );     //  [.L][wS]

            FLEX_REWIND         ();
            FLEX_POS_RAZ        ();
            FLEX_BEGIN_STATE    ( Error, sMcp() + 1 );
        }
        else
        {
            if ( sFlagIDot() )
            {
                FLEX_DBM("I3", "%s\n", "[.DIRECTIVE][nl]");
                ////FLEX_LCP_PUSH   ( sMcp() );
                FLEX_TOK_ADD        ( SCE_GAS_DIRECTIVE );                      //  [wS]    D

                FLEX_REWIND         ();
                FLEX_POS_RAZ        ();
                FLEX_BEGIN_STATE    ( NEWLINE, sMcp() + 1 );
            }
            else
            {
                FLEX_DBM_ERR("I3", "%s\n", "[wS][nl]");

                FLEX_REWIND         ();
                ////FLEX_BEGIN_STATE    ( INSTRUCTION, sMcp() + 1 );

                FLEX_TOK_ADD        ( SCE_GAS_INSTRUCTION_GENERIC );            //  [wS]    //  _GWR_TODO_  colourize in STATE_INSTTRUCTION

                FLEX_POS_RAZ        ();
                FLEX_BEGIN_STATE    ( NEWLINE, sMcp() + 1 );

            }
        }
    }
}
                                                                                /*
    ****************************************************************************
    STATE_I4

    - on pos stack :  0                  0    1    2    3
                     [i] [k]  [m]   or  [i]  [k]  [m]  [p]
                     [j] [l]            [j]  [l]  [n]
                     [wS][ +]           [.L] [wS] [ +]
    ****************************************************************************
                                                                                */
<STATE_I4>
{
    /*
     *      [.1][V+]                        9       D
     *      [wI]                            10
     *      [wI] [wI]                       11
     *      [wI] [wI] [wI]                  12
     *
     *      Act accordingly to the first non-wsp char ( wsp chars have been
     *      handled by STATE_I3 )
     */
.|{nl}                                                                          {
        FLEX_DBM("I4", "%s\n", "R9, ( R10, R11, R12 )");
        FLEX_LFLAGS_SET_SL();

        if ( sFlagILoc() )
        {
            FLEX_DBM_ERR("I4", "%s\n", "R9 ERROR");
            FLEX_LCP_PUSH   ( sMcp() );
            FLEX_TOK_ADD_D  ( 0, 2, SCE_GAS_ERROR_SYNTAX_UNCOLORIZED );         //  [.L][wS][ +]

            FLEX_REWIND         ();
            FLEX_POS_RAZ        ();
            FLEX_BEGIN_STATE( Error, sMcp() + 1 );
        }
        else
        {
            if ( sFlagIDot() )
            {
                FLEX_DBM("I4", "%s\n", "R9 (ok)");
                FLEX_TOK_ADD_S  ( 0, SCE_GAS_DIRECTIVE );                       //  [wS]
                FLEX_TOK_ADD_S  ( 1, SCE_GAS_DEFAULT );                         //  [ +]

                FLEX_REWIND();
                FLEX_POS_RAZ    ();
                FLEX_BEGIN_STATE( DIRECTIVE, sMcp() + 1 );
            }
            else
            {
                FLEX_DBM("I4", "%s\n", "R10, R11, R12 (ok)");

                FLEX_TOK_ADD_S  ( 0, SCE_GAS_INSTRUCTION_GENERIC );             //  [wS]
                FLEX_TOK_ADD_S  ( 1, SCE_GAS_DEFAULT );                         //  [ +]

                FLEX_REWIND();
                FLEX_POS_RAZ    ();
                FLEX_BEGIN_STATE( INSTRUCTION, sMcp() + 1 );                    //  _GWR_TODO_  colourize in STATE_INSTRUCTION
            }
        }
    }
}


























