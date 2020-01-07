module Main exposing (main)

import Page.Home as Home
import Page.Detail as Detail
import Route exposing (Route)
import Browser exposing (UrlRequest(..), Document)
import Browser.Navigation as Nav
import Url exposing (Url)
import Html exposing (..)
import RemoteData exposing (WebData)
import Recipe exposing (..)

-- MAIN TYPES

type alias Model =
    { route : Route
    , page : Page
    , navKey : Nav.Key
    }

type alias HomeModel =
    {
        recipes : WebData (List RecipeLite)
        , input : String
    }

type Page
    = NotFoundPage
    | HomePage Home.Model
    | DetailPage Detail.Model

type Msg
    = HomePageMsg Home.Msg
    | DetailPageMsg Detail.Msg
    | LinkClicked UrlRequest
    | UrlChanged Url


-- MAIN INIT

init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        model =
            { route = Route.parseUrl url
            , page = NotFoundPage
            , navKey = navKey
            }
    in
    initCurrentPage ( model, Cmd.none )


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, existingCmds ) =
    let
        ( currentPage, mappedPageCmds ) =
            case model.route of
                Route.NotFound ->
                    ( NotFoundPage, Cmd.none )

                Route.Home ->
                    let
                        ( pageModel, pageCmds ) =
                            Home.init   
                    in
                    ( HomePage pageModel, Cmd.map HomePageMsg pageCmds )

                Route.Detail recipeId ->
                    let
                        ( pageModel, pageCmds ) =
                            Detail.init recipeId model.navKey
                    in
                    ( DetailPage pageModel, Cmd.map DetailPageMsg pageCmds )
    in
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )


-- MAIN VIEW

view : Model -> Document Msg
view model =
    { title = "CookBook"
    , body = [ currentView model ]
    }

currentView : Model -> Html Msg
currentView model =
    case model.page of
        NotFoundPage ->
            notFoundView

        HomePage pageModel ->
            Home.view pageModel
                |> Html.map HomePageMsg

        DetailPage pageModel ->
            Detail.view pageModel
                |> Html.map DetailPageMsg


notFoundView : Html msg
notFoundView =
    h3 [] [ text "Oops! The page you requested was not found!" ]


-- MAIN UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( HomePageMsg subMsg, HomePage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    Home.update subMsg pageModel
            in
            ( { model | page = HomePage updatedPageModel }
            , Cmd.map HomePageMsg updatedCmd
            )

        ( DetailPageMsg subMsg, DetailPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    Detail.update subMsg pageModel
            in
            ( { model | page = DetailPage updatedPageModel }
            , Cmd.map DetailPageMsg updatedCmd
            )
        
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )
                    
        ( UrlChanged url, _ ) ->
            let
                newRoute =
                    Route.parseUrl url
            in
            ( { model | route = newRoute }, Cmd.none )
                |> initCurrentPage

        ( _, _ ) ->
            ( model, Cmd.none )


main : Program () Model Msg
main = Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }