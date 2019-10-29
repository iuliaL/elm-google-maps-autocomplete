module Main exposing (..)

import Browser
import ElmStreet.AutocompletePrediction exposing (AutocompletePrediction)
import ElmStreet.Place exposing (ComponentType(..), Place, getComponentName)

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
                Ok suggestions ->
                    ( { model | suggestions = suggestions }
                    , Cmd.none
                    )

                Err _ ->
                    ( model
                    , Cmd.none
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
        img [ src "/logo.svg" ] []
        , h1 [] [ text "My Elm App is working!" ]
        , input [ placeholder "Start typing...", value model.streetAddress, onInput Change ] []
        , div [] (List.map addressView model.suggestions)
        , button [ style "background-color" "#00f"
                , style "color" "#fff"
                , onClick Reset
             ]
                [ text "Reset" ]
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
