                                                                                /*
    ****************************************************************************
    STATE_NIMPL

    - on pos stack :  0
                     [i]
                     [ ]
    ****************************************************************************
                                                                                */
    /*
     *  anything except newline
     */
<STATE_NIMPL>
{
    /*
     *  anything except newline
     */
.+                                                                              {
        FLEX_DBM("NIMPL", "%s\n", "---");
        FLEX_LCP_PUSH   ( sMcp() );
        FLEX_TOK_ADD    ( SCE_GAS_STATE_NIMPL );
        FLEX_POS_RST    ( sMcp() + 1 );
    }

    /*
     *  newline
     */
{nl}                                                                            {
        FLEX_DBM("NIMPL", "%s\n", "{nl}");
        FLEX_LFLAGS_SET_SL();

        FLEX_REWIND     ();
        FLEX_POS_RAZ    ();
        FLEX_BEGIN_STATE( INITIAL, sMcp()  + 1);
    }
}
                                                                               /*
    ****************************************************************************
    <<EOF>>

    - <<EOF>> is handled identically everywhere

    - Strangely the general <<EOF>> rule has to be put after specialized <<EOF>>
    rules, else flex complains about <<EOF>> multiple rules.

    - Each lex ends here ( due to scintilla lex concept ) ; we have to
      BEGIN( INITIAL ) in case of buggy lexer which dont colorize the
      entire document : in this case scintilla re-lex, but the state would not
      be reinitialized !
    ****************************************************************************
                                                                                */
<<EOF>>                                                                         {
        int pos_lcc =   -1;
        int pos_eof =   -1;
        //  ....................................................................
        YY_USER_ACTION;                                                         //  at <<EOF>>, YY_USER_ACTION is not called

        pos_lcc =   s_flex_last_colourized_pos;
        pos_eof =   sMcp();

        FLEX_DBG("EOF", "%s\n", "<EOF>");

        FLEX_DBG("EOF", "last colourized pos[%i] sMcp()[%i]\n", pos_lcc, pos_eof);

        //  some chars are not colourized
        if ( ( pos_lcc + 1 ) != pos_eof )
        {
            //  no char at all was colorourized
            if ( pos_lcc == -1 )
            {
                pos_lcc =   s_flex_scintilla_start_pos - 1;                     //  -1 for +1 below
            }
            FLEX_POS_RAZ    ();
            FLEX_FCP_PUSH   ( pos_lcc + 1 );
            FLEX_LCP_PUSH   ( pos_eof - 1 );
            FLEX_TOK_ADD    ( SCE_GAS_ERROR_SYNTAX );
        }

        BEGIN( INITIAL );
        return 0;
    }

%%
