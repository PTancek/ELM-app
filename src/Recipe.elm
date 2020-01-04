module Recipe exposing (Recipe, recipeDecoder, recipesDecoder, hitsDecoder)

import Json.Decode as Decode exposing (Decoder, int, float, list, string, field)
import Json.Decode.Pipeline exposing (..)

type alias Recipe =
    { 
        id : String
        , title : String
        , url : String
        , image : String
        , calories : Float
        , servings : Int
        , ingredients : List Ingredient
        -- , totalNutrients : List NutrientInfo

    }

type alias NutrientInfo = 
    { 
        label : String
        , quanity : String
        , unit : String
    }

type alias Ingredient = 
    {
        text : String
    }

hitsDecoder : Decoder (List Recipe)
hitsDecoder =
    field "hits" recipesDecoder

recipesDecoder : Decoder (List Recipe)
recipesDecoder =
    list recipeDecoder

recipeDecoder : Decoder Recipe
recipeDecoder =
    field "recipe" (Decode.succeed Recipe
        |> required "uri" string
        |> required "label" string
        |> required "url" string
        |> required "image" string
        |> required "calories" float
        |> required "yield" int
        |> required "ingredients" ingredientsDecoder 
        -- |> required "totalNutrients" nutrientsDecoder
        )


ingredientsDecoder : Decoder (List Ingredient)
ingredientsDecoder =
    list ingredientDecoder


ingredientDecoder : Decoder Ingredient
ingredientDecoder =
    Decode.succeed Ingredient
        |> required "text" string


nutrientsDecoder : Decoder (List NutrientInfo)
nutrientsDecoder =
    list nutrientDecoder

nutrientDecoder : Decoder NutrientInfo
nutrientDecoder =
    Decode.succeed NutrientInfo
        |> required "label" string
        |> required "quanity" string
        |> required "unit" string 