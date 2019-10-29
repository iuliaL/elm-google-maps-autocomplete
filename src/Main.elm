module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, img, button, input)
import Html.Attributes exposing (src, style, placeholder, value)
import Html.Events exposing (onInput, onClick)



---- MODEL ----


type alias Model =
    { text: String }


init : ( Model, Cmd Msg )
init =
    ( { text = "" }, Cmd.none )



---- UPDATE ----


type Msg
  = Change String
     | Reset
--   | Submit


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Reset -> init

        Change input -> ( { model | text = input }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ 
        img [ src "/logo.svg" ] []
        , h1 [] [ text "My Elm App is working!" ]
        , input [ placeholder "Start typing...", value model.text, onInput Change ] []
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
