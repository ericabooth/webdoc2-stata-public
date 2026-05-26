*! wdwidth - Set or change the page content width
*!           Writes a <style> block overriding --wd-page-width.
*!           Usage:  wdwidth 80%   (any valid CSS width: %, px, vw, etc.)
*!                   wdwidth       (resets to default 90%)
*cap program drop wdwidth
program define wdwidth
syntax [anything(equalok everything)]
local anything = `"`anything'"'
if `"`anything'"' == "" local anything "90%"
webdoc put <style>:root { --wd-page-width: `anything'; }</style>
end
