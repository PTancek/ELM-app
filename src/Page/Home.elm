module Page.Home exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Recipe exposing (Recipe, recipeDecoder)
import RemoteData exposing (WebData)


-- MODEL

type alias Model =
    { recipes : WebData (List Recipe) }


-- MSG

type Msg
    = FetchRecipes
    | RecipesRecieved (WebData (List Recipe))


-- INIT

init : () -> ( Model, Cmd Msg )
init _ =
    ( { recipes = RemoteData.Loading }, fetchRecipes )