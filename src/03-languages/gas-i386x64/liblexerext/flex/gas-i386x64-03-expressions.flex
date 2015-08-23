                                                                                /*
    ============================================================================
                    FLEX REMARKS
    ============================================================================
    Notes :
    * Do not use name definitions ( {name} ) in character classes ( [] )
    * Regexps explanations:
        lstringdq       {dquote}(\\.|[^\"\n])*{dquote}
        \\.     for escaped characters within a string ex. "ABCD\"EFGH"
    ============================================================================
                    FOLLOWING IS FOR GAS version 2.25

    Remarks :

        - Octal numbers as constants are chars from [0-7], but escaped inside a
          string they are chars from [0-9]

    ============================================================================
    Notations:
        N   [0-9]
        n   [1-9]
        D   [n1][N+]
        B   C-B
        A   C-A
        V   [a-z0-9]
        I   [A-Za-Z0-9]
        i   [A-Za-z]
        S   [A-Za-z0-9_.$]
        s   [A-Za-z_.$]
    ----------------------------------------------------------------------------
    Symbols:
        Non-Local
            Usr                                 [wS]                            1
        Local
            Usr                                 [L1][wS]                        2

    Labels:
        Non-Local
            Usr                                 [wS][:1]                        3
        Local
            Gas                                 [L1][D1][B1][D1][:1]            4
            Gas Dollar                          [L1][D1][A1][D1][:1]            5
            Gas Undocumented-A                  [L1][D1][:1]                    13
            Usr Standard                        [L1][wS][:1]                    6
            Usr Numeric
            Usr     Declaration                 [D1][:1]                        7
            Usr     Reference                   [D1][b1] / [D1][f1]             8

    Directives:
        Gas                                     [.1][V+]                        9

    Instructions:
        Inst                                    [wI]                            10
        Inst   + Suffix / Prefix + Inst         [wI] [wI]                       11
        Prefix + Inst + Suffix                  [wI] [wI] [wI]                  12

    Comments:
        * Any '#' in the line
        * C-style multiline comment
        * If the --divide command line option has not been specified then the [/]
          character appearing anywhere on a line also introduces a line comment.

    Notes:
        * C-A and C-B exist for avoiding collisions between usr local symbols.
        * Two ways of differentiating (1) and (9) :
          - dictionnary of directives
          - scan for a [:] after the word
    ============================================================================
                                SYNTHESIS
    ============================================================================
    Statement parsing:

    ----------------------------------------------------------------------------
    INITIAL ( I1 )
    ----------------------------------------------------------------------------
    Get rid of [L1], and set a flag L. After that we have :

    Symbols:
        Non-Local
            Usr                                 [wS]                            1
        Local
            Usr                                 [wS]                            2   L

    Labels:
        Non-Local
            Usr                                 [wS][:1]                        3
        Local
            Gas                                 [D1][B1][D1][:1]                4   L
            Gas Dollar                          [D1][A1][D1][:1]                5   L
            Gas Undocumented-A                  [L1][D1][:1]                    13  L
            Usr Standard                        [wS][:1]                        6   L
            Usr Numeric
            Usr     Declaration                 [D1][:1]                        7

    Directives:
        Gas                                     [.1][V+]                        9

    Instructions:
        Inst                                    [wI]                            10
        Inst   + Suffix / Prefix + Inst         [wI] [wI]                       11
        Prefix + Inst + Suffix                  [wI] [wI] [wI]                  12
    ----------------------------------------------------------------------------
    I2
    ----------------------------------------------------------------------------
    * [wI], [V] are subsets of [wS]. So it is simplier to recognize a [wS] and
    work on yytext, settings dome flags :
        - D ( first char is dot )
    rather that defining specific flex states
    * 4, 5, 7 can be resolved easyly inside I2.

    After that we have :

    Symbols:                                                                        Flags
        Non-Local
            Usr                                 [wS]                            1       (D)
        Local
            Usr                                 [wS]                            2   L

    Labels:
        Non-Local
            Usr                                 [wS][:1]                        3       (D)
        Local
            Usr Standard                        [wS][:1]                        6   L   (D)

    Directives:
        Gas                                     [.1][V+]                        9       D

    Instructions:
        Inst                                    [wI]                            10
        Inst   + Suffix / Prefix + Inst         [wI] [wI]                       11
        Prefix + Inst + Suffix                  [wI] [wI] [wI]                  12
    ----------------------------------------------------------------------------
    I3
    ----------------------------------------------------------------------------
    Following next chars :
      - If immediate next char is [:]           ->  R(3 ,6)                 with L
      - If we get [ *][=] , symbol affectation  ->  R(1, 2)                 with L
      - If we get [ *], goto state I4 ( so we can count the number of spaces )

    After that we have :
                                                                                    Flags

    Directives:
        Gas                                     [.1][V+]                        9       D

    Instructions:
        Inst                                    [wI]                            10
        Inst   + Suffix / Prefix + Inst         [wI] [wI]                       11
        Prefix + Inst + Suffix                  [wI] [wI] [wI]                  12
    ----------------------------------------------------------------------------
    I4
    ----------------------------------------------------------------------------
    Easyly resloving of 9, 10, 11, 12
    ----------------------------------------------------------------------------
    INSTRUCTION
    ----------------------------------------------------------------------------
    Operands:

    Register:       %rax

    Immediate:      $0x16
                    movb $0x05, %al

    Memory:         displacement(base register, offset register, scalar multiplier)
                    movl    -4(%ebp, %edx, 4), %eax  # Full example: load *(ebp - 4 + (edx * 4)) into eax
                    movl    -4(%ebp), %eax           # Typical example: load a stack variable into eax
                    movl    (%ecx), %edx             # No offset: copy the target of a pointer into a register
                    leal    8(,%eax,4), %eax         # Arithmetic: multiply eax by 4 and add 8
                    leal    (%eax,%eax,2), %eax      # Arithmetic: multiply eax by 2 and add eax (i.e. multiply by 3)

    Numerical constants :

      - A binary integer is `0b' or `0B' followed by zero or more of the binary digits `01'.
      - An octal integer is `0' followed by zero or more of the octal digits (`01234567').
      - A decimal integer starts with a non-zero digit followed by zero or more digits (`0123456789').
      - A hexadecimal integer is `0x' or `0X' followed by one or more hexadecimal digits chosen from `0123456789abcdefABCDEF'.
      - Integers have the usual values. To denote a negative integer, use the prefix operator `-' discussed under expressions
    ============================================================================
                                                                                */

    //  ------------------------------------------------------------------------
    //  Numerical constants
    //  ------------------------------------------------------------------------
cNDec           [0-9]
cNdec           [1-9]
cNHex           [A-Fa-f0-9]
cNOct           [0-7]

    //  ------------------------------------------------------------------------

wNDecP          {cNdec}{cNDec}*
wNDecN          -{cNdec}{cNDec}*
wNDec           {wNDecN}|{wNDecP}

wNHex1          0x{cNHex}+
wNHex2          0X{cNHex}+
wNHex           {wNHex1}|{wNHex2}

wNBin1          0b[01]+
wNBin2          0B[01]+
wNBin           {wNBin1}|{wNBin2}

wNOct           0{cNOct}+

wNCst           {wNDec}|{wNHex}|{wNBin}|{wNOct}
    //  ------------------------------------------------------------------------
    //  Others
    //  ------------------------------------------------------------------------
nl              \n

cWsp            [ \t]

cLp             \(
cRp             \)
cComma          ,

cL              L
ca              C-A
cb              C-B

cS              [A-Za-z0-9_\\.$@]
cs              [A-Za-z_.$]

cI              [A-Za-z0-9]
ci              [A-Za-z]

cCol            :
cEqu            =
cDot            \.

cCtrlA          C-a
cCtrlB          C-b

    //  ------------------------------------------------------------------------

wS              {cs}{cS}*

wXste           ;

wLoc            {cDot}{cL}

wInst           {ci}{cI}+

wCtrlA          C-a
wCtrlB          C-b
    //  ------------------------------------------------------------------------
    //  Operands specific
    //  ------------------------------------------------------------------------
cReg            [A-Za-z0-9]
    //  ------------------------------------------------------------------------

wOPNCst         {wNCst}
wOPImm          ${wNCst}
wOPReg          %{cReg}+
    //  ------------------------------------------------------------------------
    //  Directive specific
    //      - no need to escape the '"' here, but in the rule yes
    //  ------------------------------------------------------------------------
cDIRTok         [^ "\n\t]
    //  ------------------------------------------------------------------------

wDIRTok         {cDIRTok}+
    //  ------------------------------------------------------------------------
    //  String specific
    //
    //  A string is written between double-quotes. It may contain double-quotes
    //  or null characters. The way to get special characters into a string is
    //  to escape these characters: precede them with a backslash `\' character.
    //      \b  Mnemonic for backspace; for ASCII this is octal code 010.
    //      \f  Mnemonic for FormFeed; for ASCII this is octal code 014.
    //      \n  Mnemonic for newline; for ASCII this is octal code 012.
    //      \r  Mnemonic for carriage-Return; for ASCII this is octal code 015.
    //      \t  Mnemonic for horizontal Tab; for ASCII this is octal code 011.
    //      \ digit digit digit
    //          An octal character code. The numeric code is 3 octal digits. For compatibility with other Unix systems, 8 and 9 are accepted as digits: for example, \008 has the value 010, and \009 the value 011.
    //      \x hex-digits...
    //          A hex character code. All trailing hex digits are combined.
    //          Either upper or lower case x works.
    //      \\  Represents one `\' character.
    //      \"  Represents one `"' character. Needed in strings to represent
    //          this character, because an unescaped `"' would end the string.
    //      \ anything-else
    //          Any other character when escaped by \ gives a warning,
    //          but assembles as if the `\' was not present. The idea is that
    //          if you used an escape sequence you clearly didn't want the
    //          literal interpretation of the following character.
    //          However as has no other interpretation, so as knows it is giving
    //          you the wrong code and warns you of the fact.
    //  Which characters are escapable, and what those escapes represent, varies
    //  widely among assemblers. The current set is what we think the BSD 4.2
    //  assembler recognizes, and is a subset of what most C compilers recognize.
    //  If you are in doubt, do not use an escape sequence.
    //
    //  _GWR_TODO_  multiline strings allowed ???
    //  ------------------------------------------------------------------------
    //  ------------------------------------------------------------------------
wSTREsc01   \\b
wSTREsc02   \\f
wSTREsc03   \\n
wSTREsc04   \\r
wSTREsc05   \\t
wSTREsc06   \\[0-9][0-9][0-9]
wSTREsc07   \\x[A-Fa-f0-9]+
wSTREsc08   \\\\
wSTREsc09   \\["]

wSTREsc     {wSTREsc01}|{wSTREsc02}|{wSTREsc03}|{wSTREsc04}|{wSTREsc05}|{wSTREsc06}|{wSTREsc07}|{wSTREsc08}|{wSTREsc09}
    //  ------------------------------------------------------------------------
    //  COMMENTs specific
    //  ------------------------------------------------------------------------
cCMTMLb         \*
cCMTMLbx        [^\*\n]
    //  ------------------------------------------------------------------------
wCMTSL1         #
wCMTSL2         ##
wCMTSL3         ###

wCMTMLa         \x2f\x2a
wCMTMLb         \x2a\x2f
