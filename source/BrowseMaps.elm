port module Package exposing (main)

import Html exposing (Html, button, div, text)
import Html.Attributes exposing (style, class)
import Html.Events exposing (onClick)
import McpaModel
import ParseMcpa exposing (McpaData, parseMcpa)


type alias Model =
    { mcpaModel : McpaModel.Model McpaData
    }


type Msg
    = McpaMsg McpaModel.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        OpenTree ->
        McpaMsg _ ->
            (model, Cmd.none)


buttonStyle : Html.Attribute msg
buttonStyle = style [ ("width", "25%"), ("height", "40px"), ("vertical-align", "middle") ]


view : Model -> Html Msg
view model =
    div [ class "map-container" ]
        [ div [ class "map-image-container"]
              [ img [ class "map-image", src "https://cataas.com/cat" ] [] ]
        , div [ class "map-label-container"]
              [ span [ class "map-label" ] [ strong [] [text "Species Name: "], text "Bensoniella Oregona" ]
              , span [ class "map-label" ] [ strong [] [text "Model Algorithm: "], text "ATT_MAXENT" ]
              , span [ class "map-label" ] [ strong [] [text "Project Scenario Code: "], text "sax_simple_base" ]
              , span [ class "map-label" ] [ strong [] [text "Data Path: "], text "gridset/sdm/Bensoniella_oregona/prj_3785512.tif" ]
              ]
        ]


init : McpaModel.Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( mcpaModel, mcpaCmd ) =
            McpaModel.init StatsTreeMap.parseData flags
    in
        ( { mcpaModel = mcpaModel }
        , Cmd.batch
            [ Cmd.map McpaMsg mcpaCmd ]
        )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program McpaModel.Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }