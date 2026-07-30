*! Custom webdoc2 :  version 1.1.3 20260523 Eric Booth
*!
*! Note: Custom subcommands include:
*!       wd and  wdclose
*!       button and  buttonclose
*!       graphbutton  and  graphbuttonclose
*! 	    wput , h1put, ... h3put
*!       wdnavbar  wdnavitem  wdnavbarclose  wdnavdropdown  wdnavdropdownitem  wdnavdropdownclose
*!       wdtoc  wdwidth
*!       wdinit



**main program goes last so that others get recognized as subroutines!
 program  webdoc2, rclass
version 14
* open:    open the output HTML in the default browser after building
* cleanup: delete intermediate .log/.smcl files after building (PNG graphs kept)
syntax [anything] [, open Cleanup *]
loc o `"`=subinstr(`"`options'"', "replace", "", .)'"'
* Strip any outer double-quotes that syntax preserves (handles quoted paths)
local anything `anything'
global anythingi `"`anything'"'
*quietly run  `"webdoc2subs.ado"', nostop //loads all the sub routines into memory
*********
if `"${anythingi}"' == "help" {
	which webdoc2
	program list
	help webdoc2
	exit 198
}

webdoc do `"${anythingi}"'  , replace `o'

* Derive HTML filename: replace .do→.html; if no .do present, append .html
* (Used only as fallback when wdinit did not set $webdoc2htmlpath)
loc anything2: subinstr local anything ".do" ".html"
if `"`anything2'"' == `"`anything'"' {
    local anything2 `"`anything'.html"'
}
cap webdoc close

* Prefer the path wdinit communicated (absolute, correct even when the
* do-file lives in a different directory than Stata's CWD).
if `"${webdoc2htmlpath}"' != "" {
    local htmlpath "${webdoc2htmlpath}"
    global webdoc2htmlpath ""
}
else {
    local htmlpath `"`anything2'"'
}
webdoc2findreplace `"`htmlpath'"'

* ── Optional cleanup: delete intermediate .log / .smcl files ──────────────
* The HTML embeds stlog content inline, so the per-block log files are NOT
* referenced after build. PNG/JPG/SVG graphs ARE referenced and stay.
if "`cleanup'" != "" {
    local stem `"`htmlpath'"'
    if substr(`"`stem'"', -5, .) == ".html" {
        local stem = substr(`"`stem'"', 1, strlen(`"`stem'"') - 5)
    }
    local nremoved = 0
    cap erase `"`stem'.log"'
    if !_rc local ++nremoved
    cap erase `"`stem'.smcl"'
    if !_rc local ++nremoved
    forvalues i = 1/500 {
        cap erase `"`stem'_`i'.log"'
        if !_rc local ++nremoved
        cap erase `"`stem'_`i'.smcl"'
        if !_rc local ++nremoved
    }
    di as txt "webdoc2 cleanup: removed `nremoved' intermediate .log/.smcl file(s) (PNG/JPG graphs kept)."
}

* ── Open in default browser if requested ──────────────────────────────────
* Writes a tiny shell script via `file write`, then invokes it via `shell sh`.
* No Stata compound-quote delimiters (which would emit a literal backtick)
* are ever passed to the shell, so this avoids the "zsh: unmatched `" error.
if "`open'" != "" {
    di as txt `"Opening: `htmlpath'"'
    cap file close _wd2_fh
    tempfile _wd2_sh
    if ("`c(os)'" == "MacOSX") | regexm("`c(machine_type)'", "Mac") {     // Apple-Silicon Stata reports c(os)=="Unix"
        cap file open _wd2_fh using "`_wd2_sh'", write text replace
        if !_rc {
            file write _wd2_fh "/usr/bin/open " _char(34) `"`htmlpath'"' _char(34) _n
            cap file close _wd2_fh
            shell sh "`_wd2_sh'"
        }
    }
    else if "`c(os)'" == "Windows" {
        cap file open _wd2_fh using "`_wd2_sh'.cmd", write text replace
        if !_rc {
            file write _wd2_fh "start " _char(34) _char(34) " " _char(34) `"`htmlpath'"' _char(34) _n
            cap file close _wd2_fh
            shell "`_wd2_sh'.cmd"
        }
    }
    else {
        cap file open _wd2_fh using "`_wd2_sh'", write text replace
        if !_rc {
            file write _wd2_fh "xdg-open " _char(34) `"`htmlpath'"' _char(34) _n
            cap file close _wd2_fh
            shell sh "`_wd2_sh'"
        }
    }
}

 di as txt `"For error checking:"'
 di as smcl `"View subprogram list (loaded in memory): {stata program list}"'

end


*cap program drop webdoc2findreplace
program def webdoc2findreplace
syntax [anything]
local fn `anything'
di as smcl `"Reopen: {browse "`fn'"}"'

* Strip closing-command echoes from the HTML on disk.
* Targets ONLY <span class="stinp">.<ws>cmd<ws></span> patterns so legitimate
* mentions of the command names (e.g., in help-text <p> tags) survive.
* The JS in header.html does the same in the browser; this complements it
* so the saved-to-disk file is also clean.

cap file close _wd2_in
cap file close _wd2_out

tempfile _wd2_tmp
cap file open _wd2_in using `"`fn'"', read text
if _rc {
    di as txt `"webdoc2findreplace: cannot read `fn' — JS in header.html will still clean browser display"'
    exit
}
cap file open _wd2_out using `"`_wd2_tmp'"', write text replace
if _rc {
    cap file close _wd2_in
    di as txt `"webdoc2findreplace: cannot write tempfile — JS in header.html will still clean browser display"'
    exit
}

local q = char(34)
local pat `"<span class=`q'stinp`q'>\.\s*(wdclose|buttonclose|graphbuttonclose|wdnavbarclose|wdnavdropdownclose)\s*</span>"'

file read _wd2_in line
while r(eof) == 0 {
    local newline = ustrregexra(`"`macval(line)'"', `"`pat'"', "")
    file write _wd2_out `"`macval(newline)'"' _n
    file read _wd2_in line
}
cap file close _wd2_in
cap file close _wd2_out

cap copy `"`_wd2_tmp'"' `"`fn'"', replace
if _rc {
    di as txt `"webdoc2findreplace: could not overwrite `fn' — JS in header.html will still clean browser display"'
}
end
