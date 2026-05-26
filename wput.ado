*********! webdoc put


*cap program drop wput
program define  wput
* Bypass syntax entirely so unquoted commas are allowed.
* local text `0' also strips any outer double-quotes the user may have added.
local text `0'
webdoc put <p>`text'</p>
end
