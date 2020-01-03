module Main exposing (main)

import Browser
import Page.Home as Home

main : Program () Home.Model Home.Msg
main =
    Browser.element
        { init = Listrecipes.init
        , view = Listrecipes.view
        , update = Listrecipes.update
        , subscriptions = \_ -> Sub.none
        }