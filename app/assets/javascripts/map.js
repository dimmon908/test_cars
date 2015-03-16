var windowsArray = [];
/** @type {Array<google.maps.Marker>} */
var markersArray = [];
var markersVisibleArray = [];
var directionsDisplays = [];
var directionServices = [];
var Paths = [];
var infowindow = null;
var curretMarkerIndex = null;
var defaults = {
  PICKUP_ICON: 'img/icon/pickup.png',
  DESTINATION_ICON: 'img/icon/destination.png',
  POINT_ICON: 'img/icon/map_point.png',

  DRIVER_ICON: 'img/icon/car.png'
};
var delay_request = false;
var latlngbounds;

function GoogleAddress(address_components, name) {
  var _route='';
  var _locality='';
  var _country='';
  var _postal_code='';
  var _street_number='';
  var _county = '';
  var _state = '';
  var _neighborhood = '';
  var _name = name || '';

  this.name = function() {
    return _name;
  };
  this.route = function() {
    return _route;
  };
  this.neighborhood = function() {
    return _neighborhood;
  };
  this.locality = function() {
    return _locality;
  };
  this.country = function() {
    return _country;
  };
  this.postal_code = function() {
    return _postal_code;
  };
  this.street_number = function() {
    return _street_number;
  };
  this.county = function() {
    return _county;
  };
  this.state = function() {
    return _state;
  };
  this.city = function() {
    var array = [];
    if (_locality.toString() != '') {
      array.push(_locality.toString());
    }
    if (_postal_code.toString() != '') {
      array.push(_postal_code.toString());
    }
    return array.join(' ');
  };
  this.street = function() {
    var array = [];
    if (_street_number.toString() != '') {
      array.push(_street_number.toString());
    }
    if (_route.toString() != '') {
      array.push(_route.toString());
    }

    return array.join('  ');
  };

  $.each(address_components, function (i, address_component) {
    switch(address_component.types[0].toString()) {
      case 'route':
        _route = address_component.long_name;
        break;
      case 'administrative_area_level_2':
        _county = address_component.long_name;
        break;
      case 'administrative_area_level_1':
        _state = address_component.long_name;
        break;
      case 'locality':
        _locality = address_component.long_name;
        break;
      case 'country':
        _country = address_component.long_name;
        break;
      case 'postal_code_prefix':
      case 'postal_code':
        _postal_code = address_component.long_name;
        break;
      case 'street_number':
        _street_number = address_component.long_name;
        break;
      case 'neighborhood':
        _neighborhood = address_component.long_name;
        break;
    }
  });

}

jQuery(function () {

  window.can_click = window.can_click || false;
  /**
   * @param value
   * @param index
   * @param street
   * @param city
   * @param lat
   * @param lng
   * @param name
   * @param marker_id
   */
  window.addWaypoint = function(value, index, street, city, lat, lng, name, marker_id) {
    curretMarkerIndex = null;
    var id = window.add_way_point();
    var waypoint = jQuery("#" + id);

    var leng = window.current_to.length;
    window.current_to.push({
      geometry: {location: (new google.maps.LatLng(lat, lng))},
      formatted_address: value
    });

    window.direction();
    if (waypoint.length) {
      $(waypoint).attr('data-street', street);
      $(waypoint).attr('data-city', city);
      $(waypoint).attr('data-lat', lat);
      $(waypoint).attr('data-lng', lng);
      $(waypoint).attr('data-name', name);
      window.recheck_validators(function() {waypoint.val(value);});
      delay_request = true;
      if (markersArray[marker_id] != null) {
        if (markersArray['to_'+leng] != null) { markersArray['to_'+leng].setMap(null); }
        markersArray['to_'+leng] = markersArray[marker_id];
        markersArray['to_'+leng].setIcon(defaults.PICKUP_ICON);
        markersArray[marker_id] = null;
      }
      add_address(value, function (results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
          window.current_to[leng] = results[0];
          direction();
        }
        delay_request = false;
      });
    }
    clean(index);
  };

  /**
   * @param value
   * @param index
   * @param street
   * @param city
   * @param lat
   * @param lng
   * @param name
   * @param marker_id
   */
  window.setPickup = function(value, index, street, city, lat, lng, name, marker_id) {
    curretMarkerIndex = null;
    var from = jQuery("#Request_from");
    if (from.length) {
      $(from).attr('data-street', street);
      $(from).attr('data-city', city);
      $(from).attr('data-lat', lat);
      $(from).attr('data-lng', lng);
      $(from).attr('data-name', name);
      window.recheck_validators(function() {from.val(value);});
      delay_request = true;
      if (markersArray[marker_id] != null) {
        if (markersArray['from'] != null) { markersArray['from'].setMap(null); }
        markersArray['from'] = markersArray[marker_id];
        markersArray['from'].setIcon(defaults.PICKUP_ICON);
        markersArray[marker_id] = null;
      }
      add_address(value, function (results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
          window.from = results[0];
          direction();
        }
        delay_request = false;
      });
      $(from).parent().find('.favorite_star').removeClass('exist');
    }
    clean(index);
  };

  /**
   * @param value
   * @param index
   * @param street
   * @param city
   * @param lat
   * @param lng
   * @param name
   * @param marker_id
   */
  window.setDest = function(value, index, street, city, lat, lng, name, marker_id) {
    curretMarkerIndex = null;
    var to = jQuery("#Request_to_0");
    if (to.length) {
      $(to).attr('data-street', street);
      $(to).attr('data-city', city);
      $(to).attr('data-lat', lat);
      $(to).attr('data-lng', lng);
      $(to).attr('data-name', name);
      window.recheck_validators(function() {to.val(value);});
      window.current_to[0] = ({
        geometry: {location: (new google.maps.LatLng(lat, lng))},
        formatted_address: value
      });
      if (markersArray[marker_id] != null) {
        if (markersArray['to_0'] != null) { markersArray['to_0'].setMap(null); }
        markersArray['to_0'] = markersArray[marker_id];
        markersArray['to_0'].setIcon(defaults.DESTINATION_ICON);
        markersArray[marker_id] = null;
      }
      delay_request = true;
      add_address(value, function (results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
          window.to = results[0];
          direction();
        }
        delay_request = false;
      });
      $(to).parent().find('.favorite_star').removeClass('exist');
    }
    clean(index);
  };

  window.clearOverlays = clearOverlays;

  function summDistance(route) {
    var distance = 0;
    for (var j in route.legs) {
      if (!route.legs.hasOwnProperty(j)) { continue; }
      var leg = route.legs[j];
      distance += leg.distance.value;
    }
    return distance;
  }

  function summTime(route) {
    var duration = 0;
    for (var j in route.legs) {
      if (!route.legs.hasOwnProperty(j)) { continue; }
      var leg = route.legs[j];
      duration += leg.duration.value;
    }
    return duration;
  }

  /**
   * @param from
   * @param to
   * @param i
   * @param [icons]
   * @param [ids]
   * @param [center]
   */
  function paintDirect(from, to, i, icons, ids, center) {

    if (typeof icons === "undefined") { icons = []; }
    if (typeof ids === "undefined") { ids = []; }

    center = center || false;

    if (typeof directionsDisplays[i] !== "undefined") { directionsDisplays[i].setMap(null); }
    directionsDisplays[i] = new google.maps.DirectionsRenderer();

    if (typeof directionServices[i] === "undefined") { directionServices[i] = new google.maps.DirectionsService(); }
    var request = {
      origin: from.geometry.location,
      destination: to.geometry.location,
      travelMode: google.maps.DirectionsTravelMode.DRIVING,
      provideRouteAlternatives: true,
      unitSystem: google.maps.UnitSystem.IMPERIAL
    };

    directionServices[i].route(request, function (response, status) {
      if (status == google.maps.DirectionsStatus.OK) {
        var distanceObj = jQuery('#Request_distance');
        var timeObj = jQuery('#Request_time');

        var distance = parseFloat(distanceObj.val());
        var time = parseFloat(timeObj.val()) || 0;

        var route = response.routes[0];
        var temp_distance = summDistance(route);
        var temp_time = summTime(route);
        for(var l in  response.routes) {
          if (!response.routes.hasOwnProperty(l)) { continue; }
          var temp_distance2 = summDistance(response.routes[l]);
          var temp_time2 = summTime(response.routes[l]);
          if (temp_distance > temp_distance2) {
            route = response.routes[l];
            temp_distance = temp_distance2;
            temp_time = temp_time2;
          }
        }

        distance += temp_distance;
        time += temp_time;

        distanceObj.val(distance);
        timeObj.val(time);

        if (Paths[i] != null) { Paths[i].setMap(null); }
        Paths[i] = new google.maps.Polyline({
          path: route.overview_path,
          geodesic: true,
          strokeColor: '#FF4000',
          strokeOpacity: 1.0,
          strokeWeight: 2
        });
        Paths[i].setMap(Gmaps.map.serviceObject);
        placeMarker(route.legs[0].start_location, '', '', icons[0], ids[0], '');
        placeMarker(route.legs[0].end_location, '', '', icons[1], ids[1], '');
        curretMarkerIndex = null;

        latlngbounds.extend(route.legs[0].start_location);
        latlngbounds.extend(route.legs[0].end_location);
        if (center && Gmaps.map.serviceObject != null) {
          latlngbounds.extend(to.geometry.location);
          Gmaps.map.serviceObject.setCenter(latlngbounds.getCenter());
          Gmaps.map.serviceObject.fitBounds(latlngbounds);
        }
      }
    });
    directionsDisplays[i].setMap(Gmaps.map.serviceObject);
  }

  /**
   * @param [center]
   */
  window.direction = function (center) {
    if (Gmaps.map.serviceObject == null) {
      setTimeout(function() {window.direction(center);}, 1000);
      return;
    }

    if (typeof window.from !== "undefined" && typeof window.to !== "undefined") {

      if(typeof center == "undefined") { center = true; }

      jQuery('#Request_distance').val(0);
      jQuery('#Request_time').val(0);
      clearOverlays();
      clearDirections();

      var from, to;

      latlngbounds = new google.maps.LatLngBounds();

      to = false;

      for(var i = 0; i < window.current_to.length; i++) {
        var first =  i == 0;

        from = first ? window.from : to;
        to = window.current_to[i];

        paintDirect(
          from, to, i,
          [(first ? defaults.PICKUP_ICON : defaults.DESTINATION_ICON), defaults.DESTINATION_ICON],
          [(first ? 'from' : 'to_' + (i-1)), 'to_' + i],
          center
        );
      }
    }
  };

  window.add_address = function (address, callback) {
    var geocoder = new google.maps.Geocoder();
    if (geocoder) {
      geocoder.geocode({ 'address': address }, callback);
    }
  };

  function clean(index) {
    if (typeof index !== "undefined" && windowsArray.hasOwnProperty(index)) {
      windowsArray[index].close();
      //markersArray[index].setMap(null);
    }
  }

  /**
   * @param {String} id
   * @param {String} icon
   * @param {function} callback
   * @param {Object} [input_data]
   */
  function init_autocomplete(id, icon, callback, input_data) {
    input_data = input_data || {};
    var input = document.getElementById(id);

    var autocomplete = new google.maps.places.Autocomplete(input);
    autocomplete.bindTo('bounds', Gmaps.map.serviceObject);

    window.autocompletes[id] = autocomplete;

    var marker = new google.maps.Marker({map: Gmaps.map.serviceObject}); markersVisibleArray.push(marker);

    google.maps.event.addListener(autocomplete, 'place_changed', function () {
      clearOverlays(false);
      marker.setVisible(false);
      input.className = input.className.replace(' notfound ', '');
      var place = autocomplete.getPlace();
      if (!place.geometry) {
        input.className += '  notfound ';
        return;
      }

      var gAddress = new GoogleAddress(place.address_components, place.name);
      if (place.geometry.viewport) {
        Gmaps.map.serviceObject.fitBounds(place.geometry.viewport);
      } else {
        Gmaps.map.serviceObject.setCenter(place.geometry.location);
        Gmaps.map.serviceObject.setZoom(17);
      }
      marker.setIcon(({
        url: icon
      }));
      marker.setPosition(place.geometry.location);
      marker.setVisible(true);

      window.recheck_validators();
      window.change_address(input, gAddress.street(), gAddress.city(), place.geometry.location, false, gAddress.name());
      if (typeof callback == "function") {
        callback(place, input_data);
      }
    });
  }

  window.input_autocomplete = init_autocomplete;

  Gmaps.map.callback = function () {
    var marker = Gmaps.map.markers[0];
    if (marker) {
      google.maps.event.addListener(marker.serviceObject, 'dragend', function () {
        updateFormLocation(this.getPosition());
      });
    }

    google.maps.event.addListener(Gmaps.map.serviceObject, 'click', function (event) {
      if (delay_request) { return; }

      if (!window.can_click) { return; }

      var geocoder = new google.maps.Geocoder();
      if (geocoder) {
        geocoder.geocode({ 'address': event.latLng.lat() + ',' + event.latLng.lng() }, function (results, status) {
          if (status == google.maps.GeocoderStatus.OK) {
            //clearOverlays();
            if (curretMarkerIndex !== null) {
              markersArray[curretMarkerIndex].setMap(null);
            }
            placeMarker(
              event.latLng,
              results[0].address_components,
              results[0].formatted_address,
              defaults.POINT_ICON,
              undefined,
              results[0].name
            );
            updateFormLocation(event.latLng);
          }
        });
      }

    });

    init_autocomplete('Request_from', defaults.PICKUP_ICON, function(result) {
      window.from = result;
      direction();
    });
    init_autocomplete('Request_to_0', defaults.DESTINATION_ICON, function(result) {
      window.to = result;
      window.current_to[0] = result;
      direction();
    });
  };

  function updateFormLocation(latLng) {
    $('#centre_latitude').val(latLng.lat());
    $('#centre_longitude').val(latLng.lng());
    $('#centre_gmaps_zoom').val(Gmaps.map.serviceObject.getZoom());
  }

  /**
   * @param address_components
   * @param text
   * @param latLng
   * @param [name]
   * @param [marker_id]
   * @returns {*}
   */
  function generatPopupBlock(address_components, text, latLng, name, marker_id) {
    name = name || '';
    var gAddress = new GoogleAddress(address_components, name);
    var street = gAddress.street();
    var city = gAddress.city();
    name = gAddress.name();

    var html = jQuery('#map_popup2').html();
    html = html.
      replace(/__street__/g, street).
      replace(/__city__/g, city).
      replace(/__text__/g, text.replace(/'/gi, '&apos;')).
      replace(/__i__/gi, windowsArray.length).
      replace(/__name__/gi, name).
      replace(/__marker_id__/gi, marker_id).
      replace(/__lat__/gi, latLng.lat()).
      replace(/__lng__/gi, latLng.lng());
    return html;
  }

  /**
   * @param latLng
   * @param title
   * @param icon
   * @param [marker_id]
   * @returns {Array<google.maps.Marker>}
   */
  function putMarker(latLng, title, icon, marker_id) {
    var marker = new google.maps.Marker({
      position: latLng,
      map: Gmaps.map.serviceObject,
      draggable: false,
      title: title,
      icon: icon
    });
    curretMarkerIndex = markersArray.length;
    if (typeof marker_id !== "undefined") {
      if (markersArray[marker_id] != null) {
        markersArray[marker_id].setMap(null);
      }
      markersArray[marker_id] = marker;
    } else {
      marker_id = markersArray.length;
      markersArray.push(marker);
    }

    return [marker, marker_id];
  }

  /**
   * @param latLng
   * @param address_components
   * @param text
   * @param icon
   * @param [marker_id]
   * @param [name]
   */
  function placeMarker(latLng, address_components, text, icon, marker_id, name) {
    var array = putMarker(latLng, text, icon, marker_id);

    var marker = array[0];
    marker_id = array[1];

    name = name || '';

    if (typeof address_components !== "undefined" && address_components !== '') {
      var html = generatPopupBlock(address_components, text, latLng, name, marker_id);

      var myOptions = {
        content: html
        ,disableAutoPan: false
        ,maxWidth: 0
        ,pixelOffset: new google.maps.Size(40, -90)
        ,zIndex: null
        ,closeBoxMargin: "10px 10px 0 0"
        ,closeBoxURL: "http://www.google.com/intl/en_us/mapfiles/close.gif"
        ,infoBoxClearance: new google.maps.Size(1, 1)
        ,isHidden: false
        ,pane: "floatPane"
        ,enableEventPropagation: false
        ,closeHandler: function() {
          marker.setMap(null);
        }
      };

      if (infowindow != null) { infowindow.close(); }

      infowindow = new InfoBox(myOptions);
      infowindow.open(Gmaps.map.serviceObject, marker);
      windowsArray.push(infowindow);
    }
  }

  window.putMarker = putMarker;

  function clearOverlays(with_visible) {
    if (typeof with_visible === "undefined") { with_visible = true; }

    var i;
    for (i = 0; i < markersArray.length; i++) {
      if(markersArray[i] != null) { markersArray[i].setMap(null); }
    }
    markersArray.length = 0;

    for(i in markersArray) {
      if (!markersArray.hasOwnProperty(i)) { continue; }
      if(markersArray[i] != null) {
        markersArray[i].setMap(null);
        markersArray[i] = null;
      }
    }


    for (i = 0; i < Gmaps.map.markers.length; i++) {
      Gmaps.map.clearMarker(Gmaps.map.markers[i]);
    }

    if (with_visible) {
      for(i in markersVisibleArray) {
        if (!markersVisibleArray.hasOwnProperty(i)) { continue; }
        markersVisibleArray[i].setVisible(false);
      }
    }
  }

  function clearDirections() {
    var i;
    i = directionsDisplays.length-1;
    while(i > -1) {
      directionsDisplays[i].setMap(null);
      i--;
    }
    directionsDisplays.length = 0;

    i = Paths.length - 1;
    while(i > -1) {
      Paths[i].setMap(null);
      i--;
    }
    Paths.length = 0;
  }
  window.clearDirections = clearDirections;
});