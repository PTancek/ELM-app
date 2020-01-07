module Page.Detail exposing (..)

import Recipe exposing (Recipe, recipeDecoder)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Http exposing (..)
import RemoteData exposing (WebData)
import Debug exposing (..)

type alias Model =
    { navKey : Nav.Key
    , recipe : WebData (List Recipe) }

type Msg =
     RecipeReceived (WebData (List Recipe))

init : String -> Nav.Key -> ( Model, Cmd Msg )
init recipeId navKey =
    ( initialModel navKey, fetchRecipe recipeId )


initialModel : Nav.Key -> Model
initialModel navKey =
    { navKey = navKey
    , recipe = RemoteData.Loading
    }


fetchRecipe : String -> Cmd Msg
fetchRecipe recipeId =
    let
        searchUrl = "https://api.edamam.com/search?r=" ++ recipeId ++ "&app_id=05058adb&app_key=d2fa30e84fc9f8af6b3504f0be84cd78"
    in
    Http.get
        { url = searchUrl
        , expect =
            recipeDecoder
                |> Http.expectJson (RemoteData.fromResult >> RecipeReceived)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RecipeReceived recipe ->
            ( { model | recipe = recipe }, Cmd.none )



view : Model -> Html Msg
view model =
    div []
        [ h3 [] [ text "CookBook" ]
        , viewRecipe model.recipe
        ]

viewRecipe : WebData (List Recipe) -> Html Msg
viewRecipe recipe =
    case recipe of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            h3 [] [ text "Loading Recipe..." ]

        RemoteData.Success recipeData ->
            recipeDetailsView recipeData

        RemoteData.Failure httpError ->
            viewFetchError (buildErrorMessage httpError)


recipeDetailsView : (List Recipe) -> Html Msg
recipeDetailsView recipe =
        let
            head = List.head recipe
        in
        
        case head of 
                Just x -> pre [] [text x.title]  -- VIEW GOES HERE -> x is the recipe
                Nothing -> pre [] [text "There was a problem loading the Recipe!"]


viewFetchError : String -> Html Msg
viewFetchError errorMessage =
    let
        errorHeading =
            "Couldn't fetch recipe at this time."
    in
    div []
        [ h3 [] [ text errorHeading ]
        , text ("Error: " ++ errorMessage)
        ]


buildErrorMessage : Http.Error -> String
buildErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Server is taking too long to respond. Please try again later."

        Http.NetworkError ->
            "Unable to reach server."

        Http.BadStatus statusCode ->
            "Request failed with status code: " ++ String.fromInt statusCode

        Http.BadBody message ->
            message