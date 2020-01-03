module Recipe exposing (Recipe, recipesDecoder, recipeDecoder)

import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (required)

type alias Recipe =
    { 
        id : String
        , title : String
        , description : String
        , imageUrl : String
        , calories : String
        , servings : Int
        , ingredients : List Ingredient
        , totalNutrients : List NutrientInfo

    }

type alias NutrientInfo = 
    { 
        id : String
        , label : String
        , quanity : String
        , unit : String
    }

type alias Ingredient = 
    { 
        id : String
        , qty : Float
        , measure : String
        , weight : Float
    }

recipesDecoder : Decoder (List Recipe)
recipesDecoder =
    list recipeDecoder


recipeDecoder : Decoder Recipe
recipeDecoder =
    Decode.succeed Recipe
        |> required "id" string
        |> required "title" string
        |> required "description" string
        |> required "imageUrl" string
        |> required "calories" string
        |> required "servings" int
        |> required "ingredients" (list Ingredient)
        |> required "totalNutrientsss" (list NutrientInfo)





