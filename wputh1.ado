*! wputh1 - Insert an <h1> with an auto-generated id slug for anchor navigation.
*!          Slug rule: lowercase, runs of non-alphanumeric chars → "-", trimmed.
*!          Examples:  "Home"             → id="home"
*!                     "Summary Stats"    → id="summary-stats"
*!                     "R & D Notes"      → id="r-d-notes"
*!          To use a custom id, write the <h1> yourself with webdoc put.
*cap program drop wputh1
program define wputh1
version 14
local text `0'

* Slugify the heading text into an id.
local id = lower(`"`text'"')
local id = ustrregexra(`"`id'"', "[^a-z0-9]+", "-")
local id = ustrregexra(`"`id'"', "^-+|-+$", "")
if `"`id'"' == "" local id "section"

webdoc put <h1 id="`id'">`text'</h1>
end
