*********! stlog open/close = w and wclose 
*cap program drop wd
program define  wd
version 14
syntax [anything] [, *]
webdoc stlog `anything', `options'
end
