*==============================================================================*
* test_webdoc2.do -- battery for webdoc2 v1.1.5
* Run:  stata-mp -b do test_webdoc2.do ["/path/to/pkg"]
* Requires Ben Jann's webdoc (ssc install webdoc), which webdoc2 wraps.
* webdoc commands act only while -webdoc do- is processing a do-file, so the
* battery writes a small inner do-file and drives it through webdoc do, then
* checks the HTML that lands on disk.
* Judge the run by the log: no r(NNN) errors, no "assertion is false".
* File cleanup uses Mata (no shell), so the battery runs on any OS.
*==============================================================================*
clear all
set more off

* remove a scratch folder and everything in it (Mata, no shell)
capture mata: mata drop _wd2t_rmtree()
mata:
void _wd2t_rmtree(string scalar d)
{
    string colvector f
    real scalar      i
    if (!direxists(d)) return
    f = dir(d, "files", "*")
    for (i = 1; i <= rows(f); i++) unlink(pathjoin(d, f[i]))
    f = dir(d, "dirs", "*")
    for (i = 1; i <= rows(f); i++) _wd2t_rmtree(pathjoin(d, f[i]))
    (void) _rmdir(d)
}
end

* count Mata file handles left open (probe closes each one it finds)
capture program drop _wd2t_nopen
program _wd2t_nopen, rclass
    local n 0
    forvalues i = 0/60 {
        capture mata: (void) _fclose(`i')
        if !_rc local ++n
    }
    return scalar n = `n'
end

if `"`1'"' != "" global pkgroot `"`1'"'
if `"$pkgroot"' == "" {
    capture findfile webdoc2.ado
    if !_rc {
        local fp `"`r(fn)'"'
        local s = max(strrpos(`"`fp'"', "/"), strrpos(`"`fp'"', "\"))
        if `s' > 1 global pkgroot = substr(`"`fp'"', 1, `s' - 1)
    }
}
if `"$pkgroot"' == "" {
    di as err "test_webdoc2: cannot locate webdoc2.ado."
    exit 601
}
confirm file "$pkgroot/webdoc2.ado"
adopath ++ "$pkgroot"
discard

* dependency: webdoc2 wraps Ben Jann's webdoc
capture which webdoc
if _rc {
    di as err "test_webdoc2: requires -webdoc- (ssc install webdoc)."
    exit 111
}

* work in a scratch directory
local wd0 "`c(pwd)'"
local site "`c(tmpdir)'/wd2_test_site"
mata: _wd2t_rmtree(st_local("site"))
mkdir "`site'"
cd "`site'"

*--- (1) an inner do-file driven by webdoc do builds the page -----------------*
file open h using "inner.do", write replace
file write h `"wdinit testpage, replace"' _n
file write h `"wput This is the battery body text."' _n
file write h `"wputh1 Battery Heading One"' _n
file write h `"webdoc close"' _n
file close h
webdoc do inner.do
confirm file "`site'/testpage.html"
di as res "TEST 1 OK: webdoc do inner.do writes testpage.html"

*--- (2) the HTML holds the body text, the heading, and the injected header ---*
local html = fileread("`site'/testpage.html")
assert strpos(`"`html'"', "battery body text") > 0
assert strpos(`"`html'"', "Battery Heading One") > 0
assert strpos(lower(`"`html'"'), "bootstrap") > 0
di as res "TEST 2 OK: body, h1, and Bootstrap header all present"

*--- (3) the h1 is a real tag, not escaped text -------------------------------*
assert strpos(`"`html'"', "<h1") > 0
di as res "TEST 3 OK: heading rendered as an <h1> tag"

*--- (4) rerunning webdoc do over existing output must not r(602) -------------*
* webdoc do injects its own optionless -webdoc init "inner"- because wdinit is
* invisible to its textual scan for init commands. The stray inner.html that
* init created made every rerun die with r(602) before wdinit executed; wdinit
* now removes the stray when it takes over, so a second pass replaces cleanly.
confirm new file "`site'/inner.html"
capture noisily webdoc do inner.do
assert _rc == 0
confirm file "`site'/testpage.html"
local html = fileread("`site'/testpage.html")
assert strpos(`"`html'"', "battery body text") > 0
confirm new file "`site'/inner.html"
di as res "TEST 4 OK: rerun with existing HTML replaces cleanly (no r(602))"

*--- (5) outside webdoc do, the wrappers refuse gracefully --------------------*
capture noisily wdinit failpage, replace
assert _rc == 0
confirm new file "`site'/failpage.html"
di as res "TEST 5 OK: outside webdoc do, wdinit declines and writes nothing"

*--- (6) wdimg writes width= and alt= (1.1.5) ---------------------------------*
file open h using "img.do", write replace
file write h `"wdinit imgpage, replace"' _n
file write h `"wdimg figure1.png, width(600) alt(Distribution of price)"' _n
file write h `"wdimg, src(viasrc.png) caption(Cap) alt(Alt text) width(50%)"' _n
file write h `"webdoc close"' _n
file close h
webdoc2 img.do, cleanup
local html = fileread("`site'/imgpage.html")
assert strpos(`"`html'"', `"<img src="figure1.png" width="600" alt="Distribution of price""') > 0
assert strpos(`"`html'"', `"<img src="viasrc.png" width="50%" alt="Alt text">"') > 0
di as res "TEST 6 OK: wdimg width() and alt() reach the HTML"

*--- (7) wd rejects scan-only stlog options instead of ignoring them (1.1.5) -*
* webdoc do applies nooutput/nodo/cmdlog/dosave only to literal webdoc stlog
* lines; wd used to accept and ignore them, publishing hidden output.
local i 0
foreach opt in "nooutput" "noout" "nodo" "cmdlog" "dosave" {
    local ++i
    file open h using "wdopt`i'.do", write replace
    file write h `"wdinit wdoptpage`i', replace"' _n
    file write h `"wd, `opt'"' _n
    file write h `"display "WD-SHOULD-NOT-SHOW""' _n
    file write h `"wdclose"' _n
    file write h `"webdoc close"' _n
    file close h
    capture noisily webdoc2 wdopt`i'.do, cleanup
    assert _rc == 198
    capture webdoc close
}
* a nooutput default on wdinit is caught too; wd, output overrides it
file open h using "wdopt6.do", write replace
file write h `"wdinit wdoptpage6, replace nooutput"' _n
file write h `"wd"' _n
file write h `"display "X""' _n
file write h `"wdclose"' _n
file write h `"webdoc close"' _n
file close h
capture noisily webdoc2 wdopt6.do, cleanup
assert _rc == 198
capture webdoc close
file open h using "wdopt7.do", write replace
file write h `"wdinit wdoptpage7, replace nooutput"' _n
file write h `"wd named7, output"' _n
file write h `"display "WD-SHOWN-OUT""' _n
file write h `"wdclose"' _n
file write h `"webdoc stlog, nooutput"' _n
file write h `"display "NATIVE-HIDDEN-OUT""' _n
file write h `"webdoc stlog close"' _n
file write h `"webdoc close"' _n
file close h
webdoc2 wdopt7.do, cleanup
local html = fileread("`site'/wdoptpage7.html")
assert strpos(`"`html'"', `"<span class="stres">WD-SHOWN-OUT"') > 0
assert strpos(`"`html'"', `"<span class="stres">NATIVE-HIDDEN-OUT"') == 0
di as res "TEST 7 OK: wd rejects nooutput/nodo/cmdlog/dosave; webdoc stlog, nooutput hides"

*--- (8) logall is rejected up front, not r(499) mid-build (1.1.5) ------------*
capture noisily webdoc2 inner.do, logall
assert _rc == 198
capture webdoc close
di as res "TEST 8 OK: webdoc2, logall stops with r(198)"

*--- (9) no file handle leaks across builds (1.1.5) ---------------------------*
_wd2t_nopen
forvalues k = 1/5 {
    quietly webdoc2 inner.do
}
_wd2t_nopen
assert r(n) == 0
local fails 0
forvalues k = 1/55 {
    capture quietly webdoc2 inner.do
    if _rc local ++fails
}
assert `fails' == 0
di as res "TEST 9 OK: 60 builds in one session, no leaked handles, no r(3611)"

*--- (10) wdnavbar brandhref() sets the brand link (1.1.4) --------------------*
file open h using "nav.do", write replace
file write h `"wdinit navpage, replace"' _n
file write h `"wdnavbar Brand A, brandhref(pageA.html) bg(bg-primary)"' _n
file write h `"wdnavbarclose"' _n
file write h `"webdoc close"' _n
file close h
webdoc2 nav.do, cleanup
local html = fileread("`site'/navpage.html")
assert strpos(`"`html'"', `"<a class="navbar-brand" href="pageA.html">"') > 0
assert strpos(`"`html'"', "bg-primary") > 0
di as res "TEST 10 OK: wdnavbar brandhref() lands in the HTML"

*--- (11) headerfile(): absolute path, path with a space, ~ path (1.1.5) ------*
mkdir "`site'/sub dir"
file open h using "`site'/sub dir/my head.html", write replace
file write h "<style>/*WD2-CUSTOM-HEADER*/</style>" _n
file close h
local cases `""`site'/sub dir/my head.html""'
local home : env HOME
if `"`home'"' == "" local home : env USERPROFILE
local hl = strlen(`"`home'"')
if `hl' > 0 & substr(`"`site'"', 1, `hl') == `"`home'"' {
    local cases `"`cases' "~`=substr(`"`site'"', `hl' + 1, .)'/sub dir/my head.html""'
}
local i 0
foreach hf of local cases {
    local ++i
    file open h using "hf`i'.do", write replace
    file write h `"wdinit hfpage`i', replace headerfile("`hf'")"' _n
    file write h `"wput custom header body"' _n
    file write h `"webdoc close"' _n
    file close h
    webdoc2 hf`i'.do, cleanup
    local html = fileread("`site'/hfpage`i'.html")
    assert strpos(`"`html'"', "WD2-CUSTOM-HEADER") > 0
    di as txt `"  headerfile("`hf'") OK"'
}
di as res "TEST 11 OK: headerfile() accepts absolute, spaced and ~ paths (`i' case(s))"

*--- (12) built-in header: identical to header.html, used when it is absent ---*
_webdoc2_header "`site'/builtin.html"
checksum "`site'/builtin.html"
local ck1 = r(checksum)
checksum "$pkgroot/header.html"
assert `ck1' == r(checksum)
* package copy without header.html, in place of the full one on the adopath
mkdir "`site'/nohdr"
local ados : dir "$pkgroot" files "*.ado"
foreach f of local ados {
    copy "$pkgroot/`f'" "`site'/nohdr/`f'"
}
adopath - "$pkgroot"
adopath ++ "`site'/nohdr"
discard
capture findfile header.html
local hashdr = (_rc == 0)
if !`hashdr' {
    webdoc2 inner.do
    local html = fileread("`site'/testpage.html")
    assert strpos(`"`html'"', "battery body text") > 0
    assert strpos(lower(`"`html'"'), "bootstrap") > 0
    di as res "TEST 12 OK: no header.html installed, wdinit used the built-in copy"
}
else di as txt "TEST 12 partial: another header.html is on the adopath (`r(fn)'); fallback build skipped"
adopath - "`site'/nohdr"
adopath ++ "$pkgroot"
discard

cd "`wd0'"
mata: _wd2t_rmtree(st_local("site"))
di as res _n "ALL TESTS PASSED: webdoc2 battery complete"
