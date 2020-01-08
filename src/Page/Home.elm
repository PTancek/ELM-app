module Page.Home exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Recipe exposing (..)
import RemoteData exposing (WebData)
import Url exposing (percentEncode)
import Style exposing (..)

type alias Model =
    { 
        recipes : WebData (List RecipeLite)
        , input : String
        , health : String
        , diet : String
        , mealType : String
        , page : Int
        , pageLoaded : Bool
    }


type Msg
    = FetchRecipes
    | SaveIng String
    | SaveD String
    | SaveH String
    | SaveMT String
    | RecipesRecieved (WebData (List RecipeLite))
    | PrevoiusPage
    | NextPage

init : ( Model, Cmd Msg )
init =
    ( { recipes = RemoteData.NotAsked, input = "", health = "", diet = "", mealType = "", page = 0, pageLoaded = True}, Cmd.none )


fetchRecipes : Model -> Cmd Msg
fetchRecipes model =
    let

        from = "&from=" ++ String.fromInt (0 + ( 10 * model.page ))
        to = "&to=" ++ String.fromInt (10 + ( 10 * model.page ))
        -- diet = "&diet=" ++ model.diet
        -- health = "&health=" ++ model.health
        -- mtype = "&mealType=" ++ model.mealType

        searchUrl = "https://api.edamam.com/search?q=" ++ model.input ++ "&app_id=05058adb&app_key=d2fa30e84fc9f8af6b3504f0be84cd78" ++ from ++ to

    in
    
    Http.get
        { url = searchUrl
        , expect =
            recipesDecoder
                |> Http.expectJson (RemoteData.fromResult >> RecipesRecieved)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchRecipes ->
            ( { model | recipes = RemoteData.Loading, page = 0}, fetchRecipes model)

        SaveIng input ->
            ( { model | input = input }, Cmd.none)

        SaveD input ->
            ( { model | diet = input }, Cmd.none)

        SaveH input ->
            ( { model | health = input }, Cmd.none)

        SaveMT input ->
            ( { model | mealType = input }, Cmd.none)

        RecipesRecieved response ->
            ( { model | recipes = response, pageLoaded = False }, Cmd.none )

        PrevoiusPage ->
            ( { model | page = model.page - 1
            , recipes = RemoteData.Loading}
            , fetchRecipes model)

        NextPage -> 
            ( { model | page = model.page + 1
            , recipes = RemoteData.Loading}
            , fetchRecipes model)

        


-- VIEWS


view : Model -> Html Msg
view model =
        div ([] ++ page)
        [ div ([] ++ navBar)
            [
                h3([] ++ logostyle) [text "CookBook" ]
            ]
        , div ([] ++ inputAndCover)
            [
                div ([] ++ leftSide)
                [
                    h2([] ++ upperInputText) [text "Discover most delicious recipes"]
                    ,div ([] ++ inputBar)
                    [
                        viewInput searchBar "text" "Search for recipes" model.input SaveIng
                        , button ([onClick FetchRecipes ] ++ searchButton) [ text "Search"  ]
                    ]
                    , div ([] ++ listOfRecepies )
                    [
                        viewRecipes model.recipes 
                    ]
                    , div [ hidden model.pageLoaded ] [
                        button [onClick PrevoiusPage, disabled (checkStartIndex model)] [text "Previous"]
                        , button [onClick NextPage, disabled (shouldEnableNext model)] [text "Next"]
                    ]
                ]
                , div ([] ++ cover)
                [
                    img [src "./img/cover.png", alt "solatka"] []
                ]
            ]
        ]

checkStartIndex : Model -> Bool
checkStartIndex m = 
    case m.page of
        0 -> True
        _ -> False

shouldEnableNext : Model -> Bool
shouldEnableNext m = 
    if m.pageLoaded == False then 
        case m.recipes of
            RemoteData.Success x -> 
                if List.length x /= 10 then 
                    True 
                else 
                    False

            _ -> True
    else 
        True
    

viewInput : List (Attribute msg) -> String -> String -> String -> (String -> msg) -> Html msg
viewInput c t p v toMsg =
  input ([ type_ t, placeholder p, value v, onInput toMsg ] ++ c) []


viewRecipes : WebData (List RecipeLite) -> Html Msg
viewRecipes recipes =
    case recipes of
        RemoteData.NotAsked ->
            h3 [ style "color" "red"][ text "Start Searching for new Recipes!" ]

        RemoteData.Loading ->
            h3 [][ text "Loading..." ]

        RemoteData.Success actualRecipes ->
            div []
                [ h3 [] [ text "Recipes" ]
                , table []
                    ([] ++ List.map viewRecipe actualRecipes)
                ]

        RemoteData.Failure httpError ->
            viewFetchError (buildErrorMessage httpError)


viewRecipe : RecipeLite -> Html Msg
viewRecipe recipe =
    let
        recipeUrl = Url.percentEncode recipe.id
    in

    div[style "display" "flex", style "position" "relative", style "width" "33%"]
        [
        div[style "display" "flex", style "flex" "3",style "width" "50%", style "height" "50%", style "background" ("url(" ++ recipe.image ++ ")") ]
            [
                div[style "min-width" "200px", style "min-height" "200px"] [
                    
                    div[style "position" "absolute", style "bottom" "20px", style "left" "20 px"]
                    [
                        h5 [ style "decoration" "none"] [a [ href ("detail/" ++ recipeUrl)] [text recipe.title]]
                    ]
                ]
                
            ] 
        
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

