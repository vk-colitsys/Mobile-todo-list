<html>
	<head>
		<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />

		<meta HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">

	    <style type="text/css">
	    	html { height: 100% }
	      	body { height: 100%; margin: 0; padding: 0 }
	      	#map-canvas { height: 100% }
	    </style>

		<script src="http://maps.googleapis.com/maps/api/js?sensor=true"></script>

		<script src="jquery-2.0.3.min.js" ></script>

	    <script >
	    	$(document).ready(function(){
	    		//do nothing for now
	    	});

	    	function displayMessage(msg)
	    	{ 
	    		$("#msgDiv").html(msg);
	    	}
	    </script>
	</head>

	<body>
		<div id="msgDiv"></div>

		<div id="map-canvas"/>	
	</body>
</html>

<cfclientsettings enabledeviceapi="true">
<cfclient>
	<cfscript>
		mapEnableHighAccuracy = false; //If true, API will use GPS else will use mobile network to get current position.

		try
		{
			myMap = new google.maps.Map(document.getElementById("map-canvas"));

			mapMarker = new google.maps.Marker({
			    map: myMap,
			    title:"My Location",
	            draggable: true
			});

			getCurrentPosition (function(position) {
				//Got current position
				displayMap(myMap,position,mapMarker);

				//Watch for change in the position
				cfclient.geolocation.watchPosition(function(pos) {

					displayMessage("Location changed - " + pos.coords.latitude + "," + 
						pos.coords.longitude);

					displayMap(myMap,pos,mapMarker);
				},
				{maximumAge: 3000, timeout: 5000, enableHighAccuracy: mapEnableHighAccuracy });
			}, 0, 0 /*indefinite wating time*/);
		} 
		catch (any e)
		{
			alert("Error : " + e.message);
		}

		function displayMap(map, position, marker)
		{
			var latLong = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
			var mapOptions = {
          		center: latLong,
          		zoom: 15
        	};

        	map.setOptions(mapOptions);
        	marker.setPosition(latLong);
		}

		//Value of 0 for maxWaritingTime means keep trying indefinitely. 
		function getCurrentPosition (callback, totalWaitingTime, maxWaitingTime)
		{
			if (maxWaitingTime > 0 && totalWaitingTime > maxWaitingTime)
			{
				displayMessage("Timed out. Failed to get the current position");
				return;
			}

			var options = {maximumAge: 3000, timeout: 1000, enableHighAccuracy: mapEnableHighAccuracy };

			try
			{
				if (totalWaitingTime <= 0)
					displayMessage("Getting current position");

				var currPos = cfclient.geolocation.getCurrentPosition(options);

				displayMessage("Got the current position");

				callback(currPos);
			}
			catch (any e)
			{
				totalWaitingTime += options.timeout;
				displayMessage("Retrying to get the current position - " + totalWaitingTime + " - " + e.message);
				//assume it is timeout
				setTimeout(function(){
					getCurrentPosition(callback, totalWaitingTime, maxWaitingTime);
				},100);
			}
		}
	</cfscript>
</cfclient>