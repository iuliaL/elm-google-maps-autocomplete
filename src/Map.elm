module Map exposing (..)


type alias Model
    = { lat : Float
        , lng : Float
        }


init : Model
init = { lat = 11.55408504200135
        , lng = 104.910961602369
        }


modify : Float -> Float -> Model -> Model
modify lat lng model =
        { model
            | lat = lat
            , lng = lng
        }
