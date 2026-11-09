*! wdimg - Insert an image, optionally with a caption.
*! 2026-11-09 (webdoc2 1.1.5): width() and alt() reach the HTML again.
*!
*!         Usage:  wdimg {it:path} [, width() alt() caption()]
*!         or:     wdimg, src({it:path}) [...]
*!
*!         Without caption(): emits a plain <img> sized to fit the page width.
*!         With caption():    wraps the image in <figure>/<figcaption> for
*!                            styled rendering via header.html's figure CSS.
*cap program drop wdimg
program define wdimg
version 14
syntax [anything(equalok everything)] [, SRC(string) Width(string) Alt(string) Caption(string)]

* Strip any outer double-quotes the user typed around the positional arg.
* `syntax [anything]` preserves outer quotes literally, which would otherwise
* produce a malformed `src=""path""` attribute when embedded in the HTML.
local anything `anything'

if `"`src'"' == "" local src `"`anything'"'
if `"`src'"' == "" {
    di as err "wdimg: must specify an image path or URL (as the first argument or via src())"
    exit 198
}

* Build the attribute fragments with compound quotes and char(34). A bare
* opening backtick (` width="...") is read as a reference to a macro named
* ' width="..."', which expands to nothing, so width() and alt() were dropped
* silently before webdoc2 1.1.5.
local q = char(34)
local widthpart ""
if `"`width'"' != "" local widthpart `" width=`q'`macval(width)'`q'"'

local altpart ""
if `"`alt'"' != "" local altpart `" alt=`q'`macval(alt)'`q'"'

if `"`caption'"' != "" {
    webdoc put <figure>
    webdoc put <img src="`src'"`widthpart'`altpart'>
    webdoc put <figcaption>`caption'</figcaption>
    webdoc put </figure>
}
else {
    webdoc put <img src="`src'"`widthpart'`altpart' style="max-width:100%; height:auto; border-radius:6px;">
}
end
