*! wdinit - webdoc init with Bootstrap 5 header injection
*! version 1.1.6 20261109 Eric Booth (part of webdoc2)
*!          Default: finds header.html in adopath / working directory.
*!          Custom:  wdinit myfile, replace headerfile("mytheme.html")
*! 2026-11-09 (webdoc2 1.1.5): built-in header fallback when header.html is
*!   not installed; headerfile() accepts absolute and ~ paths; the stray
*!   auto-init document's file handle is closed (no more r(3611) after 48
*!   builds in one session).
*! 2026-11-09 (webdoc2 1.1.6): outer quotes on the document name are removed
*!   (wdinit "report" made a file named "report".html); a bare wdinit keeps
*!   webdoc's default document (<dofile>.html) instead of failing with r(198);
*!   $webdoc2htmlpath is webdoc's absolute ${WebDoc_docname}, so a relative
*!   subfolder name or a cd inside the do-file no longer misleads webdoc2;
*!   the rerun note is not shown when webdoc2 runs the build (it passes
*!   replace).
*cap program drop wdinit
program define wdinit
version 14
* HEADERFile, not HeaderFile: syntax option capitals must be an initial
* substring, and the malformed form made a typed headerfile() fall through
* to the * catch-all silently -- the option never worked as documented.
syntax [anything(id="document name")] [, HEADERFile(string) *]
* syntax keeps outer quotes in anything; webdoc init got them back as part
* of the name, giving "report".html and a broken buttonclose.
local anything `anything'

* Determine which header file to inject
if `"`headerfile'"' == "" {
    * Default: header.html in the working directory or on the adopath; else
    * the built-in copy in _webdoc2_header.ado. net install treats
    * header.html as an ancillary file and does not copy it, so before 1.1.5
    * a plain net/ssc install stopped here with r(601).
    cap findfile "header.html"
    if _rc == 0 {
        local hpath `"`r(fn)'"'
    }
    else {
        cap findfile "_webdoc2_header.ado"
        if _rc != 0 {
            di as err "wdinit: header.html not found in the working directory or on the adopath,"
            di as err "       and the built-in header (_webdoc2_header.ado) is not installed."
            di as err "       Reinstall webdoc2, fetch header.html with -net get webdoc2-,"
            di as err "       or name a theme file with the headerfile() option."
            exit 601
        }
        tempfile hpath
        _webdoc2_header `"`hpath'"'
    }
}
else {
    * User-specified header file. findfile searches only the adopath, so it
    * rejects absolute and ~ paths; try the path as given first.
    local hf `"`macval(headerfile)'"'
    if `"`hf'"' == "~" | inlist(substr(`"`hf'"', 1, 2), "~/", "~\") {
        local home : env HOME
        if `"`home'"' == "" local home : env USERPROFILE
        if `"`home'"' == "" {
            local hd : env HOMEDRIVE
            local hp : env HOMEPATH
            local home `"`hd'`hp'"'
        }
        if `"`home'"' != "" local hf `"`home'`=substr(`"`hf'"', 2, .)'"'
    }
    cap confirm file `"`hf'"'
    if _rc == 0 {
        local hpath `"`hf'"'
    }
    else {
        cap findfile `"`hf'"'
        if _rc != 0 {
            di as err `"wdinit: header file not found: `macval(headerfile)'"'
            exit 601
        }
        local hpath `"`r(fn)'"'
    }
}

* Bare wdinit: keep the document webdoc do opened for this do-file
* (<dofile>.html) and only add the header. webdoc init without a name
* updates the open document; with an empty quoted name it failed r(198).
if `"`anything'"' == "" {
    webdoc init, `macval(options)' header2(include(`"`hpath'"'))
    global webdoc2htmlpath `"${WebDoc_docname}"'
    exit
}

* The document file name, as webdoc init will form it (.html appended)
local htmlfn `"`anything'"'
if lower(substr(`"`htmlfn'"',-5,.)) != ".html" {
    local htmlfn `"`htmlfn'.html"'
}

* -webdoc do- prepends its own optionless `webdoc init "<dofile basename>"'
* when the do-file has no literal -webdoc init- line: wdinit is invisible to
* webdoc's textual scan for init commands. That injected init creates a stray
* <basename>.html, and on the next -webdoc do- pass over the same directory
* it fails with r(602) "file already exists" before wdinit ever executes, so
* no option passed to wdinit can prevent it. When taking over from that stray
* document, close its file handle and remove the file so reruns start clean.
* Only the exact auto-init file is removed, and only while still empty.
if `"${WebDoc_dofile}"' != "" & `"${WebDoc_docname}"' != "" {
    mata: st_local("straydoc", pathrmsuffix(st_global("WebDoc_dofile")) + ".html")
    mata: st_local("wdtarget", pathisabs(st_local("htmlfn")) ? st_local("htmlfn") : pathjoin(pwd(), st_local("htmlfn")))
    if `"${WebDoc_docname}"' == `"`straydoc'"' {
        if `"`wdtarget'"' == `"`straydoc'"' {
            * Same name for document and do-file: the stray IS the target, so
            * it cannot be removed here. The rerun still breaks unless webdoc
            * do itself gets the replace option; warn instead of failing later.
            * webdoc2 always passes replace, so the note is for webdoc do only.
            if `"${webdoc2_running}"' == "" {
                di as txt "note: wdinit document name matches the do-file name;" ///
                    " rerunning -webdoc do- in this directory will fail with" ///
                    " r(602) unless replace is passed to -webdoc do- itself."
            }
        }
        else {
            * webdoc_closeout_fh() lives in webdoc.ado and is private to it,
            * so calling it from here always failed (r(3499), hidden by
            * capture) and leaked one file handle per build; after 48 builds
            * in a session every build died with r(3611). _fclose() is
            * built in. Set the global to missing so webdoc's own cleanup
            * does not close the reused handle number a second time.
            if `"${WebDoc_docname_FH}"' != "" & `"${WebDoc_docname_FH}"' != "." {
                capture mata: (void) _fclose(${WebDoc_docname_FH})
                global WebDoc_docname_FH "."
            }
            capture quietly checksum `"`straydoc'"'
            if _rc == 0 & r(filelen) == 0 {
                capture erase `"`straydoc'"'
            }
        }
    }
}

* Call webdoc init, injecting the header file into <head> via include()
* All other options (replace, logall, grdir, etc.) pass through via `options'
webdoc init `"`anything'"', `macval(options)' header2(include(`"`hpath'"'))
* webdoc stores the absolute document path; webdoc2 uses it for the
* closing-command scrub, cleanup and open (a relative name such as
* out/report went wrong when the do-file changed directory).
global webdoc2htmlpath `"${WebDoc_docname}"'
end
