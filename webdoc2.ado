*! Custom webdoc2 :  version 1.1.6 20261109 Eric Booth
*!
*! Note: Custom subcommands include:
*!       wd and  wdclose
*!       button and  buttonclose
*!       graphbutton  and  graphbuttonclose
*! 	    wput , h1put, ... h3put
*!       wdnavbar  wdnavitem  wdnavbarclose  wdnavdropdown  wdnavdropdownitem  wdnavdropdownclose
*!       wdtoc  wdwidth
*!       wdinit
*! 1.1.6: replace is parsed as an option, not deleted as a substring (grdir()
*!   and other arguments containing "replace" survive); webdoc2 help returns
*!   0; a report next to a do-file run from another folder is no longer
*!   emptied and deleted; cleanup removes only webdoc's numbered stlog files;
*!   the closing-command scrub runs in Mata and cannot fail the build; open
*!   uses the absolute path, expands ~, and quotes the path for the shell.



**main program goes last so that others get recognized as subroutines!
 program  webdoc2, rclass
version 14
* open:    open the output HTML in the default browser after building
* cleanup: delete intermediate .log/.smcl files after building (PNG graphs kept)
* Replace is parsed here because webdoc do always gets replace (see below);
* before 1.1.6 the word was deleted from the option string with subinstr(),
* which also cut it out of arguments such as grdir(replacefigs).
syntax [anything] [, open Cleanup Replace LOGALL *]
* logall makes -webdoc do- wrap every command it does not recognise as a
* webdoc command in its own stlog. wdinit, wput and the other webdoc2
* commands are not recognised, so wdinit landed inside a log section and
* every build stopped with r(499) "webdoc init not allowed within stlog".
if "`logall'" != "" {
    di as err "webdoc2: option logall is not supported; webdoc's logall wraps"
    di as err "         wdinit and the other webdoc2 commands in stlog sections."
    di as err "         Use wd/wdclose (or webdoc stlog) around the output to show."
    exit 198
}
local o `"`macval(options)'"'
* Strip any outer double-quotes that syntax preserves (handles quoted paths)
local anything `anything'
*********
if `"`anything'"' == "help" {
    * Environment check, then the help file. Returns 0 so a do-file that
    * calls it keeps running (before 1.1.6 it listed every program in memory
    * and ended with r(198)).
    which webdoc2
    capture noisily which webdoc
    if _rc {
        di as err "webdoc2 needs Ben Jann's webdoc: ssc install webdoc"
    }
    capture findfile header.html
    if _rc == 0 {
        di as txt `"header.html: `r(fn)'"'
    }
    else {
        capture findfile _webdoc2_header.ado
        if _rc == 0 {
            di as txt "header.html: not found; wdinit uses the built-in header"
        }
        else {
            di as err "header.html and _webdoc2_header.ado not found; reinstall webdoc2"
        }
    }
    help webdoc2
    exit
}

* -webdoc do- opens <dofile>.html next to the do-file before the do-file runs
* (its automatic init; wdinit is invisible to it), and because webdoc2 passes
* replace that file is truncated. When the report has another name, wdinit
* then removes the empty file. If the do-file is run from another folder and
* a report from an earlier build in the do-file's own folder sits at that
* path, the report was destroyed. Keep a copy and put it back afterwards.
mata: st_local("dofile", st_local("anything") + (pathsuffix(st_local("anything")) == "" ? ".do" : ""))
mata: st_local("autodoc", pathrmsuffix(pathisabs(st_local("dofile")) ? st_local("dofile") : pathjoin(pwd(), st_local("dofile"))) + ".html")
local autobak ""
capture quietly checksum `"`autodoc'"'
if _rc == 0 {
    if r(filelen) > 0 {
        tempfile autobak
        quietly copy `"`autodoc'"' `"`autobak'"'
    }
}

global webdoc2htmlpath ""
* wdinit reads this to skip its rerun warning: webdoc2 always passes replace.
global webdoc2_running 1
capture noisily webdoc do `"`anything'"', replace `macval(o)'
local rc = _rc
global webdoc2_running ""
cap webdoc close

* wdinit communicates the absolute document path (webdoc's own
* ${WebDoc_docname}); without wdinit, webdoc wrote the automatic document.
local htmlpath `"${webdoc2htmlpath}"'
global webdoc2htmlpath ""
if `"`htmlpath'"' == "" local htmlpath `"`autodoc'"'
* Expand a leading ~ (pathisabs() accepts it, so webdoc keeps it as typed)
if substr(`"`htmlpath'"', 1, 2) == "~/" {
    local home : env HOME
    if `"`home'"' == "" local home : env USERPROFILE
    if `"`home'"' != "" local htmlpath `"`home'`=substr(`"`htmlpath'"', 2, .)'"'
}

* Put back a report that the automatic init emptied, unless it was the target
if `"`autobak'"' != "" & `"`htmlpath'"' != `"`autodoc'"' {
    local autolen 0
    capture quietly checksum `"`autodoc'"'
    if _rc == 0 local autolen = r(filelen)
    if `autolen' == 0 {
        quietly copy `"`autobak'"' `"`autodoc'"', replace
        di as txt `"(webdoc2: restored `autodoc', which webdoc's automatic init had emptied)"'
    }
}
if `rc' exit `rc'

webdoc2findreplace `"`htmlpath'"'

* ── Optional cleanup: delete intermediate .log / .smcl files ──────────────
* The HTML embeds stlog content inline, so the per-block log files are NOT
* referenced after build. PNG/JPG/SVG graphs ARE referenced and stay.
* webdoc names them <stem>_1.log, <stem>_2.log, ...; it never writes
* <stem>.log, so that name (a user's own log) is left alone since 1.1.6.
if "`cleanup'" != "" {
    local stem `"`htmlpath'"'
    if substr(`"`stem'"', -5, .) == ".html" {
        local stem = substr(`"`stem'"', 1, strlen(`"`stem'"') - 5)
    }
    local nremoved = 0
    forvalues i = 1/500 {
        cap erase `"`stem'_`i'.log"'
        if !_rc local ++nremoved
        cap erase `"`stem'_`i'.smcl"'
        if !_rc local ++nremoved
    }
    di as txt "webdoc2 cleanup: removed `nremoved' intermediate .log/.smcl file(s) (PNG/JPG graphs kept)."
}

* ── Open in default browser if requested ──────────────────────────────────
* Writes a one-line shell script (path in single quotes on Unix, so $ and
* backticks in it are not expanded), then runs it with -shell-.
if "`open'" != "" {
    capture confirm file `"`htmlpath'"'
    if _rc {
        di as err `"webdoc2: cannot open `htmlpath': file not found"'
    }
    else {
        di as txt `"Opening: `htmlpath'"'
        webdoc2open `"`htmlpath'"'
    }
}

 di as txt `"For error checking:"'
 di as smcl `"View subprogram list (loaded in memory): {stata program list}"'

end


program def webdoc2open
version 14
args fn
local mac = ("`c(os)'" == "MacOSX") | regexm("`c(machine_type)'", "Mac")   // Apple-Silicon Stata reports c(os)=="Unix"
local win = ("`c(os)'" == "Windows")
tempfile _wd2_sh
if `win' local script `"`_wd2_sh'.cmd"'
else     local script `"`_wd2_sh'"'
capture mata: st_local("cmdline", _wd2_opencmd(st_local("fn"), `mac', `win', st_local("script")))
if _rc {
    di as txt "webdoc2: could not write the open script; open the file by hand."
    exit
}
* Test hook: with $webdoc2_open_dryrun set, show the command and do not run it
if `"${webdoc2_open_dryrun}"' != "" {
    di as txt `"webdoc2 open (dry run): `macval(cmdline)'"'
}
else if `win' {
    shell "`script'"
}
else {
    shell sh "`script'"
}
if `win' capture erase `"`script'"'
end


program def webdoc2findreplace
version 14
syntax [anything]
local fn `anything'
di as smcl `"Reopen: {browse "`fn'"}"'

* Strip closing-command echoes from the HTML on disk.
* Targets ONLY <span class="stinp">.<ws>cmd<ws></span> patterns so legitimate
* mentions of the command names (e.g., in help-text <p> tags) survive.
* The JS in header.html does the same in the browser; this complements it
* so the saved-to-disk file is also clean. The scrub runs on the whole file
* in Mata: reading it a line at a time into a macro failed with r(132)
* when a logged command with compound quotes wrapped across lines.
tempfile _wd2_tmp
local scrub -9
capture mata: st_local("scrub", strofreal(_wd2_scrub(st_local("fn"), st_local("_wd2_tmp"))))
if _rc | `scrub' < 0 {
    di as txt `"webdoc2findreplace: cannot read or rewrite `fn' — JS in header.html will still clean browser display"'
    exit
}
if `scrub' == 1 {
    cap copy `"`_wd2_tmp'"' `"`fn'"', replace
    if _rc {
        di as txt `"webdoc2findreplace: could not overwrite `fn' — JS in header.html will still clean browser display"'
    }
}
end


version 14
mata:
// Returns 1 when closing-command echoes were removed and the result was
// written to tmp, 0 when there was nothing to remove, < 0 on a file error.
real scalar _wd2_scrub(string scalar fn, string scalar tmp)
{
    real scalar   fh, n
    string scalar s, t, pat, q

    fh = _fopen(fn, "r")
    if (fh < 0) return(-1)
    fseek(fh, 0, 1)
    n = ftell(fh)
    fseek(fh, 0, -1)
    s = (n > 0 ? fread(fh, n) : "")
    fclose(fh)

    q   = char(34)
    pat = "<span class=" + q + "stinp" + q + ">\.\s*(wdclose|buttonclose|graphbuttonclose|wdnavbarclose|wdnavdropdownclose)\s*</span>"
    if (!ustrregexm(s, pat)) return(0)
    t = ustrregexra(s, pat, "")

    fh = _fopen(tmp, "w")
    if (fh < 0) return(-2)
    fwrite(fh, t)
    fclose(fh)
    return(1)
}

// Writes the one-line script that opens fn and returns the command line.
string scalar _wd2_opencmd(string scalar fn, real scalar mac,
                           real scalar win, string scalar script)
{
    real scalar   fh
    string scalar cmd, sq

    sq = char(39)
    if (win) {
        cmd = "start " + char(34) + char(34) + " " + char(34) + fn + char(34)
    }
    else {
        cmd = (mac ? "/usr/bin/open " : "xdg-open ") +
              sq + subinstr(fn, sq, sq + "\" + sq + sq) + sq
    }
    if (fileexists(script)) unlink(script)
    fh = fopen(script, "w")
    fput(fh, cmd)
    fclose(fh)
    return(cmd)
}
end
