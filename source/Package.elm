port module Package exposing (main)

import Html exposing (Html, button, div, text)
import Html.Attributes exposing (style, class)
import Html.Events exposing (onClick)
import McpaModel
import ParseMcpa exposing (McpaData, parseMcpa)
--import StatsMain
import StatsTreeMap


type alias Model =
    { mcpaModel : McpaModel.Model McpaData
    --, statsModel : StatsMain.Model
    }

port openTree : () -> Cmd msg

type Msg
    = OpenTree
    | OpenMap
    | OpenScatter
    | OpenProjection
    -- Taken from StatsTreeMap.elm -- should probably be removed
    | McpaMsg McpaModel.Msg
    {--| StatsMsg StatsMain.Msg
    | SetSelectedSites (List ( Int, String ))
    | SetSelectedNodes ( List Int, List Int )--}

-- TODO: this was very Frankensteiny
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        OpenTree ->
            (model, openTree ())
        OpenMap ->
            (model, Cmd.none)
        OpenScatter ->
            (model, Cmd.none)
        OpenProjection ->
            (model, Cmd.none)
        McpaMsg _ ->
            (model, Cmd.none)
        {--StatsMsg _ ->
            (model, Cmd.none)
        SetSelectedSites _ ->
            (model, Cmd.none)
        SetSelectedNodes _ ->
            (model, Cmd.none)--}


buttonStyle : Html.Attribute msg
buttonStyle = style [ ("width", "25%"), ("height", "40px"), ("vertical-align", "middle") ]

view : Model -> Html Msg
view model =
    div []
        [ button [ class "button", buttonStyle, onClick OpenTree ] [ text "Phylogenetic Tree" ]
        , button [ class "button", buttonStyle, onClick OpenMap ] [ text "Occurrence Map" ]
        , button [ class "button", buttonStyle, onClick OpenScatter ] [ text "Scatter Plot" ]
        , button [ class "button", buttonStyle, onClick OpenProjection ] [ text "Model Projection" ]
        ]

-- Clean this up!
init : McpaModel.Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( mcpaModel, mcpaCmd ) =
            McpaModel.init StatsTreeMap.parseData flags -- TODO: Move StatsTreeMap.parseData here?

        --( statsModel, statsCmd ) =
        --    StatsMain.init
    in
        ( { mcpaModel = mcpaModel } --, statsModel = statsModel }
        , Cmd.batch
            [ Cmd.map McpaMsg mcpaCmd -- TODO: Move StatsTreeMap.McpaMsg here?
        --    , Cmd.map StatsMsg statsCmd -- TODO: Move StatsTreeMap.StatsMsg here?
            ]
        )


-- Clean this up!
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
    {--[ McpaModel.subscriptions model.mcpaModel |> Sub.map McpaMsg
    , StatsMain.subscriptions model.statsModel |> Sub.map StatsMsg
    , sitesForNode SetSelectedSites
    , nodesForSites SetSelectedNodes
    ]
        |> Sub.batch--}


main : Program McpaModel.Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }