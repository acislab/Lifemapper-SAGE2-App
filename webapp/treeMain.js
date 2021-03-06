/*
Copyright (C) 2017, University of Kansas Center for Research

Lifemapper Project, lifemapper [at] ku [dot] edu,
Biodiversity Institute,
1345 Jayhawk Boulevard, Lawrence, Kansas, 66045, USA

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
02110-1301, USA.
*/

"use strict";

// Elm init
var node = document.getElementById("app");
while(node.firstChild) { node.removeChild(node.firstChild); }

// TODO: get mcpaMatrix and taxonTree from lifemapper.js?

var app = Elm.TreeView.embed(node, {
    data: mcpaMatrix,
    taxonTree: taxonTree
});

/*
app.ports.propagateNodeSelection.subscribe(function(data) {
    console.log("packageMain.js: propagating node selection");
    console.log(data);
    SAGE2_AppState.callFunctionInContainer("propagateNodeSelection", data );
});
*/

// SAGE2 init
SAGE2_AppState.titleUpdate("Phylogenetic Tree");
