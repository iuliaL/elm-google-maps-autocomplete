port module Ports exposing (..)

import Json.Decode as Decode

import Map

-- Console logging

port logger : String -> Cmd msg

-- Outgoing Ports

port predictAddress : String -> Cmd msg


port addressPredictions : (Decode.Value -> msg) -> Sub msg


port getPredictionDetails : String -> Cmd msg -- send 


port addressDetails : (String -> msg) -> Sub msg


port initializeMap : Map.Model -> Cmd msg


port setPlace : Map.Model -> Cmd msg