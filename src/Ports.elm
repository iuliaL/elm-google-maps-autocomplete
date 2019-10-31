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


port initializeMap : Map.Model -> Cmd msg


port moveMap : Map.Model -> Cmd msg