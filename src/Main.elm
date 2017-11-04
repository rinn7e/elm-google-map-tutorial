module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Map
import Port


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type alias Model =
    { title : String
    , map : Map.Model
    , state : State
    }


type State
    = View
    | Edit


init : ( Model, Cmd Msg )
init =
    ( { title = "Elm Google Map"
      , map = Map.init
      , state = View
      }
    , Map.init
        |> Map.toJsObject
        |> Port.initializeMap
    )


type Msg
    = NoOp
    | EditMap
    | OnEditMapDrag Map.JsObject
    | SaveEditMap


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        EditMap ->
            ( { model | state = Edit }
            , model.map
                |> Map.toJsObject
                |> Port.initializeEditMap
            )

        OnEditMapDrag { lat, lng } ->
            ( { model | map = Map.modify lat lng model.map }
            , Cmd.none
            )

        SaveEditMap ->
            ( { model | state = View }
            , model.map
                |> Map.toJsObject
                |> Port.moveMap
            )


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text model.title ]
        , p [] [ text <| "Current pointer" ++ (toString <| Map.toJsObject model.map) ]
        , div []
            [ div [ id "map" ] []
            , button [ onClick EditMap ] [ text "Edit" ]
            ]
        , editView model
        ]


editView : Model -> Html Msg
editView model =
    div
        [ class <|
            case model.state of
                View ->
                    "hidden"

                Edit ->
                    ""
        ]
        [ hr [] []
        , div [ id "edit-map" ] []
        , button [ onClick SaveEditMap ] [ text "Done" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Port.mapMoved OnEditMapDrag
