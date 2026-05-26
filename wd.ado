*********! stlog open/close = w and wclose 
*cap program drop wd
program define  wd
syntax [anything] [, *]
webdoc stlog `anything', `options'
end
