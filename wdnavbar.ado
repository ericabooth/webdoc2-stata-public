*! wdnavbar - Open a Bootstrap 5 navbar (use with wdnavitem / wdnavbarclose)
*cap program drop wdnavbar
program define wdnavbar
version 14
syntax [anything(equalok everything)] [, Color(string) Bg(string) BrandHref(string) Id(string)]
local anything = `"`anything'"'
if "`color'"     == "" local color     "navbar-dark"
if "`bg'"        == "" local bg        "bg-dark"
if "`brandhref'" == "" local brandhref "#"
if "`id'"        == "" local id        "mainNavbar"
webdoc put <nav class="navbar navbar-expand-lg `color' `bg' mb-4">
webdoc put <div class="container-fluid">
webdoc put <a class="navbar-brand" href="`brandhref'">`anything'</a>
webdoc put <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#`id'" aria-controls="`id'" aria-expanded="false" aria-label="Toggle navigation"><span class="navbar-toggler-icon"></span></button>
webdoc put <div class="collapse navbar-collapse" id="`id'"><ul class="navbar-nav me-auto mb-2 mb-lg-0">
end
