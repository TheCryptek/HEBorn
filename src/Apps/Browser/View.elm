module Apps.Browser.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Css exposing (pct, width, asPairs)
import Game.Data as GameData
import Apps.Browser.Messages exposing (Msg(..))
import Apps.Browser.Models exposing (Model, Browser)
import Apps.Browser.Menu.View exposing (menuView, menuNav, menuContent)
import Apps.Browser.Pages.Models as Pages
import Apps.Browser.Pages.View as Pages
import Apps.Browser.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


styles : List Css.Style -> Attribute Msg
styles =
    Css.asPairs >> style


view : GameData.Data -> Model -> Html Msg
view data ({ app } as model) =
    div
        [ menuContent
        , class [ Window, Content, Client ]
        ]
        [ viewToolbar app
        , viewPg data app.page
        , menuView model
        ]


renderToolbarBtn : Bool -> String -> msg -> Html msg
renderToolbarBtn active label callback =
    div
        [ class
            (if active then
                [ Btn ]
             else
                [ Btn, InactiveBtn ]
            )
        , onClick callback
        ]
        [ text label ]


viewToolbar : Browser -> Html Msg
viewToolbar browser =
    div [ class [ Toolbar ] ]
        [ div
            -- TODO: Add classes
            [ class
                (if (List.length browser.previousPages) > 0 then
                    [ Btn ]
                 else
                    [ Btn, InactiveBtn ]
                )
            , onClick GoPrevious
            ]
            [ text "<" ]
        , div
            [ class
                (if (List.length browser.nextPages) > 0 then
                    [ Btn ]
                 else
                    [ Btn, InactiveBtn ]
                )
            , onClick GoNext
            ]
            [ text ">" ]
        , div
            [ class
                (if (String.length browser.addressBar) > 0 then
                    [ Btn ]
                 else
                    [ Btn, InactiveBtn ]
                )
            ]
            [ text "%" ]
        , div
            [ class [ AddressBar ] ]
            [ Html.form
                [ onSubmit AddressEnter ]
                [ input
                    [ value browser.addressBar
                    , onInput UpdateAddress
                    ]
                    []
                ]
            ]
        ]


viewPg : GameData.Data -> Pages.Model -> Html Msg
viewPg data pg =
    div
        [ class [ PageContent ] ]
        [ (Html.map (always PageMsg) (Pages.view data pg)) ]



-- PAGES


pgWelcomeHost : String -> List (Html Msg)
pgWelcomeHost ip =
    [ div [ class [ LoginPageHeader ] ] [ text "No web server running" ]
    , div [ class [ LoginPageForm ] ]
        [ div []
            [ input [ placeholder "Password" ] []
            , text "E"
            ]
        ]
    , div [ class [ LoginPageFooter ] ]
        [ div []
            [ text "C"
            , br [] []
            , text "Crack"
            ]
        , div []
            [ text "M"
            , br [] []
            , text "AnyMap"
            ]
        ]
    ]
