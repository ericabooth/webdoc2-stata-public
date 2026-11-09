*! wdnavitem - Add one nav link inside a wdnavbar block
*cap program drop wdnavitem
program define wdnavitem
version 14
syntax [anything(equalok everything)] [, Href(string) Active]
* 1.1.6: strip outer quotes (a quoted label kept them in the HTML)
local anything `anything'
if "`active'" != "" {
    webdoc put <li class="nav-item"><a class="nav-link active" aria-current="page" href="`href'">`anything'</a></li>
}
else {
    webdoc put <li class="nav-item"><a class="nav-link" href="`href'">`anything'</a></li>
}
end
