*! wputh3 - Insert an <h3> with an auto-generated id slug for anchor navigation.
*!          Slug rule: lowercase, runs of non-alphanumeric chars → "-", trimmed.
*cap program drop wputh3
program define wputh3
version 14
local text `0'

local id = lower(`"`text'"')
local id = ustrregexra(`"`id'"', "[^a-z0-9]+", "-")
local id = ustrregexra(`"`id'"', "^-+|-+$", "")
if `"`id'"' == "" local id "section"

webdoc put <h3 id="`id'">`text'</h3>
end
