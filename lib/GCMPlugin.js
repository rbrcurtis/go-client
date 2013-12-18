var GCM = function() {

}

GCM.prototype.init = function(senderID, eventCallback, successCallback, failureCallback) {
    if (typeof eventCallback != "string"){
		return failureCallback(new Error('eventCallback must be a STRING name of the routine'))
	}

	return Cordova.exec(
		successCallback,
		failureCallback,
		'GCMPlugin',
		'init',
		[{ senderID: senderID, ecb : eventCallback }]
	)

}

GCM.prototype.register = function(successCallback, failureCallback) {
	if (typeof Cordova === 'undefined') { return; }
	return Cordova.exec(
		successCallback,
		failureCallback,
		'GCMPlugin',
		'register',
		[]
	)
}

GCM.prototype.unregister = function( successCallback, failureCallback ) {
	if (typeof Cordova === 'undefined') { return; }
	return Cordova.exec(
		successCallback,
		failureCallback,
		'GCMPlugin',
		'unregister',
		[]
	)

}

if( cordova.addPlugin ){
	cordova.addConstructor(function() {
		//Register the javascript plugin with Cordova
		cordova.addPlugin('GCM', new GCM())
	})
} else {
	window.GCM = new GCM()
}
