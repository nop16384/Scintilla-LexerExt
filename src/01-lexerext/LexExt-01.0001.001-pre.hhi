//  ############################################################################
//  § LexExt-01-pre.cci
//  ############################################################################

//#define     LXG_UCHAR(X)    (static_cast< unsigned char >( X ))
//#define     LXG_TID8(TID)   (static_cast< LexerExt::eTokenId8 >( TID ))
#define     LXG_SIZE_T_MAX  (static_cast< size_t >(-1))
//  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define     LXG_MEMBER_AUTO( TYPE, NAME, METHODNAME )                           \
    private:                                                                    \
    TYPE        a_##NAME;                                                       \
    public:                                                                     \
    TYPE        METHODNAME()                                                    \
                {                                                               \
                    return a_##NAME;                                            \
                }                                                               \
    void        METHODNAME##_set(TYPE _T)                                       \
                {                                                               \
                    a_##NAME = _T;                                              \
                }
//  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Colors
#define     LXGRV   "\033[7m"                                                   //  attribute reverse video
#define     LXGNA   "\033[0m"                                                   //  no attributes
#define     LXGC0   "\033[0;37m"                                                //  white
#define     LXGC1   "\033[0;33m"                                                //  yellow
#define     LXGC2   "\033[0;32m"                                                //  green
#define     LXGC9   "\033[0;31m"                                                //  red
//  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Errors
#define     LXG_ERR(FORMAT, ...)        printf(LXGC9 FORMAT LXGC0, __VA_ARGS__)
#define     LXG_INTERRUPT                                                       \
            {                                                                   \
                LXG_ERR("EXPLICIT INTERRUPT 'int $3' [%s][%u]\n",               \
                __FILE__, __LINE__ );                                           \
                __asm__ ( "int $3" );                                           \
            }
#define     LXG_INTERRUPT_MSG(FORMAT, ...)                                      \
            {                                                                   \
                LXG_ERR(FORMAT, __VA_ARGS__);                                   \
                LXG_ERR("EXPLICIT INTERRUPT 'int $3' [%s][%u]\n",               \
                __FILE__, __LINE__ );                                           \
                __asm__ ( "int $3" );                                           \
            }
//  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  All these macros for avoiding unused-but-set warnings because my debugs
//  use specific variables
//  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Generic debug
#define     LXG_DEBUG_LEXING
//#define     LXG_DEBUG_FOLDING
#define     LXG_DEBUG_LLG
//  ............................................................................
//  LEXING
#ifdef      LXG_DEBUG_LEXING
    #define     LXGLDB(FORMAT, ...)     printf(FORMAT, __VA_ARGS__)
    #define     LXGLDC(CODE)            CODE
#else
    #define     LXGLDB(FORMAT, ...)
    #define     LXGLDC(CODE)
#endif
//  ............................................................................
//  FOLDING
#ifdef      LXG_DEBUG_FOLDING
    #define     LXGFDB(FORMAT, ...)     printf(FORMAT, __VA_ARGS__)
    #define     LXGFDC(CODE)            CODE
#else
    #define     LXGFDB(FORMAT, ...)
    #define     LXGFDC(CODE)
#endif
//  ............................................................................
//  LIBLEXEREXT
#ifdef      LXG_DEBUG_LLG
    #define     LXG_LLG_DBG(FORMAT, ...)     printf("LexerExt::liblexerext::" FORMAT, __VA_ARGS__)
    #define     LXG_LLG_DBC(CODE)            CODE
#else
    #define     LXG_LLG_DBG(FORMAT, ...)
    #define     LXG_LLG_DBC(CODE)
#endif
//  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  For cross-referencing, declare all classes
class   LexerExt;
class   LexerGas_i386;
class   LexerGas_arm;
class   DynamicLibraryImpl;
