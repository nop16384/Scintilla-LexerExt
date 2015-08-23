//  ############################################################################
//  § LexExt-07-post.cci
//  ############################################################################
std::list < LexerExt::LibLexerExt::SharedLibrary* >    LexerExt::LibLexerExt::s_shared_libraries;

ILexer*
LexerExt::LexerFactory_ext__gas_i386x64()
{
    printf("LexerFactory_ext__gas_i386x64\n");
    return new LexerExt("ext__gas_i386x64");
}
ILexer*
LexerExt::LexerFactory_ext__gas_arm_generic()
{
    printf("LexerFactory_ext__gas_arm_generic\n");
    return new LexerExt("ext__gas_arm_generic");
}
ILexer*
LexerExt::LexerFactoryExt()
{
    printf("LexerFactoryExt\n");
    return new LexerExt();
}


//  ----------------------------------------------------------------------------
//  wether the build is done for scite / codeblocks, tag SCITE_OR_CODEBLOCKS...
//  is replaced by the good lexer module(s)
//  - scite linkage : many lexer modules
//    lm_ext__LANGUAGE(SCLEX_EXT, LexerExt::LexerFactory_ext__LANGUAGE, "ext__LANGUAGE", extWordListDesc);
//  - codeblocks linkage : one lexer module
//    lmExt(SCLEX_EXT, LexerExt::LexerFactoryExt, "ext", extWordListDesc);

SCITE_OR_CODEBLOCKS_MODULE_LINKAGE
