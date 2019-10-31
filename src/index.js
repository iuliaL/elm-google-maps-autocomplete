import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

const app = Elm.Main.init({
  node: document.getElementById('root')
});

app.ports.logger.subscribe(message => {
  console.log('Logger port emitted a new message: ' + message);
});

app.ports.predictAddress.subscribe(function (text) {
  if (!text) { return; }
  const service = new google.maps.places.AutocompleteService();
  const options = { input: text, types: ['address'] }
  service.getPlacePredictions(options, function (predictions, status) {
    console.log("Got these results", predictions, 'status', status);

    if (status == 'OK') {
      app.ports.addressPredictions.send(predictions);
    } else app.ports.addressPredictions.send(status);
  });

});


app.ports.getPredictionDetails.subscribe(function (placeId) {
  const request = { placeId };
  const service = new google.maps.places.PlacesService(document.createElement('div'));
  service.getDetails(request, function (place, status) {
    console.log("Got this place", place, 'status', status);
    if (status == 'OK') {
      app.ports.addressDetails.send(JSON.stringify(place));
    } else app.ports.addressDetails.send(status);
  });

});

app.ports.initializeMap.subscribe(function (pos) {
  const mapDiv = document.getElementById('map');
  if (mapDiv) {
    // Map
    const myLatlng = new google.maps.LatLng(pos);
    const mapOptions = {
      zoom: 15,
      center: myLatlng
    };
    const gmap = new google.maps.Map(mapDiv, mapOptions);

    // Listening for set place event
    app.ports.setPlace.subscribe(function (pos) {

      const marker = new google.maps.Marker({
        position: myLatlng,
        title: "Hello World!"
      });

      marker.setMap(gmap);
      const myLatlng = new google.maps.LatLng(pos);
      gmap.setCenter(myLatlng);
      marker.setPosition(myLatlng)
    });

  } else {
    console.log("Cant find map element");
  }
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
