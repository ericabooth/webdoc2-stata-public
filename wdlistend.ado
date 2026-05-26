*! wdlistend - Close the list opened by wdlist (emits </ul> or </ol>).
*cap program drop wdlistend
program define wdlistend
syntax
local tag "${wdlist_tag}"
if "`tag'" == "" local tag "ul"
webdoc put </`tag'>
global wdlist_tag ""
end
