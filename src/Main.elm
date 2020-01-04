-- module Main exposing (main)

-- import Browser
-- import Html exposing (..)
-- import Html.Attributes exposing (..)
-- import Html.Events exposing (..)

-- type alias Model =
--     { text : String }

-- type Msg =
--     NoMsg

-- init : () -> (Model, Cmd Msg)
-- init  _ =  
--     (Model "Main Worksssssss!", Cmd.none)


-- view : Model -> Html Msg
-- view m = 
--     div[ style "height" "100%" ][ text m.text ]


-- update : Msg -> Model -> (Model, Cmd Msg)
-- update msg m =
--     case msg of
--        NoMsg -> (m, Cmd.none)


-- main =
--     Browser.element
--         { init = init
--         , view = view
--         , update = update
--         , subscriptions = \_ -> Sub.none
--         }


module Main exposing (main)

import Browser
import Page.Home as Home


main : Program () Home.Model Home.Msg
main = Browser.element
        { init = Home.init
        , view = Home.view
        , update = Home.update
        , subscriptions = \_ -> Sub.none
        }