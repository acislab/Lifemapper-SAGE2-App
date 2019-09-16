module Dropdown exposing (..)

import Html
import Html.Attributes as A
import Html.Events
-- import List.Extra as List

type Msg
    = Select String
    | Open
    | Close
    | Toggle


-- TODO: how do we set default values?
type alias Style =
    { lineHeight : Int -- 19
    , borderWidth : Int -- 2
    , style : List ( String, String ) -- [ ( "width", "300px" ) ]
    }


type alias State =
    { open : Bool
    , items : List String
    , selection : Maybe String
    }


viewDropdown : State -> Style -> Html.Html Msg
viewDropdown state style =
    let
        selectorHeight =
            case state.open of
                False ->
                    style.lineHeight

                True ->
                    (style.lineHeight + style.borderWidth) * List.length state.items - style.borderWidth
    in
    Html.div
        [ A.style
            [ ( "position", "relative" )
            , ( "display", "flex" )
            , ( "justify-content", "flex-start" )
            ]
        ]
        [ Html.span [ A.style [ ( "margin", "0px 4px" ) ] ] [ Html.text "Predictor:" ]
        , Html.div []
            [ Html.ul
                [ A.classList [ ( "drop-down", True ), ( "closed", not state.open ) ]
                , A.style <|
                    [ ( "height", toString selectorHeight ) ]
                        ++ style.style
                ]
                (List.concat
                    [ [ Html.li []
                            [ Html.a
                                [ A.href "#"
                                , A.class "nav-button"
                                , Html.Events.onClick Toggle
                                ]
                                [ Html.text <| Maybe.withDefault "" state.selection ]
                            ]
                      ]
                    , state.items
                        |> List.indexedMap
                            (\i v ->
                                Html.li []
                                    [ Html.a
                                        [ A.href "#"
                                        , A.value (toString i)
                                        , Html.Events.onClick (Select v)
                                        ]
                                        [ Html.text v ]
                                    ]
                            )
                    ]
                )
            ]
        ]


update : Msg -> State -> ( State, Cmd Msg )
update msg state =
    case msg of
        Select item ->
            ( { state
                | selection = Just item
                , open = False
              }
            , Cmd.none
            )

        Open ->
            ( { state
                | open = True
              }
            , Cmd.none
            )

        Close ->
            ( { state
                | open = False
              }
            , Cmd.none
            )

        Toggle ->
            ( { state
                | open = not state.open
              }
            , Cmd.none
            )
