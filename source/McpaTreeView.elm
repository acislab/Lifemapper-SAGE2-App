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


module McpaTreeView exposing (viewTree)

import Html
import Html.Attributes as A
import Html.Events
import LinearTreeView exposing (computeColor, drawTree, gradientDefinitions)
import McpaModel exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)


viewTree : Model data -> Bool -> (Int -> Maybe Float) -> Html.Html Msg
viewTree model redBlue selectData =
    let
        computeColor_ opacity cladeId =
            selectData cladeId
                |> Maybe.map (computeColor opacity)
                |> Maybe.withDefault "#ccc"

        ( treeHeight, grads, treeSvg ) =
            drawTree
                { computeColor = computeColor_
                , showBranchLengths = model.showBranchLengths
                , treeDepth = model.treeInfo.depth
                , totalLength = model.treeInfo.length
                , flaggedNodes = model.flaggedNodes
                , selectedNode = model.selectedNode
                , selectNode = SelectNode
                , redBlue = redBlue
                }
                "#ccc"
                model.treeInfo.root

        gradDefs =
            gradientDefinitions grads

        ( color0, color1 ) =
            ( computeColor 1.0 0.0, computeColor 1.0 1.0 )

        legend =
            Html.div
                [ A.style
                    [ ( "width", "100%" )
                    , ( "background", "linear-gradient(to right, " ++ color0 ++ ", " ++ color1 ++ ")" )
                    , ( "display", "flex" )
                    , ( "flex-direction", "row" )
                    , ( "justify-content", "space-between" )
                    , ( "margin", "0px 0" )
                    , ( "outline", "solid 2px" )
                    , ( "outline-offset", "-2px" )
                    ]
                ]
                [ Html.p [ A.style [ ( "margin", "3px 6px" ) ] ] [ Html.text "0.0" ]
                , Html.p [ A.style [ ( "margin", "3px" ) ] ] [ Html.text "Semipartial Correlation b/w Node and Selected Predictor" ]
                , Html.p [ A.style [ ( "margin", "3px 6px" ) ] ] [ Html.text "1.0" ]
                ]
    in
        Html.div
            [ A.style [ ( "display", "flex" ), ( "flex-direction", "column" ) ] ]
            [ legend
            , Html.div [ A.style [ ( "overflow-y", "auto" ) ] ]
                [ svg
                    [ width "560" -- TODO: get rid of these magic numbers!
                    , height (14 * treeHeight |> toString)
                    , viewBox ("0 0 40 " ++ toString treeHeight)
                    , A.style [ ( "background", "#000" ), ( "font-family", "sans-serif" ) ] -- TODO: let's get a better font :)
                    ]
                    (gradDefs :: treeSvg)
                ]
            ]
