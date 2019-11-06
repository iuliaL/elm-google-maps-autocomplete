module Map exposing (..)


type alias LatLng =
    { lat : Float
    , lng : Float
    }


type alias Model =
    LatLng


init : Model
init =
    { lat = 11.55408504200135
    , lng = 104.910961602369
    }


modify : LatLng -> Model -> Model
modify coordinates model =
    { model
        | lat = coordinates.lat
        , lng = coordinates.lng
    }
