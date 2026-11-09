*! wdnavdropdownitem - Add one item to a wdnavdropdown menu
*!   Usage: wdnavdropdownitem [label] [, href(url)]
*cap program drop wdnavdropdownitem
program define wdnavdropdownitem
version 14
syntax [anything(equalok everything)] [, Href(string)]
* 1.1.6: strip outer quotes (a quoted label kept them in the HTML)
local anything `anything'
webdoc put <li><a class="dropdown-item" href="`href'">`anything'</a></li>
end
