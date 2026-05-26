*! wdiframe - Embed an <iframe> (Sparkta dashboards, external pages, sub-reports)
*!            without writing HTML by hand.
*!
*!            Usage:  wdiframe {it:src} [, width() height() class() border]
*!            or:     wdiframe, src({it:src}) [...]
*!
*!            Defaults: width=100%, height=800px, no visible border, subtle
*!            rounded corners + drop shadow + vertical margin.
*cap program drop wdiframe
program define wdiframe
syntax [anything(equalok everything)] [, SRC(string) Width(string) ///
        Height(string) Class(string) Border]

* Strip any outer double-quotes the user typed around the positional arg.
* `syntax [anything]` preserves outer quotes literally, which would otherwise
* produce a malformed `src=""path""` attribute when embedded in the HTML.
local anything `anything'

if `"`src'"' == "" local src `"`anything'"'
if `"`src'"' == "" {
    di as err "wdiframe: must specify a source URL or file path (as the first argument or via src())"
    exit 198
}

if "`width'"  == "" local width  "100%"
if "`height'" == "" local height "800px"

local q = char(34)
local classpart ""
if `"`class'"' != "" local classpart `" class=`q'`class'`q'"'

local borderstyle "border:none;"
if "`border'" != "" local borderstyle "border:1px solid #dee2e6;"

webdoc put <iframe src="`src'" width="`width'" height="`height'" frameborder="0"`classpart' style="`borderstyle' border-radius:8px; box-shadow:0 2px 10px rgba(0,0,0,0.06); margin:1rem 0;"></iframe>
end
