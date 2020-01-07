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
        -- , startIndex : Int
        -- , endIndex : Int
        , page : Int
    }


type Msg
    = FetchRecipes
    | SaveInput String
    | RecipesRecieved (WebData (List RecipeLite))
    | PrevoiusPage
    | NextPage

type alias Option =
    {
        
    }

init : ( Model, Cmd Msg )
init =
    ( { recipes = RemoteData.NotAsked, input = "", page = 0}, Cmd.none )


fetchRecipes : Model -> Cmd Msg
fetchRecipes model =
    let

        from = 0 + ( 10 * model.page )
        to = 10 + ( 10 * model.page )
        searchUrl0 = "https://api.edamam.com/search?q=" ++ model.input ++ "&app_id=05058adb&app_key=d2fa30e84fc9f8af6b3504f0be84cd78"
        searchUrl1 = searchUrl0 ++ "&from=" ++ String.fromInt from ++ "&to=" ++ String.fromInt to

    in
    
    Http.get
        { url = searchUrl1
        , expect =
            recipesDecoder
                |> Http.expectJson (RemoteData.fromResult >> RecipesRecieved)
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchRecipes ->
            ( { model | recipes = RemoteData.Loading, page = 0}, fetchRecipes model)

        SaveInput input ->
            ( { model | input = input }, Cmd.none)

        RecipesRecieved response ->
            ( { model | recipes = response }, Cmd.none )

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

    div [class "page"]
        [ div [class "nav-bar"]
            [
                h3[ class "logo"][text "CookBook"]
            ]
        , div [class "input-and-cover"]
            [
                div [class "left-side" ]
                [
                    h2[ class "upper-input-text"][text "Discover most delicious recipes"]
                    ,div [class "input-bar"]
                    [
                        
                        viewInput "search-bar" "text" "Search for recipes" model.input SaveInput
                        , button [class "search-button", onClick FetchRecipes ][ text "Search"  ]
                    ]
                    , div [class "list-of-recepies"]
                    [
                        viewRecipes model.recipes 
                    ]
                ]
                , div [class "cover"]
                [
                    img [src "./img/cover.png", alt "solatka"] []
                ]
            ]
        ]

    -- div []
    --     [ h1[][text "CookBook"]
    --     , viewInput "text" "Search for recipes" model.input SaveInput
    --     , button [ onClick FetchRecipes ][ text "Search" ]
    --     , viewRecipes model.recipes 
    --     , div[  ] [
    --         button [onClick PrevoiusPage, disabled (checkStartIndex model)] [text "Previous"]
    --         , button [onClick NextPage] [text "Next"]
    --     ]]
        

-- checkStartIndex : Model -> Bool
-- checkStartIndex m = 
--     case m.page of
--         0 -> True
--         _ -> False

    

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



