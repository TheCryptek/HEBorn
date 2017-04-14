module OS.WindowManager.Models
    exposing
        ( Model
        , initialModel
        , Window
        , WindowID
        , Position
        , Windows
        , defaultSize
        , openWindow
        , closeWindow
        , getOpenWindows
        , filterAppWindows
        , updateWindowPosition
        , windowsFoldr
        , hasWindowOpen
        , toggleMaximizeWindow
        , minimizeWindow
        )

import Dict
import Uuid
import Random.Pcg exposing (Seed, step, initialSeed)
import Draggable
import OS.WindowManager.Windows exposing (GameWindow(..))


type alias Model =
    { windows : Windows
    , seed : Seed
    , drag : Draggable.State WindowID
    , dragging : Maybe WindowID
    , focus : Maybe WindowID
    , highestZ : Int
    }


type alias WindowID =
    String


type alias Position =
    { x : Float
    , y : Float
    , z : Int
    }


type alias Size =
    { width : Float
    , height : Float
    }


type WindowState
    = Open
    | Minimized


type alias Window =
    { id : WindowID
    , window : GameWindow
    , state : WindowState
    , position : Position
    , title : String
    , size : Size
    , maximized : Bool
    }


type alias Windows =
    Dict.Dict WindowID Window


initialPosition : Int -> Position
initialPosition off =
    Position (toFloat (32 * off)) (44 + (toFloat (32 * off))) off



-- initialPosition: 44 is header height hardwritten


initialWindows : Dict.Dict WindowID Window
initialWindows =
    Dict.empty


defaultSize : Size
defaultSize =
    Size 600 400


initialModel : Model
initialModel =
    { windows = initialWindows
    , seed = initialSeed 42
    , drag = Draggable.init
    , dragging = Nothing
    , focus = Nothing
    , highestZ = 1
    }


newWindow : Model -> GameWindow -> ( Window, Seed )
newWindow model window =
    let
        ( id, seed ) =
            step Uuid.uuidGenerator model.seed

        window_ =
            { id = (Uuid.toString id)
            , window = window
            , state = Open
            , position = initialPosition (Dict.size model.windows)
            , title = "Sem titulo"
            , size = defaultSize
            , maximized = False
            }
    in
        ( window_, seed )


filterAppMinimizedWindows : Windows -> GameWindow -> Windows
filterAppMinimizedWindows windows app =
    Dict.filter
        (\id oWindow ->
            ((oWindow.state == Minimized)
                && (oWindow.window == app)
            )
        )
        windows


countAppMinimizedWindow : Model -> GameWindow -> Int
countAppMinimizedWindow model app =
    Dict.size
        (filterAppMinimizedWindows model.windows app)


unMinimizeIfGameWindow : Window -> GameWindow -> Window
unMinimizeIfGameWindow window app =
    if (window.window == app) then
        { window | state = Open }
    else
        window


openWindow : Model -> GameWindow -> ( Windows, Seed, Maybe WindowID )
openWindow model window =
    if ((countAppMinimizedWindow model window) > 0) then
        ( Dict.map (\id oWindow -> (unMinimizeIfGameWindow oWindow window)) model.windows
        , model.seed
        , Nothing
        )
    else
        let
            ( window_, seed_ ) =
                newWindow model window

            windows_ =
                Dict.insert window_.id window_ model.windows
        in
            ( windows_, seed_, Just window_.id )


closeWindow : Model -> WindowID -> Windows
closeWindow model id =
    Dict.remove id model.windows


getOpenWindows : Model -> Windows
getOpenWindows model =
    Dict.filter (\id window -> window.state == Open) model.windows


filterAppWindows : Windows -> GameWindow -> Windows
filterAppWindows windows app =
    Dict.filter (\id window -> window.window == app) windows


windowsFoldr : (comparable -> v -> a -> a) -> a -> Dict.Dict comparable v -> a
windowsFoldr fun acc windows =
    Dict.foldr (fun) acc windows


getWindow : Model -> WindowID -> Maybe Window
getWindow model id =
    Dict.get id model.windows


updateWindowPosition : Model -> ( Float, Float ) -> Windows
updateWindowPosition model delta =
    case model.dragging of
        Nothing ->
            model.windows

        Just id ->
            let
                windows_ =
                    case (getWindow model id) of
                        Nothing ->
                            model.windows

                        Just window ->
                            let
                                ( dx, dy ) =
                                    delta

                                x_ =
                                    window.position.x + dx

                                y_ =
                                    window.position.y + dy

                                position_ =
                                    Position x_ y_ window.position.z

                                window_ =
                                    { window | position = position_ }

                                update_ w =
                                    case w of
                                        Just window ->
                                            Just window_

                                        Nothing ->
                                            Nothing

                                windows_ =
                                    Dict.update id update_ model.windows
                            in
                                windows_
            in
                windows_


hasWindowOpen : Model -> GameWindow -> Bool
hasWindowOpen model window =
    let
        filter id w =
            w.state == Open && w.window == window

        open =
            Dict.filter filter model.windows
    in
        not (Dict.isEmpty open)


toggleMaximizeWindow : Model -> WindowID -> Windows
toggleMaximizeWindow model id =
    case (getWindow model id) of
        Nothing ->
            model.windows

        Just window ->
            let
                window_ =
                    { window | maximized = not window.maximized }

                update_ w =
                    case w of
                        Just window ->
                            Just window_

                        Nothing ->
                            Nothing

                windows_ =
                    Dict.update id update_ model.windows
            in
                windows_


minimizeWindow : Model -> WindowID -> Windows
minimizeWindow model id =
    case (getWindow model id) of
        Nothing ->
            model.windows

        Just window ->
            let
                window_ =
                    { window | state = Minimized }

                update_ w =
                    case w of
                        Just window ->
                            Just window_

                        Nothing ->
                            Nothing

                windows_ =
                    Dict.update id update_ model.windows
            in
                windows_
