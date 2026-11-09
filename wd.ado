*! wd - open a webdoc stlog section (close it with wdclose)
*! 2026-11-09 (webdoc2 1.1.5): -webdoc do- applies nooutput, nodo, cmdlog and
*!   dosave only to literal "webdoc stlog" lines it finds when it scans the
*!   do-file (it inserts -set output inform- and friends around them). It
*!   never sees wd, so wd, nooutput used to publish the output it was asked
*!   to hide. A program cannot do the same itself: Stata restores -set
*!   output- when the program that set it ends. wd now rejects those options
*!   (and a nooutput default set on wdinit/webdoc init) with r(198).
*cap program drop wd
program define  wd
version 14
syntax [anything] [, *]
local passopts `"`macval(options)'"'
local 0 `", `macval(options)'"'
syntax [, NOOutput Output NODO CMDLog DOSave *]
local bad = trim("`nooutput' `nodo' `cmdlog' `dosave'")
if "`bad'" != "" {
    di as err "wd: option `bad' is not available through wd; -webdoc do- applies it only"
    di as err "    to literal webdoc stlog lines. Write -webdoc stlog, `bad'- and"
    di as err "    -webdoc stlog close- around this section instead."
    exit 198
}
if `"${WebDoc_nooutput}"' != "" & "`output'" == "" {
    di as err "wd: the document was initialized with nooutput, which wd cannot apply."
    di as err "    Use -webdoc stlog- for sections whose output must stay hidden,"
    di as err "    or specify wd, output to show this section's output."
    exit 198
}
webdoc stlog `anything', `macval(passopts)'
end
