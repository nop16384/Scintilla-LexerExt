/*
 *
 *******************************************************************************
 *
 *                              POSTCODE
 *
 *******************************************************************************
 *
 */

//  ============================================================================
//  GLOBAL FUNCTIONS
//  ============================================================================
void    FlexReset(int _start_pos, int _first_line, int _first_line_flags)
{
    yylineno                        =   0;
    s_flex_scintilla_start_pos      =   _start_pos;
    a_mcp                           =   _start_pos - 1;                         //  flex & scite char offsets differs from 1
    s_flex_last_colourized_pos      =   -1;                                     //  no token yet, set -1 as an 'invalid pos' marker
    s_flex_scintilla_line_start     =   _first_line;

    s_start_ml_state                =   sLineFlagsToMLState(_first_line_flags);
    s_start_ml_previous_state       =   sLineFlagsToMLPreviousState(_first_line_flags);

    FLEX_POS_RST( sMcp() + 1 );

    FLEX_LOG("Flex_reset():ml state[%03i] - previous [%03i]\n"  ,
        s_start_ml_state            ,
        s_start_ml_previous_state   );

    if ( s_start_ml_state == eFlexState_COMMENT_ML )
    {
        sCOMMENT_ML_RT_previous_state_set( s_start_ml_previous_state );
        sBegin_state_COMMENT_ML( 0 );
    }
}
//  ============================================================================
void    state_begin(int _state, int _pos)
{
    #ifdef  LLG_DEBUG__FLEX_ANNOUNCE_STATE_CHANGE
    printf("--------------------------------------------------------------------\n");
    printf("Beginning state [%i] @ [%5i][%5i]\n", _state, yylineno, _pos);
    #endif
    sPosDump();

    switch ( _state )
    {

    case    eFlexState_INITIAL          :   sBegin_state_INITIAL    ( _pos );   break;
    case    eFlexState_I1               :   sBegin_state_I1         ( _pos );   break;
    case    eFlexState_I2               :   sBegin_state_I2         ( _pos );   break;
    case    eFlexState_I3               :   sBegin_state_I3         ( _pos );   break;
    case    eFlexState_I4               :   sBegin_state_I4         ( _pos );   break;

    case    eFlexState_LABEL            :   sBegin_state_LABEL      ( _pos );   break;
    case    eFlexState_EXPRESSION       :   sBegin_state_EXPRESSION ( _pos );   break;
    case    eFlexState_DIRECTIVE        :   sBegin_state_DIRECTIVE  ( _pos );   break;
    case    eFlexState_INSTRUCTION      :   sBegin_state_INSTRUCTION( _pos );   break;

    case    eFlexState_COMMENT_SL       :   sBegin_state_COMMENT_SL ( _pos );   break;
    case    eFlexState_COMMENT_ML       :   sBegin_state_COMMENT_ML ( _pos );   break;

    case    eFlexState_STRING           :   sBegin_state_STRING     ( _pos );   break;

    case    eFlexState_NEWLINE          :   sBegin_state_NEWLINE    ( _pos );   break;

    case    eFlexState_NIMPL            :   sBegin_state_NIMPL      ( _pos );   break;

    case    eFlexState_Error            :   sBegin_st_error( _pos );    break;


    default:
    break;

    }

    //U s_state_current =   _state;
}
//  ============================================================================
//U int             sIdx()                      {   return s_flex_states_positions_index;   }
//U int             sIdxFcp()                   {   return s_flex_start_positions_index;    }
//U int             sIdxLcp()                   {   return s_flex_match_positions_index;    }

static  void    sIdxRaz()
{
    s_flex_start_positions_index    =   0;
    s_flex_match_positions_index    =   0;
    s_flex_states_positions_index   =   0;
}

static  int     sFcp        (int _index)    {   return  s_flex_start_positions[_index]; }
static  int     sLcp        (int _index)    {   return  s_flex_match_positions[_index]; }

static  void    sFcpPush    (int _pos)
{
    s_flex_start_positions[ s_flex_start_positions_index ++    ]   =   _pos;
}
static  void    sLcpPush    (int _pos)
{
    s_flex_match_positions[ s_flex_match_positions_index ++    ]   =   _pos;
    s_flex_states_positions_index++;
}
static  void    sPosDump()
{
    #ifdef  LLG_DEBUG__FLEX__DUMP_POSITIONS_AT_STATE_CHANGE
        printf("Dumping positions:");
        for ( int i = 0 ; i != s_flex_start_positions_index ; i++ )
            {   printf("[%03i]", sFcp(i));  }
        printf("\n");
        printf("                  ");
        for ( int i = 0 ; i != s_flex_match_positions_index ; i++ )
            {   printf("[%03i]", sLcp(i));  }
        printf("\n");
    #endif
}
//  ============================================================================
//  STATE_INITIAL variables & functions
//  ============================================================================
void    sBegin_state_INITIAL(int _pos)
{
    sFlagILocRst();
    sFlagIDotRst();
    BEGIN( INITIAL );
}
//  ============================================================================
//  STATE_I1
//  ============================================================================
void    sBegin_state_I1(int _pos)
{
    sBegin_state_INITIAL(_pos);
}
//  ============================================================================
//  STATE_I2
//  ============================================================================
void    sBegin_state_I2(int _pos)
{
    BEGIN( STATE_I2 );
}
//  ============================================================================
//  STATE_I3
//  ============================================================================
void    sBegin_state_I3(int _pos)
{
    BEGIN( STATE_I3 );
}
//  ============================================================================
//  STATE_I4
//  ============================================================================
void    sBegin_state_I4(int _pos)
{
    BEGIN( STATE_I4 );
}
//  ============================================================================
//  STATE_LABEL
//  ============================================================================
void    sBegin_state_LABEL(int _pos)
{
    BEGIN( STATE_LABEL );
}
//  ============================================================================
//  STATE_EXPRESSION
//  ============================================================================
void    sBegin_state_EXPRESSION(int _pos)
{
    BEGIN( STATE_EXPRESSION );
}
//  ============================================================================
//  STATE_DIRECTIVE
//  ============================================================================
void    sBegin_state_DIRECTIVE(int _pos)
{
    BEGIN( STATE_DIRECTIVE );
}
//  ============================================================================
//  STATE_INSTRUCTION
//  ============================================================================
void    sBegin_state_INSTRUCTION(int _pos)
{
    sRT_state_INSTRUCTION_prepare();

    BEGIN( STATE_INSTRUCTION );
}

void    sRT_state_INSTRUCTION_prepare()
{
}
//  ============================================================================
//  STATE_COMMENT_SL variables & functions
//  ============================================================================
static  void    sBegin_state_COMMENT_SL(int _pos)
{
    BEGIN( STATE_COMMENT_SL );
}

int     sCOMMENT_SL_RT_color()                  { return s_comment_sl_rt_color;     }
void    sCOMMENT_SL_RT_color_set(int _color)    { s_comment_sl_rt_color = _color;   }
//  ============================================================================
//  STATE_COMMENT_ML variables & functions
//  ============================================================================
void    sBegin_state_COMMENT_ML(int _pos)
{
    BEGIN( STATE_COMMENT_ML );
}

void    sCOMMENT_ML_RT_init(int _current_state)
{
    sCOMMENT_ML_RT_previous_state_set( _current_state );
    //liblexergas::SetLineFlags(yylineno, 0x1234);
}

int     sCOMMENT_ML_RT_previous_state()
{
    return s_comment_ml_rt_previous_state;
}
void    sCOMMENT_ML_RT_previous_state_set(int _state)
{
    s_comment_ml_rt_previous_state  = _state;
}
//  ============================================================================
//  STATE_STRING variables & functions
//  ============================================================================
void    sBegin_state_STRING(int _pos)
{
    BEGIN( STATE_STRING );
}

int     sSTRING_RT_previous_state()
{
    return s_string_rt_previous_state;
}
void    sSTRING_RT_previous_state_set(int _state)
{
    s_string_rt_previous_state  = _state;
}
//  ============================================================================
//  STATE_NEWLINE variables & functions
//  ============================================================================
void    sBegin_state_NEWLINE(int _pos)
{
    BEGIN( STATE_NEWLINE );
}
//  ============================================================================
//  STATE_NIMPL variables & functions
//  ============================================================================
void    sBegin_state_NIMPL(int _pos)
{
    BEGIN( STATE_NIMPL );
}
//  ============================================================================
//  STATE_ERROR variables & functions
//  ============================================================================
void    sStError_token_added_set(bool _b)
{
    a_st_error_token_added    =   _b;
}
bool    sStError_token_added()
{
    return a_st_error_token_added;
}

void    sBegin_st_error(int _pos)
{
    sStError_token_added_set(false);
    BEGIN( STATE_ERROR );
}
//  ============================================================================
//  STATE_COMMENT_BLOCK variables & functions
//  ============================================================================
void    scb_reset()
{
    //scb_color   = SCE_GAS_SYNTAX_UNKNOWN;
    //scb_type    =   0;
}
void    scb_begin(int _scb_type)
{
    //printf("> LGF():%4i +++ ( STATE_COMMENT_BLOCK [%i] ) +++\n", LexerGas::FlexCharPos(yytext), _scb_type);

    scb_reset();
    //scb_type    =   _scb_type;
    //if ( _scb_type == eLexGasFlexScb1 )
    {
        //scb_color   = SCE_GAS_COMMENT1;
    }
    //if ( _scb_type == eLexGasFlexScb2 )
    {
        //scb_color   = SCE_GAS_COMMENT2;
    }
    //if ( _scb_type == eLexGasFlexScb3 )
    {
        //scb_color   = SCE_GAS_COMMENT3;
    }

    BEGIN(STATE_COMMENT_BLOCK);
}

