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

import Html
import Html.Attributes as A
import Json.Encode as E
import Dict
import Set
import McpaModel
import ParseMcpa exposing (McpaData, parseMcpa)
import McpaTreeView exposing (viewTree)
import StatsMain


port requestSitesForNode : Int -> Cmd msg


port sitesForNode : (List ( Int, String ) -> msg) -> Sub msg


port requestNodesForSites : List Int -> Cmd msg


port nodesForSites : (( List Int, List Int ) -> msg) -> Sub msg

port selectNode : (Int -> msg) -> Sub msg

type alias Model =
    { mcpaModel : McpaModel.Model McpaData
    , statsModel : StatsMain.Model
    }


type Msg
    = McpaMsg McpaModel.Msg
    | StatsMsg StatsMain.Msg
    | SetSelectedSites (List ( Int, String ))
    | SetSelectedNodes ( List Int, List Int )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ mcpaModel, statsModel } as model) =
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

        McpaMsg msg_ ->
            let
                ( mcpaModel, cmd ) =
                    McpaModel.update msg_ model.mcpaModel
            in
                ( { model | mcpaModel = mcpaModel }, Cmd.map McpaMsg cmd )

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


parseData : String -> ( List String, McpaData )
parseData data =
    case parseMcpa data of
        Ok result ->
            result

        Err err ->
            Debug.crash ("failed to decode MCPA matrix: " ++ err)


view : Model -> Html.Html Msg
view { mcpaModel, statsModel } =
    let
        selectedSiteIds =
            statsModel.selected |> Set.toList |> List.map toString |> String.join " "

        selectData cladeId =
            Dict.get ( cladeId, "Observed", mcpaModel.selectedVariable ) mcpaModel.data

        block color =
            Html.div
                [ A.style [ ( "width", "12px" ), ( "height", "12px" ), ( "background-color", color ), ( "display", "inline-block" ) ] ]
                []
    in
        Html.div [ A.style [ ( "font-family", "sans-serif" ) ] ]
            [ Html.div [ A.style [ ( "display", "flex" ), ( "justify-content", "space-around" ) ] ]
                [ viewTree mcpaModel True selectData |> Html.map McpaMsg ]
            ]


init : McpaModel.Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( mcpaModel, mcpaCmd ) =
            McpaModel.init parseData flags

        ( statsModel, statsCmd ) =
            StatsMain.init
    in
        ( { mcpaModel = mcpaModel, statsModel = statsModel }
        , Cmd.batch
            [ Cmd.map McpaMsg mcpaCmd
            , Cmd.map StatsMsg statsCmd
            --, initialized ()
            ]
        )


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
