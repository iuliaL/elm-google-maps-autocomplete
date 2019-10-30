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
  var service = new google.maps.places.AutocompleteService();
  var options = { input: text, types: ['address'] }
  service.getPlacePredictions(options, function (predictions, status) {
    console.log("Got these results", predictions, 'status', status);
    // here predictions are sent back to Elm
    if (status == 'OK') {
      app.ports.addressPredictions.send(predictions);
    } else app.ports.addressPredictions.send(status);
  });
});


app.ports.getPredictionDetails.subscribe(function (text) {
  var request = { placeId: text };
  var service = new google.maps.places.PlacesService(document.createElement('div'));
  service.getDetails(request, function (place, status) {
    console.log("Got this place", place, 'status', status);
    if (status == 'OK') {
      app.ports.addressPredictions.send(JSON.stringify(place));
    } else app.ports.addressPredictions.send(status);
  });
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
