*! wditem - Insert one list item. Use inside any wdlist/wditemize/wdenumerate
*!          block (closed by wdlistend). Accepts free-form text including commas.
*cap program drop wditem
program define wditem
local text `0'
webdoc put <li>`text'</li>
end
