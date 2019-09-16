{-
   Copyright (C) 2018, University of Kansas Center for Research

   Lifemapper Project, lifemapper [at] ku [dot] edu,
   Biodiversity Institute,
   1345 Jayhawk Boulevard, Lawrence, Kansas, 66045, USA

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or (at
   your option) any later version.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
   02110-1301, USA.
-}


port module TreeView exposing (..)

import Dict
import Dropdown exposing (viewDropdown)
import Html
import Html.Attributes as A
import Html.Events
import Json.Encode as E
import List.Extra as List
import McpaModel
import McpaTreeView exposing (viewTree)
import ParseMcpa exposing (McpaData, parseMcpa)
import Set
import StatsMain


port requestSitesForNode : Int -> Cmd msg


port sitesForNode : (List ( Int, String ) -> msg) -> Sub msg


port requestNodesForSites : List Int -> Cmd msg


port nodesForSites : (( List Int, List Int ) -> msg) -> Sub msg


port selectNode : (Int -> msg) -> Sub msg


type alias Model =
    { mcpaModel : McpaModel.Model McpaData
    , statsModel : StatsMain.Model
    , variableDropdown : Dropdown.State
    , showBranchLengths : Bool
    }


type Msg
    = McpaMsg McpaModel.Msg
    | StatsMsg StatsMain.Msg
    | VariableDropdownMsg Dropdown.Msg
    | SetSelectedSites (List ( Int, String ))
    | SetSelectedNodes ( List Int, List Int )
    | ToggleBranchLengths


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        mcpaModel =
            model.mcpaModel

        statsModel =
            model.statsModel
    in
    case msg of
        SetSelectedNodes ( leftNodes, rightNodes ) ->
            ( { model | mcpaModel = { mcpaModel | selectedNode = Nothing, flaggedNodes = ( leftNodes, rightNodes ) } }
            , Cmd.none
            )

        SetSelectedSites sites ->
            let
                flagged =
                    sites
                        |> List.filterMap
                            (\( id, side ) ->
                                case side of
                                    "left" ->
                                        Just ( id, "blue" )

                                    "right" ->
                                        Just ( id, "red" )

                                    "both" ->
                                        Just ( id, "purple" )

                                    _ ->
                                        Nothing
                            )
                        |> Dict.fromList
            in
            ( { model | statsModel = { statsModel | flagged = flagged, selected = Set.empty } }, Cmd.none )

        McpaMsg ((McpaModel.SelectNode n) as msg_) ->
            let
                ( mcpaModel, cmd ) =
                    McpaModel.update msg_ model.mcpaModel
            in
            { model | mcpaModel = { mcpaModel | flaggedNodes = ( [], [] ) } }
                ! [ Cmd.map McpaMsg cmd, requestSitesForNode n ]

        StatsMsg msg_ ->
            let
                ( statsModel, cmd ) =
                    StatsMain.update msg_ model.statsModel

                getNodes =
                    if statsModel.selected /= model.statsModel.selected then
                        requestNodesForSites <| Set.toList statsModel.selected

                    else
                        Cmd.none
            in
            { model | statsModel = statsModel } ! [ Cmd.map StatsMsg cmd, getNodes ]

        VariableDropdownMsg msg_ ->
            let
                ( variableDropdown, msg__ )
                    = Dropdown.update msg_ model.variableDropdown
            in
            ( { model | variableDropdown = variableDropdown }, Cmd.none )

        -- TODO
        ToggleBranchLengths ->
            ( { model | showBranchLengths = not model.showBranchLengths }, Cmd.none )


parseData : String -> ( List String, McpaData )
parseData data =
    case parseMcpa data of
        Ok result ->
            result

        Err err ->
            Debug.crash ("failed to decode MCPA matrix: " ++ err)


view : Model -> Html.Html Msg
view model =
    let
        mcpaModel =
            model.mcpaModel

        statsModel =
            model.statsModel

        variableDropdown =
            model.variableDropdown

        selectedSiteIds =
            statsModel.selected |> Set.toList |> List.map toString |> String.join " "

        selectData cladeId =
            Dict.get ( cladeId, "Observed", mcpaModel.selectedVariable ) mcpaModel.data

        block color =
            Html.div
                [ A.style [ ( "width", "12px" ), ( "height", "12px" ), ( "background-color", color ), ( "display", "inline-block" ) ] ]
                []

        toggleBranchLengths =
            Html.div []
                [ Html.label []
                    [ Html.input
                        [ A.type_ "checkbox"
                        , A.checked model.showBranchLengths
                        , A.readonly True
                        , Html.Events.onClick ToggleBranchLengths
                        ]
                        []
                    , Html.text "Show branch lengths"
                    ]
                ]
    in
    Html.div [ A.style [ ( "font-family", "sans-serif" ) ] ]
        [ Html.div [ A.style [ ( "display", "flex" ), ( "justify-content", "space-around" ) ] ]
            [ Html.div
                [ A.style [ ( "display", "flex" ), ( "flex-direction", "column" ) ] ]
                -- Variable dropdown and branch options
                [ Html.div
                    [ A.style
                        [ ( "display", "flex" )
                        , ( "justify-content", "space-between" )
                        , ( "flex-shrink", "0" )
                        , ( "margin", "2px 4px" )
                        ]
                    ]
                    [ Html.div [] []
                    , viewDropdown
                        model.variableDropdown
                        { lineHeight = 19
                        , borderWidth = 2
                        , style = [ ( "width", "300px" ) ]
                        }
                        |> Html.map VariableDropdownMsg
                    --, toggleBranchLengths
                    , Html.div [] []
                    ]

                -- Phylogenetic tree
                , viewTree mcpaModel True selectData |> Html.map McpaMsg

                {--TODO: turn this into an info badge
                , Html.p [ A.style [ ( "width", "560px" ) ] ]
                    [ Html.text <|
                        "Node color indicates correlation between sister clades and "
                            ++ "the selected predictor.  Selecting a node highlights aggregated "
                            ++ "presence of species of one clade in blue and the other in red.  "
                            ++ "Sites where species of both sides are present are purple."
                    ]
                --}
                ]
            ]
        ]


init : McpaModel.Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( mcpaModel, mcpaCmd ) =
            McpaModel.init parseData flags

        ( statsModel, statsCmd ) =
            StatsMain.init

        -- TODO: what's up with this?
        items =
            statsModel.variables
                |> List.partition (\v -> v == "Env - Adjusted R-squared" || v == "BG - Adjusted R-squared")
                |> (\( adjustedRSquareds, rest ) -> adjustedRSquareds ++ rest)
    in
    (
        { mcpaModel = mcpaModel
        , statsModel = statsModel
        , variableDropdown =
            { open = False
            , items = items
            , selection = List.getAt 1 items
            }
        , showBranchLengths = False
        }
    , Cmd.batch
        [ Cmd.map McpaMsg mcpaCmd
        , Cmd.map StatsMsg statsCmd
        ]
    )



-- TODO: are all of these necessary?


subscriptions : Model -> Sub Msg
subscriptions model =
    [ McpaModel.subscriptions model.mcpaModel |> Sub.map McpaMsg
    , StatsMain.subscriptions model.statsModel |> Sub.map StatsMsg
    , sitesForNode SetSelectedSites
    , nodesForSites SetSelectedNodes

    --, selectNode SetNode
    ]
        |> Sub.batch


main : Program McpaModel.Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
