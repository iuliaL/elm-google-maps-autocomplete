module Main exposing (..)

import Browser
import ElmStreet.AutocompletePrediction exposing (AutocompletePrediction)
import ElmStreet.Place exposing (ComponentType(..), Place)

import Html exposing (Html, text, div, h1, img, button, input, span)
import Html.Attributes exposing (src, style, placeholder, value, class)
import Html.Events exposing (onInput, onClick)
import Json.Decode as Decode

import Ports exposing (..)

---- MODEL ----


type alias Model =
    { streetAddress : String
    , suggestions : List AutocompletePrediction
    , places: List Place
    , showMenu: Bool
    , preselectedPrediction: Maybe AutocompletePrediction
    , selectedPlace : Maybe Place
    , error: Maybe String
    }

initialState = { streetAddress = ""
   , suggestions = []
   , places = []
   , showMenu = False
   , selectedPlace = Nothing
   , preselectedPrediction = Nothing
   , error = Nothing

   }

init : ( Model, Cmd Msg )
init =
   ( initialState
   , Cmd.none )



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

        -- here we decode the suggestion into a Place
        AddressDetails placeJson ->
            let
                decodedResult =
                    Decode.decodeString ElmStreet.Place.decoder placeJson
            in
            case decodedResult of
                Ok place ->
                    ( { model | streetAddress = place.formattedAddress
                    , selectedPlace = Just place
                    , showMenu = False }
                    , Cmd.none
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


-- dummyPrediction: AutocompletePrediction
-- dummyPrediction =  { description = "Description"
--     , id = "123"
--     , matcheSubstrings = []
--     , placeId = ""
--     , reference = "Ref"
--     , structuredFormatting = { mainText = ""
--     , mainTextPredictionSubstrings = []
--     , secondaryText = ""
--     }
--     , terms = []
--     , types = []
--     }

-- dummyPlaceForTheDefault: Place
-- dummyPlaceForTheDefault = { 
--     addressComponents = [ ]
--     , adrAddress = "Some address"
--     , formattedAddress = "Some formatted address"
--     , geometry = {
--         location = {
--             lat = 40.730610,
--             lng = -73.935242
--         },
--         viewport = 
--             { south = 0
--             , west = 0
--             , north = 0
--             , east = 0
--          }

--     }
--     , icon = "Icont here"
--     , id = "1234"
--     , name = "Dummy Place"
--     , placeId = "Dummy Place id"
--     , reference = "Ref"
--     , scope = "Scope"
--     , types = []
--     , url = "url here"
--     , utcOffset = 0
--     , vicinity = Nothing
--     }

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

view : Model -> Html Msg
view model =
    div [ class "view"]
        [ 
        h1 [] [ text "Places" ]
        , input [ placeholder "Search...", value model.streetAddress, onInput Change ] []
        , button [ onClick Reset ][ text "Reset" ]
        , dropdownView model
        , errorView model.error
        , div [style "color" "#666"] [ text ("Total results:" ++ String.fromInt (List.length model.suggestions))]
        
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
