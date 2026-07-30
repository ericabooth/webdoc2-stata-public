*! wputh2 - Insert an <h2> with an auto-generated id slug for anchor navigation.
*!          Slug rule: lowercase, runs of non-alphanumeric chars → "-", trimmed.
*cap program drop wputh2
program define wputh2
version 14
local text `0'

local id = lower(`"`text'"')
local id = ustrregexra(`"`id'"', "[^a-z0-9]+", "-")
local id = ustrregexra(`"`id'"', "^-+|-+$", "")
if `"`id'"' == "" local id "section"

webdoc put <h2 id="`id'">`text'</h2>
end
