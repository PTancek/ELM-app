module Page.Detail exposing (..)

import Recipe exposing (Recipe, recipeDecoder, NutrientInfo)
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
                , viewRecipe model.recipe
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
                Just x -> detailView x
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


detailView : Recipe -> Html Msg
detailView r =
    div [style "font-size" "25"]
    [
        div [] [
            h3 [style "font-size" "45px", style "margin-top" "0", style "font-weight" "bold"]
                [ a [ href r.url, style "font-color" "black"] [ text ("Recipe: " ++ r.title)]]
            
        ]

        ,table [ style "text-align" "left"]
            ( [ tr [][ th [ style "font-size" "30px", style "font-color" "red"][ text "Ingredients:"]] 
            ] ++ List.map listInfo r.ingredients )

        , p [][]
        , br [] []

        ,table [ style "text-align" "left"]
            ( [ tr [][ th [ style "font-size" "30px", style "font-color" "red"][ text "Healt Labels:"]] 
            ] ++ List.map listInfo r.healthLabels )

        , br [] []

        ,table [ style "text-align" "left"]
            ( [ tr [][ th [ style "font-size" "30px", style "font-color" "red"][ text "Diet Labels:"]] 
            ] ++ List.map listInfo r.dietLabels )

        , br [] []

        , h3 [style "font-size" "30px", style "font-color" "red"][ text "Nutritional values"]
        ,table [ style "text-align" "left"]
            ( [ nutrientsHeader ] ++ List.map listNutrients r.nutrients )
    ]

listInfo : String -> Html Msg
listInfo info =
    tr [] [
        td [] [ text ("- " ++ info)]
    ]


nutrientsHeader : Html Msg
nutrientsHeader =
    tr [ style "font-size" "20px", style "font-color" "red" ] [
        th [style "width" "180px"] [ text "Nutrient"]
        ,th [style "width" "160px"] [ text "Quantity"]
        ,th [style "width" "100px"] [ text "Unit"]
    ]

listNutrients : NutrientInfo -> Html Msg
listNutrients nutr =
    tr [] [
        td [] [ text nutr.label]
        ,td [] [ text (String.fromInt (round nutr.quantity)) ]
        ,td [] [ text nutr.unit]
    ]