//
// SAGE2 application: lifemapper
// by: Michael Elliott <mielliott@ufl.edu>
//

"use strict";

/*
How to use:


*/


var lifemapper = sage2_webview_appCoreV01_extendWebview({
	webpageAppSettings: {
		setSageAppBackgroundColor: true, // Web pages without background values will be transparent.
		backgroundColor: "white", // Used if above is true, can also use rgb and hex strings
		enableRightClickNewWindow: false, // right clicking on images or links open new webview
		printConsoleOutputFromPage: true, // If true, when page prints to command line, app will print in display client

		// If you want your entries to appear before or after the default
		putAdditionalContextMenuEntriesBeforeDefaultEntries: true,
		// The following will include the default Webview context menu entry if set to true.
		enableUiContextMenuEntries: {
			navigateBack:       false, // alt left-arrow
			navigateForward:    false, // alt right-arrow
			reload:             false, // alt r
			autoRefresh:        false, // must be selected from UI context menu
			consoleViewToggle:  false, // must be selected from UI context menu
			zoomIn:             false, // alt up-arrow
			zoomOut:            false, // alt down-arrow
			urlTyping:          false, // must be typed from UI context menu
			copyUrlToClipboard: false, // must be typed from UI context menu
		},
	},
	init: function(data) {
		// Will be called after initial SAGE2 init()
		// this.element will refer to the webview tag
		this.resizeEvents = "continuous"; // Recommended not to change. Options: never, continuous, onfinish

		// Path / URL of the page you want to show
		// TODO: so much ugliness to fix
		if (data.customLaunchParams) {
			console.log(data.customLaunchParams);
			switch (data.customLaunchParams.view) {
				case "occmap":
					console.log("Launching Lifemapper app as \"occmap\"");
					this.sendResize(752, 600);
					this.changeURL(this.resrcPath + "/webapp/mapView.html", false);
					//this.changeURL(this.resrcPath + "/webapp/statsTreeMap.html", false);
					break;
				case "tree":
					console.log("Launching Lifemapper app as \"tree\"");
					this.sendResize(672, 1138);
					this.changeURL(this.resrcPath + "/webapp/treeView.html", false);
					break;
				case "scatter":
					console.log("Launching Lifemapper app as \"scatter\"");
					this.sendResize(700, 700);
					this.changeURL(this.resrcPath + "/webapp/scatterView.html", false);
					break;
				case "biotaphy":
					console.log("Launching Lifemapper app as \"biotaphy\"");
					this.sendResize(1200, 800);
					this.changeURL(this.resrcPath + "/heuchera_demo/index.html", false);
					break;
				default:
					console.log("Launching Lifemapper app with no parameters");
					this.sendResize(560, 128);
					this.changeURL(this.resrcPath + "/webapp/packageView.html", false);
					break;
			}
		}
		else {
			console.log("Launching Lifemapper app with no parameters");
			this.sendResize(560, 128);
			this.changeURL(this.resrcPath + "/webapp/packageView.html", false);
			//this.changeURL(this.resrcPath + "/webpageOLD/index.html", false);
		}
	},
	load: function(date) {
		// OPTIONAL
		// The state will be automatically passed to your webpage through the handler you gave to SAGE2_AppState
		// Use this if you want to alter the state BEFORE it is passed to your webpage. Access with this.state
	},
	draw: function(date) {
		// OPTIONAL
		// Your webpage will be in charge of its view
		// Use this if you want to so something within the SAGE2 Display variables
		// Be sure to set 'this.maxFPS' within init() if this is desired.
		// FPS only works if instructions sets animation true
	},
	resize: function() {
		// OPTIONAL
	},
	getContextEntries: function() {
		// OPTIONAL
		// This can be used to allow UI interaction to your webpage
		// Entries are added after entries of enableUiContextMenuEntries 
		var entries = [];
		// entries.push({
		// 	description: "This text is seen in the UI",
		// 	callback: "makeAFunctionMatchingThisString", // The string will specify which function to activate
		// 	parameters: {},
		// 	// The called function will be passed an Object.
		// 	// Each of the parameter properties will be in that object
		// 	// Some properties are reserved and may be automatically filled in.
		// });
		
		// TODO: remove these (keeping for now as reference)
		entries.push({
			description: "Set Counter value",
			callback: "setCounterValueInPage", // function defined below
			inputField: true, // Takes typed input from UI
			inputFieldSize: 5, // How big to make the field
			parameters: {},
		});
		entries.push({
			description: "Force state update",
			callback: "giveContainerStateToWebpage", // function defined below
			parameters: {},
		});

		entries.push({
			description: "Open a phylogenetic tree",
			callback: "openTreeCallback", // function defined below
			parameters: {},
		});
		entries.push({
			description: "Open an occurrence map",
			callback: "openMapCallback", // function defined below
			parameters: {},
		});
		entries.push({
			description: "Open a scatter plot",
			callback: "openScatterCallback", // function defined below
			parameters: {},
		});
		entries.push({
			description: "Open BiotaPhy",
			callback: "openBiotaPhyCallback", // function defined below
			parameters: {},
		});

		return entries;
	},

	/**
	 * Change the title of the window // Why isn't this working?
	 *
	 * @method     changeWebviewTitle
	 * @param newTitle {String} new title
	 */
	/*changeWebviewTitle: function(newTitle) {
		console.log("Changing title to" + newTitle)
		this.updateTitle(newTitle + " AROO?");
	},*/

	// ----------------------------------------------------------------------------------------------------
	// ----------------------------------------------------------------------------------------------------
	// ----------------------------------------------------------------------------------------------------
	// Add optional functions

	openTreeCallback: function() {
		console.log("Opening phylogenetic tree app");
		this.launchAppWithValues("Lifemapper-SAGE2-App", { view : "tree" });
	},

	openMapCallback: function() {
		console.log("Opening occurrence map app");
		this.launchAppWithValues("Lifemapper-SAGE2-App", { view : "occmap" });
	},

	openScatterCallback: function() {
		console.log("Opening scatter plot app");
		this.launchAppWithValues("Lifemapper-SAGE2-App", { view : "scatter" });
	},

	openBiotaPhyCallback: function() {
		console.log("Opening a BiotaPhy app")
		this.launchAppWithValues("Lifemapper-SAGE2-App", { view : "biotaphy" })
	},

	suggestNodesForSites: function(data) {
		console.log("Suggesting nodes for sites");
		this.sendDataToParentApp("propagateNodesForSites", JSON.stringify(data));
	},

	suggestSitesForNode: function(data) {
		console.log("Suggesting sites for node");
		console.log("Received this piece a junkah:");
		console.log(JSON.stringify(data))
		console.log("End of junk")
		this.sendDataToParentApp("propagateSitesForNode", JSON.stringify(data));
	},

	propagateNodesForSites: function(data) {
		console.log("Propagating nodes for sites");
		this.sendDataToChildrenApps("receiveNodesForSites", data);
	},

	propagateSitesForNode: function(data) {
		console.log("Propagating sites for node");
		this.sendDataToChildrenApps("receiveSitesForNode", data);
	},

	receiveNodesForSites: function(data) {
		console.log("Receiving nodes for sites");
		this.callFunctionInWebpage("receiveNodesForSites", data);
	},

	receiveSitesForNode: function(data) {
		console.log("Receiving sites for node");
		this.callFunctionInWebpage("receiveSitesForNode", data);
	},

	askParent: function(func, data) { // TODO: not in use? Remove?
		data._sender = this.id; // Provide an address for the parent to reply to
		this.sendDataToParentApp(func, data);
	},

	getModel: function(data) {
		if (data._sender)
			applications[data._sender]
	},

	setCounterValueInPage: function(responseObject) { // Handles the UI context menu entry
		this.callFunctionInWebpage("setCounterValue", responseObject.clientInput);
	},

	giveContainerStateToWebpage: function() {
		this.sendStateToWebpage();
	},

	printPropertyLine1: function(value) {
		console.log(value.line1);
	},

	printPropertyLine2: function(value) {
		console.log(value.line2);
	},

});