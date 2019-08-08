//
// SAGE2 application: lifemapper
// by: Michael Elliott <mielliott@ufl.edu>
//

console.log("main.js loaded");



/*
How to use SAGE2_AppState.js

	Including SAGE2_AppState.js will add a global variable to the window called:
		SAGE2_AppState

	That provides the means to communicate with the app container.

	See the following examples below:

*/

// Adding a full state handler
SAGE2_AppState.addFullStateHandler(customFullStateHandler); // customFullStateHandler is a function defined below

// Adding a specific value handler, this always activate AFTER the full state handler
SAGE2_AppState.addValueHandler("zoom", handlerForZoomStateValue); 


// To manually change the container title
SAGE2_AppState.titleUpdate("Hello world test page");

// To call a function in the container
// State the name of the function in a string, the second param will be given to the function
SAGE2_AppState.callFunctionInContainer("printPropertyLine1", {line1: "To pass more than oneparam", line2:"pass an object", lineCount:2});
SAGE2_AppState.callFunctionInContainer("printPropertyLine2", {line1: "To pass more than oneparam", line2:"pass an object", lineCount:2});



	
// ----------------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------------------
function customFullStateHandler(state) {
	console.log("Received a full state update from container", state);
	document.getElementById("stateInfo").textContent = JSON.stringify(state);
}

function handlerForZoomStateValue(value) {
	console.log("State was updated, current zoom value:", value);
	document.getElementById("zoomInfo").textContent = value;
}

// Called from UI context menu
function setCounterValue(value) {
	document.getElementById("counterInfo").textContent = value;
}

