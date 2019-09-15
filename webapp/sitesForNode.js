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

app.ports.requestSitesForNode.subscribe(function(nodeId) {
    const node = nodeLookup.find(function(d) {
        return d.header == nodeId || d.header.toLowerCase() == ("node_" + nodeId);
    });
    const dataColumn = node && node.index;

    const sites = ancPam.features.map(function(feature) {
        const data = feature.properties.data;
        if (data[1] && data[1].includes(dataColumn)) return [feature.id, "left"];
        if (data[-1] && data[-1].includes(dataColumn)) return [feature.id, "right"];
        if (data[2] && data[2].includes(dataColumn)) return [feature.id, "both"];
        return null;
    }).filter(function(result) { return result != null; });

    // Propagate selection to other apps
    //console.log("Suggestions vvvvv")
    //console.log(sites)
    //console.log("selecting node 10 ahhaah");
    //app.ports.selectNode.send(10);
    SAGE2_AppState.callFunctionInContainer("suggestSitesForNode", { dat: sites } );
    //receiveSitesForNode(sites);
    app.ports.sitesForNode.send(sites);
    //app.ports.selectNode.send(nodeId);
});

app.ports.requestNodesForSites.subscribe(function(sites) {
    const leftNodes = new Set();
    const rightNodes = new Set();
    ancPam.features.forEach(function(feature) {
        const data = feature.properties.data;
        if(sites.includes(feature.id)) {
            data[1] && data[1].forEach(function(i) {
                const node = nodeLookup.find(function(d) {
                    return d.index == i;
                });
                leftNodes.add(parseInt(node.header.replace(/^Node_/i, '')));
            });
            data[-1] && data[-1].forEach(function(i) {
                const node = nodeLookup.find(function(d) {
                    return d.index == i;
                });
                rightNodes.add(parseInt(node.header.replace(/^Node_/i, '')));
            });
        }
    });
    const nodesForSites = [Array.from(leftNodes), Array.from(rightNodes)];

    // Propagate selection to other apps
    SAGE2_AppState.callFunctionInContainer("suggestNodesForSites", { dat: nodesForSites });
    app.ports.nodesForSites.send(nodesForSites);
});

function receiveSitesForNode(data) {
    //console.log("Passing sites for node to Elm !!");
    //console.log(data)
    //console.log(String(data))
    /*var q = String(JSON.parse(String(data))).split(",");
    console.log(q)
    var d = [];
    for (let i = 0; i < q.length; i += 2) {
        d[i / 2] = [parseInt(q[i]), q[i + 1]];
    }*/
    var d = JSON.parse(String(data)).dat;
    //console.log("All cleaned up!");
    //console.log(d);
    //console.log("Now send!")
    app.ports.sitesForNode.send(d);
}

function receiveNodesForSites(data) {
    //console.log("Passing nodes for sites to Elm");
    var d = JSON.parse(String(data)).dat;
    app.ports.nodesForSites.send(d);
}

