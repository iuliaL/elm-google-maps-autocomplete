port module Ports exposing (..)

import Json.Decode as Decode

port logger : String -> Cmd msg

port predictAddress : String -> Cmd msg


port addressPredictions : (Decode.Value -> msg) -> Sub msg


port getPredictionDetails : String -> Cmd msg


port addressDetails : (String -> msg) -> Sub msg