*! wdnavdropdownitem - Add one item to a wdnavdropdown menu
*!   Usage: wdnavdropdownitem [label] [, href(url)]
*cap program drop wdnavdropdownitem
program define wdnavdropdownitem
version 14
syntax [anything(equalok everything)] [, Href(string)]
local anything = `"`anything'"'
webdoc put <li><a class="dropdown-item" href="`href'">`anything'</a></li>
end
