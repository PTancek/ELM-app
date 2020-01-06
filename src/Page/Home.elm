module Page.Home exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Recipe exposing (..)
import RemoteData exposing (WebData)


type alias Model =
    { 
        recipes : WebData (List Recipe)
        , input : String
    }


type Msg
    = FetchRecipes
    | SaveInput String
    | RecipesRecieved (WebData (List Recipe))
    | ViewRecipe


init : ( Model, Cmd Msg )
init =
    ( { recipes = RemoteData.NotAsked, input = "" }, Cmd.none )


fetchRecipes : Model -> Cmd Msg
fetchRecipes model =
    let
        searchUrl = "https://api.edamam.com/search?q=" ++ model.input ++ "&app_id=05058adb&app_key=d2fa30e84fc9f8af6b3504f0be84cd78"
    in
    
    Http.get
        { url = searchUrl
        , expect =
            hitsDecoder
                |> Http.expectJson (RemoteData.fromResult >> RecipesRecieved)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchRecipes ->
            ( { model | recipes = RemoteData.Loading }, fetchRecipes model)

        SaveInput input ->
            ( { model | input = input }, Cmd.none)

        RecipesRecieved response ->
            ( { model | recipes = response }, Cmd.none )

        -- TO DO 
        ViewRecipe -> (model, Cmd.none)



-- VIEWS


view : Model -> Html Msg
view model =
    div []
        [ h1[][text "CookBook"]
        , viewInput "text" "Search for recipes" model.input SaveInput
        , button [ onClick FetchRecipes ][ text "Search" ]
        , viewRecipes model.recipes ]

viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []


viewRecipes : WebData (List Recipe) -> Html Msg
viewRecipes recipes =
    case recipes of
        RemoteData.NotAsked ->
            h3 [][ text "Start Searching for new Recipes!" ]
            

        RemoteData.Loading ->
            h3 [][ text "Loading..." ]

        RemoteData.Success actualRecipes ->
            div []
                [ h3 [] [ text "Recipes" ]
                , table []
                    ([ viewTableHeader ] ++ List.map viewRecipe actualRecipes)
                ]

        RemoteData.Failure httpError ->
            viewFetchError (buildErrorMessage httpError)


viewTableHeader : Html Msg
viewTableHeader =
    tr []
        [ th []
            [ text "Name"]
        , th []
            [ text "calories"]
        , th []
            [ text "servings"]
        ]


viewRecipe : Recipe -> Html Msg
viewRecipe recipe =
    tr []
        [ td []
            [ text recipe.title ]
        , td []
            [ text (String.fromInt (round recipe.calories)) ]
        , td []
            [ text (String.fromInt recipe.servings) ]
        , td []
            [ button [ onClick ViewRecipe ][ text "View Recipe" ] ]
        ]


viewFetchError : String -> Html Msg
viewFetchError errorMessage =
    let
        errorHeading =
            "Couldn't fetch posts at this time."
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