*! wdtoc - Insert an auto-generated in-page table of contents.
*!         JavaScript in header.html fills this container with heading links.
*!
*!         Usage:  wdtoc [title text] [, id(string) center indent(spec) depth(N)]
*!
*!         Options:
*!           id(string)    DOM id for the TOC container (default "wd-toc")
*!           center        center the TOC horizontally on the page
*!           indent(spec)  left margin (e.g., 2em, 40px, 5%)
*!           depth(N)      heading levels to include, 1-6 (default 3 = h1+h2+h3)
*cap program drop wdtoc
program define wdtoc
syntax [anything(equalok everything)] [, Id(string) Center Indent(string) Depth(integer 3)]

local anything = `"`anything'"'
if "`id'"         == "" local id       "wd-toc"
if `"`anything'"' == "" local anything "Contents"

* Clamp depth to 1..6.
if `depth' < 1 local depth 1
if `depth' > 6 local depth 6

local q = char(34)

* Build inline style for indent (margin-left).
local styleattr ""
if `"`indent'"' != "" {
    local styleattr `" style=`q'margin-left:`indent';`q'"'
}

* Compose the TOC element.
local toc `"<div id=`q'`id'`q' class=`q'wd-toc-wrap`q' data-wd-depth=`q'`depth'`q'`styleattr'><strong class=`q'wd-toc-title`q'>`anything'</strong></div>"'

* Wrap in a centering container when `center' was passed.
if "`center'" != "" {
    webdoc put <div style="text-align:center;">`toc'</div>
}
else {
    webdoc put `toc'
}
end
