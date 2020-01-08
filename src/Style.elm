module Style exposing (..)

import Html.Attributes exposing (..)
import Html exposing (..)


logostyle: List (Attribute msg)
logostyle = 
    [ 
         style "font" "PopBold"
        ,style "font-family" "PopBold"
        ,style "src" "url('./fonts/Poppins-Regular.ttf')"
        ,style "font-size" "50px"
        ,style "color" "red"
        , style "font-weight" "bold"
       
    ]

page: List (Attribute msg)
page = 
    [
        style "color" "black"
        ,style"background" "linear-gradient(90deg,#ffedde 75%, #ec0606 25%)"
    ] 
navBar: List (Attribute msg)
navBar = 
    [
        style  "min-height" "10vh"
        ,style "width" "90%"
        ,style "margin" "auto"
        ,style "display" "flex"
        ,style "justify-content" "space-between"
        ,style "align-items" "center"
        ,style "padding" "20px 0px"    
    ]

inputAndCover: List (Attribute msg)
inputAndCover = 
    [ 
        style "display" "flex"
        ,style "width" "90%"
        ,style "margin" "auto"
        ,style "min-height" "90vh"
    ]

leftSide: List (Attribute msg)
leftSide = 
    [
        style "flex" "6"
    ]

upperInputText: List (Attribute msg)
upperInputText = 
    [
       
        style "font" "PopRegular"
        ,style "font-family" "PopRegular"
        ,style "src" "url('./fonts/Poppins-Regular.ttf')"
        ,style "color" "#3B3276"
        ,style "font-weight" "bold"

    ]

inputBar: List (Attribute msg)
inputBar = 
    [
        style "align-items" "baseline"
        ,style "display" "flex"
        ,style "align-items" "flex-start"
        ,style "width" "100%"
        ,style "position" "relative"
        ,style "height" "30px"
        ,style "margin" "15px 0px 20px 0px"
        ,style "font-family" "PopRegular"
        ,style "src" "url('./fonts/Poppins-Regular.ttf')"
    ]

searchBar: List (Attribute msg)
searchBar = 
    [
        style "border" "none"
        ,style "border-right" "none"
        ,style "padding" "10px"
        ,style "font-family" "PopRegular"
        ,style "src" "url('./fonts/Poppins-Regular.ttf')"
        ,style "width" "60%"
        ,style "outline" "none"
        ,style "color" "black"
        ,style "border-radius"  "5px 0 0 5px"
        
        
    ]

searchButton: List (Attribute msg)
searchButton = 
    [
        style "border" "none"
        ,style "background" "#F71616"
        ,style "text-align" "center"
        ,style "color" "#fff"
        ,style "border-radius" "0 5px 5px 0"
        ,style "cursor" "pointer"
        ,style "padding" "10px"
        ,style "font-family" "PopRegular"
        ,style "src" "url('./fonts/Poppins-Regular.ttf')"
        
    ]

listOfRecepies: List (Attribute msg)
listOfRecepies = 
    [
        style "display" "flex"
        ,style "width" "100%"
        ,style "margin" "auto"
        ,style "font-family" "PopRegular"
        ,style "src" "url('./fonts/Poppins-Regular.ttf')"
        ,style "color" "black"
    ]

cover: List (Attribute msg)
cover = 
    [
        style "flex" "4"
        ,style "align-items" "center"
    ]
    
slika: List (Attribute msg)
slika = 
    [
        style "display" "flex"
        ,style "width" "300px"
        ,style "margin" "10px"
        ,style "position" "relative"
    ]