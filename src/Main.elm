module Main exposing (..)

import Browser
import ElmStreet.AutocompletePrediction exposing (AutocompletePrediction)
import ElmStreet.Place exposing (ComponentType(..), Place)

import Html exposing (Html, text, div, h1, button, input, span, p)
import Html.Attributes exposing (src, placeholder, value, class, id, style)
import Html.Events exposing (onInput, onClick)
import Json.Decode as Decode

import Ports exposing (..)
import Map

---- MODEL ----


type alias Model =
    { streetAddress : String
    , suggestions : List AutocompletePrediction
    , showMenu: Bool
    , preselectedPrediction: Maybe AutocompletePrediction
    , selectedPlace : Maybe Place
    , error: Maybe String
    , map : Map.Model
    }

initialState = { streetAddress = ""
   , suggestions = []
   , showMenu = False
   , preselectedPrediction = Nothing -- here I wanted to implement keyboard events but ...
   , selectedPlace = Nothing
   , error = Nothing
   , map = Map.init
   }

init : ( Model, Cmd Msg )
init =
   ( initialState
   , Map.init
        |> Ports.initializeMap )



---- UPDATE ----

type Msg
    = Change String
    | AddressPredictions Decode.Value
    | DidSelectAddress String
    | AddressDetails String
    | Reset
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp -> (model, Cmd.none)
        Reset -> ( initialState , logger "Input was reset")

        Change text ->
            ( { model 
            | streetAddress = text,
            selectedPlace = Nothing  }
            , predictAddress text )

        DidSelectAddress placeId ->
            ( model
            , getPredictionDetails placeId
            )

        -- here we decode the suggestion into a Place then call the map move and set the marker
        AddressDetails placeJson ->
            let
                decodedResult =
                    Decode.decodeString ElmStreet.Place.decoder placeJson
            in
            case decodedResult of
                Ok place ->
                    let  { lat, lng } = place.geometry.location
                    in
                    ( { model |
                        streetAddress = place.formattedAddress
                        , selectedPlace = Just place
                        , showMenu = False
                        , suggestions = []
                        , map = Map.modify lat lng model.map
                    }
                    , setPlace { lat = lat , lng = lng }
                    )

                Err e ->
                    let error = Decode.errorToString e
                    in
                    ( { model | error = Just error }
                    , logger ("Got an error decoding place:" ++ error)
                    )

        --  here we get the google predictions
        AddressPredictions predictions ->
            let
                decodedPredictions =
                    Decode.decodeValue ElmStreet.AutocompletePrediction.decodeList predictions -- this comes from js interop
            in
            case decodedPredictions of
                Ok suggestions ->
                    ( { model | suggestions = suggestions, showMenu = True }
                    , Cmd.none
                    )

                Err e ->
                 let error = Decode.errorToString e
                 in
                    ( { model | error = Just error }
                    , logger ("Got an error decoding predictions:" ++ error)
                    )

---- VIEW ----
addressView : AutocompletePrediction -> Html Msg
addressView suggestion =
    div [ 
        onClick (DidSelectAddress suggestion.placeId) -- here DidSelectAddress acts as a dispathcer of the Msg
    ]
    [ text suggestion.description ]

errorView : Maybe String -> Html Msg
errorView error =
    case error of
        Just e ->
            div [ class "error"]
            [ text ("ERROR:" ++ e)]
        Nothing -> span [] []

dropdownView : Model -> Html Msg
dropdownView model = 
    if model.showMenu then
        div [class "dropdown"] (List.map addressView model.suggestions)
    else 
        span [] []
placeInfoView: Model -> Html Msg
placeInfoView model =
    case model.selectedPlace of
    Just place ->
        p [class "info"] [ text ("Current place: " ++ (String.fromFloat <| model.map.lat) ++ ", " ++  (String.fromFloat <| model.map.lng) )]
    Nothing ->
        p [class "info", style "visibility" "hidden"] [text ("Current coordinates: " ++ (String.fromFloat <| model.map.lat) ++ ", " ++  (String.fromFloat <| model.map.lng) )]


view : Model -> Html Msg
view model =
    div [ class "view"]
        [
        div [class "dropdown-wrapper"]
        [ 
             input [ placeholder "Search...", value model.streetAddress, onInput Change ] []
            , dropdownView model
        ]
        , button [ onClick Reset ][ text "Reset" ]
        , errorView model.error
        -- , p [class "info"] [ text ("Total results: " ++ String.fromInt (List.length model.suggestions))]
        , placeInfoView model
        , div []
            [ div [ id "map" ] []
            ]
        ]



---- PROGRAM ----
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ 
            addressPredictions AddressPredictions
            , addressDetails AddressDetails
     ]

main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
