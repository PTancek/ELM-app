module Page.Home exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Recipe exposing (..)
import RemoteData exposing (WebData)
import Url exposing (percentEncode)

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

-- type alias Option =
--     {
        
--     }

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

    div [ 
           style "height" "100%"
           , style "font-family" "Arial"
        ] 
        [
            div [
                style "height" "100%"
                , style "width" "60%"
                , style "float" "left"
                , style "disply" "flex"
                , style "margin-left" "40px"
                , style "clear" "left"  
            ][
                h3 [ style "font-family" "PopBold", style "font-size" "60px", style "color" "red"] [ text "CookBook" ]
                , input [ type_ "text", placeholder "Ingredients", value model.input, onInput SaveIng ] []
                -- , input [ type_ "text", placeholder "Diet", value model.diet, onInput SaveD] []
                -- , input [ type_ "text", placeholder "Health", value model.health, onInput SaveH ] []
                -- , input [ type_ "text", placeholder "MealType", value model.mealType, onInput SaveMT ] []
                , button [ onClick FetchRecipes ][ text "Search" ]
                , viewRecipes model.recipes
                , div[ hidden model.pageLoaded] [
                    button [onClick PrevoiusPage, disabled (checkStartIndex model)] [text "Previous"]
                    , button [onClick NextPage] [text "Next"]
                ]
            ]

            , div [
                style "height" "1500px"
                , style "width" "35%"
                , style "float" "right"
                , style "background-color" "red"
                , style "padding-top" "70px"
                , style "disply" "flex"
                , style "position" "relative"
            ][
                img [src "../img/cover.png", alt "solatka", style "width" "80%"] []
            ]
        ]

    -- div []
    --     [ h1[][text "CookBook"]
    --     , viewInput "text" "Search for recipes" model.input SaveInput
    --     , button [ onClick FetchRecipes ][ text "Search" ]
    --     , viewRecipes model.recipes 
    --     , 
        

checkStartIndex : Model -> Bool
checkStartIndex m = 
    case m.page of
        0 -> True
        _ -> False

    

viewInput : String -> String -> String -> String -> (String -> msg) -> Html msg
viewInput c t p v toMsg =
  input [ class c, type_ t, placeholder p, value v, onInput toMsg ] []


viewRecipes : WebData (List RecipeLite) -> Html Msg
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


viewRecipe : RecipeLite -> Html Msg
viewRecipe recipe =

    let
        recipeUrl = Url.percentEncode recipe.id
    in
    
    tr []
        [ td []
            [ text recipe.title ]
        , td []
            [ text (String.fromInt (round recipe.calories)) ]
        , td []
            [ text (String.fromInt recipe.servings) ]
        , td []
            [ button [ ] [ a [ href ("detail/" ++ recipeUrl) ] [ text "View Recipeit" ] ] ]
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


-- diet : List String
-- diet = 
--     [ 
--         "balanced"	
--         ,"high-fiber"	
--         ,"high-protein"
--         ,"low-carb"
--         ,"low-fat"
--         ,"low-sodium"	
--         ,"alcohol-free"
--     ]


-- health : List String
-- health =
--     [
--         "alcohol-free"	
--         ,"celery-free"	
--         ,"crustacean-free" 
--         ,"dairy-free"
--         ,"egg-free"
--         ,"fish-free" 	
--         ,"fodmap-free" 	
--         ,"gluten-free" 	
--         ,"keto-friendly" 	
--         ,"kidney-friendly" 
--         ,"kosher"
--         ,"low-potassium" 	
--         ,"lupine-free" 	
--         ,"mustard-free" 	
--         ,"low-fat-abs" 	
--         ,"No-oil-added" 	
--         ,"low-sugar" 	
--         ,"paleo" 	
--         ,"peanut-free" 	
--         ,"pecatarian" 	
--         ,"pork-free" 	
--         ,"red-meat-free" 
--         ,"sesame-free"
--         ,"shellfish-free"	
--         ,"soy-free"
--         ,"sugar-conscious"
--         ,"tree-nut-free" 
--         ,"vegetarian"
--         ,"wheat-free"
--     ]


-- mealType : List String 
-- mealType = 
--     [
--         "Breakfast"
--         ,"Lunch"
--         ,"Dinner"
--         ,"Snack"
--     ]



