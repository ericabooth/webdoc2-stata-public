*********! webdoc graph wgraph 
program define  wgraph
version 14
syntax [anything(equalok)] [, *]
* 1.1.6: pass the graph name through (it was dropped silently)
webdoc graph `anything', `options'
end
