module Recipe exposing (Recipe, RecipeLite, NutrientInfo, recipeDecoder, recipesDecoder)

import Json.Decode as D exposing (Decoder, int, float, list, string, field)
import Json.Decode.Pipeline as JP exposing (..)
-- import Ports exposing (..)

type alias Recipe =
    { 
        id : String
        , title : String
        , url : String
        , image : String
        , calories : Float
        , servings : Int
        , dietLabel : List String
        , healthLabels : List String
        , ingredients : List String
        , nutrients : List NutrientInfo 
    }

type alias RecipeLite =
    { 
        id : String
        , title : String
        , image : String
        , calories : Float
        , servings : Int
    }


type alias NutrientInfo = 
    { 
        label : String
        , quantity : Float
        , unit : String
    }



recipesDecoder : Decoder (List RecipeLite)
recipesDecoder =
    field "hits" (list (field "recipe" recipeLiteDecoder))


recipeLiteDecoder : Decoder RecipeLite
recipeLiteDecoder = 
    D.succeed RecipeLite
        |> JP.required "uri" string
        |> JP.required "label" string
        |> JP.required "image" string
        |> JP.required "calories" float
        |> JP.required "yield" int

recipeDecoder : Decoder (List Recipe)
recipeDecoder =
    list (D.succeed Recipe 
        |> JP.required "uri" string
        |> JP.required "label" string
        |> JP.required "url" string
        |> JP.required "image" string
        |> JP.required "calories" float
        |> JP.required "yield" int
        |> JP.required "dietLabels" (list string)
        |> JP.required "healthLabels" (list string)
        |> JP.required "ingredientLines" (list string) 
        |> JP.required "totalNutrients" (D.map (List.map Tuple.second) <| D.keyValuePairs nutrientDecoder)
    )
nutrientDecoder : Decoder NutrientInfo
nutrientDecoder =
    D.succeed NutrientInfo
        |> JP.required "label" string
        |> JP.required "quantity" float
        |> JP.required "unit" string
