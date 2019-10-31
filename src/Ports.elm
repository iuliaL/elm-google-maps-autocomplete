port module Ports exposing (..)

import Json.Decode as Decode

import Map

-- console logging
port logger : String -> Cmd msg

-- Outgoing Ports

port predictAddress : String -> Cmd msg


port addressPredictions : (Decode.Value -> msg) -> Sub msg


port getPredictionDetails : String -> Cmd msg


port addressDetails : (String -> msg) -> Sub msg


port initializeMap : Map.JsObject -> Cmd msg


-- port initializeEditMap : Map.JsObject -> Cmd msg


port moveMap : Map.JsObject -> Cmd msg



-- Incoming Port

--  this was not requested
-- port mapMoved : (Map.JsObject -> msg) -> Sub msg