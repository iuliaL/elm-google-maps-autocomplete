import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

import mockedPredictions from './predictions.json'
import mockedPlace from './place.json'

const app = Elm.Main.init({
  node: document.getElementById('root')
});

app.ports.logger.subscribe(message => {
  console.log('Logger port emitted a new message: ' + message);
});

app.ports.predictAddress.subscribe(function (text) {
  // if (!text) { return; }
  // var service = new google.maps.places.AutocompleteService();
  // var options = { input: text, types: ['address'] }
  // service.getPlacePredictions(options, function (predictions, status) {
  //   console.log("Got these results", predictions, 'status', status);

  //   if (status == 'OK') {
  //     app.ports.addressPredictions.send(predictions);
  //   } else app.ports.addressPredictions.send(status);
  // });


  console.log("Got these predictions", mockedPredictions);
  app.ports.addressPredictions.send(mockedPredictions);


});


app.ports.getPredictionDetails.subscribe(function (text) {
  var request = { placeId: text };
  var service = new google.maps.places.PlacesService(document.createElement('div'));
  service.getDetails(request, function (place, status) {
    console.log("Got this place", place, 'status', status);
    if (status == 'OK') {
      app.ports.addressDetails.send(JSON.stringify(place));
    } else app.ports.addressDetails.send(status);
  });


  // console.log("Got this place", mockedPlace);
  // app.ports.addressDetails.send(JSON.stringify(mockedPlace));

});

app.ports.initializeMap.subscribe(function (pos) {
  console.log("Initialize Map")
  var mapDiv = document.getElementById('map');
  console.log('position', pos);
  if (mapDiv) {
  // Map
  var myLatlng = new google.maps.LatLng(pos);
  var mapOptions = {
      zoom: 15,
      center: myLatlng
  };
  var gmap = new google.maps.Map(mapDiv, mapOptions);

  // Marker
  var marker = new google.maps.Marker({
      position: myLatlng,
      title: "Hello World!"
  });

  marker.setMap(gmap);

  // Listening for set marker event
  app.ports.moveMap.subscribe(function (pos) {
    console.log("received", pos);
    var myLatlng = new google.maps.LatLng(pos);
    gmap.setCenter(myLatlng);
    marker.setPosition(myLatlng)
  });

  } else {
    console.log ("Cant find map element");
}
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
