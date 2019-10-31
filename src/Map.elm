module Map exposing (..)


type alias Model
    = { latitude : Float
        , longtitude : Float
        }


init : Model
init =
        { latitude = 11.55408504200135
        , longtitude = 104.910961602369
        }


modify : Float -> Float -> Model -> Model
modify lat lng model =
        { model
            | latitude = lat
            , longtitude = lng
        }


type alias JsObject =
    { lat : Float
    , lng : Float
    }


toJsObject : Model -> JsObject
toJsObject model =
    { lat = model.latitude
    , lng = model.longtitude
    }
