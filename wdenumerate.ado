*! wdenumerate - Open a numbered list (<ol>).
*!               Pair with wditem (items) and wdlistend (close).
*!               For dashed markers see wdlist; for round bullets see wditemize.
*cap program drop wdenumerate
program define wdenumerate
version 14
syntax
global wdlist_tag "ol"
webdoc put <ol>
end
