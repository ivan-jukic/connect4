module Connect4 exposing (..)

import Connect4.Models exposing (..)
import Connect4.Board exposing (..)
import Connect4.Maximin exposing (..)
import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Task exposing (perform, succeed)
import Random
import Browser


type Msg
    = NoOp
    | AddToCol Int
    | AIMove Int


init : ( Model, Cmd Msg )
init =
    ( { current = P1
      , next = AI
      , winner = Nothing
      , board = initBoard
      , maxDepth = 5
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        AddToCol col ->
            model.board
                |> makeMove col model.current
                |> (\moveSuccess ->
                    case moveSuccess of
                        Success board ->
                            let
                                isWin =
                                    if checkWin model.current board then
                                        Just model.current
                                    else
                                        Nothing
                            in
                            ( { model
                              | current = model.next
                              , next = model.current
                              , board = board
                              , winner = isWin
                            }
                            , if Nothing == isWin then
                                case model.next of
                                    AI ->
                                        Random.generate AIMove (Random.int 0 1000)
                                    _ ->
                                        Cmd.none
                              else
                                Cmd.none
                            )

                        Fail ->
                            ( model, Cmd.none )
                )

        AIMove randNum ->
            let
                nextMoves =
                    maximin
                        { current = AI
                        , next = model.next
                        , maxDepth = model.maxDepth
                        }
                        model.board
            in
            ( model
            , perform (\_ -> AddToCol 0) (succeed ())
            )


view : Model -> Html Msg
view model =
    div [ style "padding" "50px"
        , style "font-family" "Arial"
        ]
        [ div
            [ style "display" "flex"
            , style "margin-bottom" "20px"
            , style "align-items" "center"
            ]
            [ span
                [ style "display" "inline-block"
                , style "border-radius" "50px"
                , style "width" "20px"
                , style "height" "20px"
                , style "margin-right" "10px"
                , style "background-color"
                    ( case model.current of
                        P1 ->
                            "blue"

                        P2 ->
                            "orange"

                        AI ->
                            "red"
                    )
                ] []
            , text <|
                "Currently playing " ++
                    (case model.current of
                        AI -> "AI"
                        P1 -> "P1"
                        P2 -> "P2"
                    )
            ]
        , div
            [ style "display" "flex"
            , style "width" "525px"
            , style "border-top" "1px solid grey"
            , style "border-left" "1px solid grey"
            ]
            ( model.board
                |> to2DBoard
                |> Array.indexedMap
                    (\i r ->
                        div [ style "display" "flex"
                            , style "width" "100%"
                            , style "flex-direction" "column"
                            , onClick <|
                                case model.winner /= Nothing || model.current == AI of
                                    True ->
                                        NoOp

                                    False ->
                                        (AddToCol i)
                            ]
                            ( r 
                                |> Array.indexedMap
                                    (\j played ->
                                        div [ style "display" "flex"
                                            , style "border-bottom" "1px solid grey"
                                            , style "border-right" "1px solid grey"
                                            , style "padding" "8px"
                                            , style "cursor" "pointer"
                                            , style "user-select" "none"
                                            , style "text-align" "center"
                                            , style "justify-content" "center"
                                            ]
                                            [ case played of
                                                Played p ->
                                                    div
                                                        [ style "width" "40px"
                                                        , style "height" "40px"
                                                        , style "border-radius" "50px"
                                                        , style "background-color"
                                                            ( case p of
                                                                P1 ->
                                                                    "blue"
                                                                P2 ->
                                                                    "orange"
                                                                AI ->
                                                                    "red"
                                                            )
                                                        ]
                                                        []

                                                NotPlayed ->
                                                    div
                                                        [ style "width" "40px"
                                                        , style "height" "40px"
                                                        ] []
                                            ]
                                    )
                                |> Array.toList
                            )
                    )
                |> Array.toList
            )
        , div
            [ style "margin-top" "20px"
            ]
            [ case model.winner of
                Just P1 ->
                    text "Player 1 is the winner"

                Just P2 ->
                    text "Player 2 is the winner"

                Just AI ->
                    text "You lose, loser!"

                Nothing ->
                    text ""
            ]
        ]


main : Program {} Model Msg
main =
    Browser.document
        { view =
            (\m ->
                { title = "Connect4 | Elm 0.19"
                , body = [ view m ]
                }
            )
        , init = \_ -> init
        , update = update
        , subscriptions = \_ -> Sub.none
        }
