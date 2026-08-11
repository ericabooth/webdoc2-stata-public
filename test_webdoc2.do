*==============================================================================*
* test_webdoc2.do -- battery for webdoc2 v1.1.3
* Run:  stata-mp -b do test_webdoc2.do ["/path/to/pkg"]
* Requires Ben Jann's webdoc (ssc install webdoc), which webdoc2 wraps.
* webdoc commands act only while -webdoc do- is processing a do-file, so the
* battery writes a small inner do-file and drives it through webdoc do, then
* checks the HTML that lands on disk.
* Judge the run by the log: no r(NNN) errors, no "assertion is false".
*==============================================================================*
clear all
set more off

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
capture shell rm -rf "`site'"
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

cd "`wd0'"
capture shell rm -rf "`site'"
di as res _n "ALL TESTS PASSED: webdoc2 battery complete"
