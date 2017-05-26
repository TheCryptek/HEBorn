module Apps.TaskManager.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.CssHelpers
import Svg exposing (svg, polyline)
import Svg.Attributes as SvgA exposing (width, height, viewBox, fill, stroke, strokeWidth, points, preserveAspectRatio, fillOpacity, strokeOpacity)
import Css exposing (asPairs)
import Game.Models exposing (GameModel)
import Apps.TaskManager.Messages exposing (Msg(..))
import Apps.TaskManager.Models exposing (..)
import Apps.TaskManager.Menu.View exposing (menuView)
import Apps.TaskManager.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "taskmngr"


styles : List Css.Mixin -> Attribute Msg
styles =
    Css.asPairs >> style


toMegaValues : Float -> String
toMegaValues x =
    -- TODO: Move this function to a better place
    -- TODO: Use "round 2" from elm-round
    if (x > (10 ^ 9)) then
        toString (x / (10 ^ 9)) ++ " G"
    else if (x > (10 ^ 6)) then
        toString (x / (10 ^ 6)) ++ " M"
    else if (x > (10 ^ 3)) then
        toString (x / (10 ^ 3)) ++ " K"
    else
        toString (x) ++ " "


viewTaskRowUsage : ResourceUsage -> List (Html Msg)
viewTaskRowUsage usage =
    [ div [] [ text ((toMegaValues usage.cpu) ++ "Hz") ]
    , div [] [ text ((toMegaValues usage.mem) ++ "iB") ]
    , div [] [ text ((toMegaValues usage.down) ++ "bps") ]
    , div [] [ text ((toMegaValues usage.up) ++ "bps") ]
    ]


viewTaskRow : TaskEntry -> Html Msg
viewTaskRow entry =
    div [ class [ EntryDivision ] ]
        [ div []
            [ div [] [ text entry.title ]
            , div [] [ text "Target: ", text entry.target ]
            , div []
                [ text "File: "
                , text entry.appFile
                , span [] [ text (toString entry.appVer) ]
                ]
            ]
        , div []
            [ text
                (toString
                    (1
                        - (toFloat entry.etaNow)
                        / (toFloat entry.etaTotal)
                    )
                )
            ]
        , div [] (viewTaskRowUsage entry.usage)
        ]


viewTasksTable : Entries -> Html Msg
viewTasksTable entries =
    div [ class [ TaskTable ] ]
        ([ div [ class [ EntryDivision ] ]
            -- TODO: Hide when too small (responsive design)
            [ div [] [ text "Process" ]
            , div [] [ text "ETA" ]
            , div [] [ text "Resources" ]
            ]
         ]
            ++ (List.map viewTaskRow entries)
        )


viewGraphUsage : String -> String -> List Float -> Float -> Html Msg
viewGraphUsage title color history limit =
    let
        sz =
            toFloat ((List.length history) - 1)
    in
        div [ class [ Graph ] ]
            [ text title
            , br [] []
            , svg
                [ SvgA.width "100%"
                , SvgA.height "50"
                , SvgA.preserveAspectRatio "none"
                , viewBox "0 0 1 1"
                ]
                [ polyline
                    [ SvgA.fill color
                    , SvgA.stroke color
                    , SvgA.strokeOpacity "0.9"
                    , SvgA.fillOpacity "0.4"
                    , SvgA.strokeWidth "0.012"
                    , SvgA.points
                        (String.join " "
                            ((List.indexedMap
                                (\i x ->
                                    String.concat
                                        [ toString (1 - toFloat (i) / sz)
                                        , ","
                                        , toString (1 - x / limit)
                                        ]
                                )
                                history
                             )
                                ++ [ "0,1", "1,1" ]
                            )
                        )
                    ]
                    []
                ]
            ]


viewTotalResources : TaskManager -> Html Msg
viewTotalResources ({ historyCPU, historyMem, historyDown, historyUp, limits } as app) =
    div [ class [ BottomGraphsRow ] ]
        [ viewGraphUsage "CPU" "green" historyCPU limits.cpu
        , viewGraphUsage "Memory" "blue" historyMem limits.mem
        , viewGraphUsage "Downlink" "red" historyDown limits.down
        , viewGraphUsage "Uplink" "yellow" historyUp limits.up
        ]


view : GameModel -> Model -> Html Msg
view game ({ app } as model) =
    div [ class [ MainLayout ] ]
        [ viewTasksTable app.tasks
        , viewTotalResources app
        ]
