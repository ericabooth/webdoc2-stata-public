*! wdnavdropdown - Open a Bootstrap 5 dropdown menu inside a navbar
*!   Usage: wdnavdropdown [label] [, id(string)]
*!   Place between wdnavbar and wdnavbarclose, then add wdnavdropdownitem lines,
*!   then close with wdnavdropdownclose.
*cap program drop wdnavdropdown
program define wdnavdropdown
syntax [anything(equalok everything)] [, Id(string)]
local anything = `"`anything'"'
if `"`anything'"' == "" local anything "Contents"
if "${tttt2}"    == "" global tttt2 = 0
global tttt2 = ${tttt2} + 1
if "`id'" == "" local id "wdNavDD${tttt2}"
webdoc put <li class="nav-item dropdown">
webdoc put <a class="nav-link dropdown-toggle" href="#" id="`id'" role="button" data-bs-toggle="dropdown" aria-expanded="false">`anything'</a>
webdoc put <ul class="dropdown-menu" aria-labelledby="`id'">
end
