module Main exposing (..)

import Browser
import Html exposing (Html, button, div, h1, input, p, span, text)
import Html.Attributes exposing (class, id, placeholder, src, style, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as Decode
import Map
import Ports exposing (..)



---- MODEL ----


type alias AutocompletePrediction =
    { description : String
    , placeId : String
    }


type alias Place =
    { coordinates: Map.LatLng
    , formattedAddress : String
    }


type alias Model =
    { streetAddress : String
    , suggestions : List AutocompletePrediction
    , showMenu : Bool
    , preselectedPrediction : Maybe AutocompletePrediction
    , selectedPlace : Maybe Place
    , error : Maybe String
    , map : Map.Model
    }


initialState =
    { streetAddress = ""
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
    , Map.init -- set some initial position for the map
        |> Ports.initializeMap -- create the map
    )



---- UPDATE ----


type Msg
    = Change String
    | GotAddressPredictions Decode.Value -- a value to decode
    | DidSelectAddress String
    | GotAddressDetails String
    | Reset
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Reset ->
            ( initialState, Ports.logger "Input was reset" )

        Change text ->
            ( { model
                | streetAddress = text
                , selectedPlace = Nothing
              }
            , Ports.predictAddress text
            )

        DidSelectAddress placeId ->
            ( model
            , Ports.getPredictionDetails placeId
            )

        -- here we decode the suggestion into a Place then call the map move and set the marker
        GotAddressDetails placeJson ->
            let
                latLngDecoder =
                    Decode.map2 Map.LatLng
                        (Decode.field "lat" Decode.float)
                        (Decode.field "lng" Decode.float)

                placeDecoder : Decode.Decoder Place
                placeDecoder =
                    Decode.map2 Place
                        (Decode.field "geometry"
                            (Decode.field "location"
                                latLngDecoder
                            )
                        )
                        (Decode.field "formatted_address" Decode.string)

                decodedResult : Result Decode.Error Place
                decodedResult =
                    Decode.decodeString placeDecoder placeJson
            in
            case decodedResult of
                Ok place ->
                    ( { model
                        | streetAddress = place.formattedAddress
                        , selectedPlace = Just place
                        , showMenu = False
                        , suggestions = []
                        , map = Map.modify place.coordinates model.map
                      }
                    , setPlace place.coordinates
                    )

                Err e ->
                    let
                        error =
                            Decode.errorToString e
                    in
                    ( { model | error = Just error }
                    , Ports.logger ("Got an error decoding place:" ++ error)
                    )

        --  here we get the google predictions and we decode them
        GotAddressPredictions predictions ->
            let
                predictionDecoder : Decode.Decoder AutocompletePrediction
                predictionDecoder =
                    Decode.map2 AutocompletePrediction
                        (Decode.field "description" Decode.string)
                        (Decode.field "place_id" Decode.string)

                decodePredictionList : Decode.Decoder (List AutocompletePrediction)
                decodePredictionList =
                    Decode.list predictionDecoder

                decodedPredictions : Result Decode.Error (List AutocompletePrediction)
                decodedPredictions =
                    Decode.decodeValue decodePredictionList predictions

                -- this comes from js interop
            in
            case decodedPredictions of
                Ok suggestions ->
                    ( { model | suggestions = suggestions, showMenu = True }
                    , Cmd.none
                    )

                Err e ->
                    let
                        error =
                            Decode.errorToString e
                    in
                    ( { model | error = Just error }
                    , Ports.logger ("Got an error decoding predictions:" ++ error)
                    )



---- VIEW ----


addressView : AutocompletePrediction -> Html Msg
addressView suggestion =
    div
        [ onClick (DidSelectAddress suggestion.placeId) -- here DidSelectAddress acts as a dispathcer of the Msg
        ]
        [ text suggestion.description ]


errorView : Maybe String -> Html Msg
errorView error =
    case error of
        Just e ->
            div [ class "error" ]
                [ text ("ERROR: " ++ e) ]

        Nothing ->
            span [] []


dropdownView : Model -> Html Msg
dropdownView model =
    if model.showMenu then
        div [ class "dropdown" ] (List.map addressView model.suggestions)

    else
        span [] []


placeInfoView : Model -> Html Msg
placeInfoView model =
    case model.selectedPlace of
        Just place ->
            p [ class "info" ] [ text ("Current place: " ++ (String.fromFloat <| model.map.lat) ++ ", " ++ (String.fromFloat <| model.map.lng)) ]

        Nothing ->
            p [ class "info", style "visibility" "hidden" ]
                [ text ("Current coordinates: " ++ (String.fromFloat <| model.map.lat) ++ ", " ++ (String.fromFloat <| model.map.lng)) ]


view : Model -> Html Msg
view model =
    div [ class "view" ]
        [ div [ class "dropdown-wrapper" ]
            [ input [ placeholder "Search...", value model.streetAddress, onInput Change ] []
            , dropdownView model
            ]
        , button [ onClick Reset ] [ text "Reset" ]
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
    Sub.batch
        [ Ports.addressPredictions GotAddressPredictions
        , Ports.addressDetails GotAddressDetails
        ]


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
