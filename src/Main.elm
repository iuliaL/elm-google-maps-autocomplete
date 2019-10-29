module Main exposing (..)

import Browser
import ElmStreet.AutocompletePrediction exposing (AutocompletePrediction)
import ElmStreet.Place exposing (ComponentType(..), Place)

import Html exposing (Html, text, div, h1, img, button, input)
import Html.Attributes exposing (src, style, placeholder, value)
import Html.Events exposing (onInput, onClick)
import Json.Decode as Decode

import Ports exposing (..)

---- MODEL ----


type alias Model =
    { streetAddress : String
    , suggestions : List AutocompletePrediction
    , selectedPlace : Maybe Place }


init : ( Model, Cmd Msg )
init =
   ( Model "" [] Nothing, Cmd.none )



---- UPDATE ----


-- type Msg
--   = Change String
--      | Reset
-- --   | Submit

type Msg
    = Change String
    | AddressPredictions Decode.Value
    -- | DidSelectAddress String
    -- | AddressDetails String
    | Reset


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Reset -> ( { streetAddress = "", suggestions = [], selectedPlace = Nothing } , logger "Input was reset")

        Change text ->
            ( { model | streetAddress = text }, predictAddress text )

        AddressPredictions predictions ->
            let
                decodedResult =
                    Decode.decodeValue ElmStreet.AutocompletePrediction.decodeList predictions
            in
            case decodedResult of
                Ok result ->
                    ( { model | suggestions = result }
                    , Cmd.none
                    )

                Err e ->
                    ( model
                    , logger ("Got an error decoding:" ++ Decode.errorToString e)
                    )



---- VIEW ----
addressView : AutocompletePrediction -> Html Msg
addressView suggestion =
    div [ 
        -- onClick (DidSelectAddress suggestion.placeId)
    ]
    [ text suggestion.description ]

view : Model -> Html Msg
view model =
    div []
        [ 
        h1 [] [ text "Paack" ]
        , input [ placeholder "Search...", value model.streetAddress, onInput Change ] []
        , div [] (List.map addressView model.suggestions)
        , div [] [ text ("Total results:" ++ String.fromInt (List.length model.suggestions))]
        , button [ style "background-color" "#00f"
                , style "color" "#fff"
                , onClick Reset
             ]
                [ text "Reset" ]
        ]



---- PROGRAM ----
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ addressPredictions AddressPredictions
    -- addressDetails AddressDetails
     ]

main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
