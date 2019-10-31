module Map exposing (..)


type Model
    = Internal
        { latitude : Float
        , longtitude : Float
        }


init : Model
init =
    Internal
        { latitude = 11.55408504200135
        , longtitude = 104.910961602369
        }


modify : Float -> Float -> Model -> Model
modify latitude longtitude (Internal model) =
    Internal
        { model
            | latitude = latitude
            , longtitude = longtitude
        }


type alias JsObject =
    { lat : Float
    , lng : Float
    }


toJsObject : Model -> JsObject
toJsObject (Internal model) =
    { lat = model.latitude
    , lng = model.longtitude
    }
