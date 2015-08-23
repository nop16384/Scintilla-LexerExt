//  ############################################################################
//  § LexExt-02-options.cci
//  ############################################################################
static const char * const extWordListDesc[] =
{
	"instruction prefix"        ,
	"instruction suffix"        ,
	"CPU instruction"           ,
	"FPU instructions"          ,
	"Extended instructions"     ,
	"--- free ---"              ,
	"--- free ---"              ,
	"Registers"                 ,
	"Directives"                ,
    0
};

class   OptionsExt
{
    public:
    std::string language;
    bool        fold_extra;
    std::string fold_extra_start;
    std::string fold_extra_end;

    std::string comment1_mark;
    std::string comment2_mark;
    std::string comment3_mark;

	OptionsExt(
        std::string     _language           ,
        bool            _fold_extra         ,
        std::string     _fold_extra_start   ,
        std::string     _fold_extra_end     ,
        std::string     _comment1_mark      ,
        std::string     _comment2_mark      ,
        std::string     _comment3_mark      )
        :   language        ( _language         )   ,
            fold_extra      ( _fold_extra       )   ,
            fold_extra_start( _fold_extra_start )   ,
            fold_extra_end  ( _fold_extra_end   )   ,
            comment1_mark   ( _comment1_mark    )   ,
            comment2_mark   ( _comment2_mark    )   ,
            comment3_mark   ( _comment3_mark    )
    {
	}
};

struct OptionSetExt : public OptionSet<OptionsExt>
{
	OptionSetExt()
    {
		DefineProperty("lexer.ext.language", &OptionsExt::language,
			"This option specify the language to use");

		DefineProperty("fold.ext.extra", &OptionsExt::fold_extra,
			"This option enables extra folding when using the ext lexer. "
			"Extra folding is done by inserting special strings in the code.");

		DefineProperty("fold.ext.extra.start", &OptionsExt::fold_extra_start,
			"The string to use for explicit fold start points, replacing the standard.");

		DefineProperty("fold.ext.extra.end", &OptionsExt::fold_extra_end,
			"The string to use for explicit fold end points, replacing the standard.");
        //  ....................................................................
		DefineProperty("fold.ext.comment.mark.1", &OptionsExt::comment1_mark,
			"The string to use for starting a block comment.");

		DefineProperty("fold.ext.comment.mark.2", &OptionsExt::comment2_mark,
			"Alternate string to use for starting a block comment.");

		DefineProperty("fold.ext.comment.mark.3", &OptionsExt::comment3_mark,
			"Alternate string to use for starting a block comment.");
        //  ....................................................................
		DefineWordListSets(extWordListDesc);
	}
};

