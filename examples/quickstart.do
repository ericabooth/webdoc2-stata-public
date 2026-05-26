*--------------------------------------------------------------------*
* quickstart.do  --  the smallest useful webdoc2 example
*
* Build with:    webdoc2 quickstart.do, open
* Result:        quickstart.html in this folder, opened in your browser.
*
* Five commands you really need to remember:
*   wdinit name, replace      open report
*   wputh1 / wputh2 text      heading + auto anchor id
*   wput text                 a paragraph
*   wd / wdclose              run code, log it inline
*   button / buttonclose      run code, log it in a click-to-expand panel
*--------------------------------------------------------------------*

wdinit quickstart, replace

wputh1 Quickstart
wput This page was generated from a 20-line Stata do-file by webdoc2.

wputh2 Run a regression and show the output inline
wd
sysuse auto, clear
regress price mpg weight
wdclose

wputh2 Same regression but collapsed by default
button
sysuse auto, clear
regress price mpg weight foreign
buttonclose

wputh2 A graph in a collapsible panel
graphbutton
sysuse auto, clear
scatter price mpg, title("Price vs MPG")
wgraph, width(600)
graphbuttonclose

webdoc close
