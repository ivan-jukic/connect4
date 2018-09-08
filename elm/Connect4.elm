module Connect4 exposing (..)

import Connect4.Models exposing (..)
import Connect4.Board exposing (..)
import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
--import Task exposing (perform, succeed)
--import Random


type Msg
    = NoOp
    | AddToCol Int
    --| AIMove Int


init : ( Model, Cmd Msg )
init =
    ( { current = P1
      , next = P2
      , winner = Nothing
      , board = initBoard
      , maxDepth = 4
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
                            ( { model
                              | current = model.next
                              , next = model.current
                              , board = board
                              , winner =
                                    if checkWin model.current board then
                                        Just model.current
                                    else
                                        Nothing
                            }
                            , Cmd.none
                            )

                        Fail ->
                            ( model, Cmd.none )
                )
           {-
            , case newPlayer of
                AI ->
                    Random.generate AIMove (Random.int 0 1000)

                _ ->
                    Cmd.none
            -}
            

        {-
        AIMove randNum ->
            let
                nextMove =
                    model.board
                        |> maximin
                            { current = AI
                            , next = if model.first == AI then model.second else model.first
                            , maxDepth = model.maxDepth
                            , depth = 0
                            , rand = randNum
                            }
                        |> Debug.log "decided move" 
            in
            ( model
            , perform (\_ -> AddToCol nextMove) (succeed ())
            )
        -}


view : Model -> Html Msg
view model =
    div [ style [("padding", "50px"), ("font-family", "Arial")] ]
        [ div
            [ style
                [ ("display", "flex")
                , ("margin-bottom", "20px")
                , ("align-items", "center")
                ] 
            ]
            [ span
                [ style
                    [ ("display", "inline-block") 
                    , ("border-radius", "50px")
                    , ("width", "20px")
                    , ("height", "20px")
                    , ("margin-right", "10px")
                    , ("background-color"
                      , case model.current of
                            P1 ->
                                "blue"

                            P2 ->
                                "orange"

                            AI ->
                                "red"
                      )
                    ]
                ]
                []
            , text <| "Currently playing " ++ (toString model.current)
            ]
        , div
            [ style
                [ ("display", "flex")
                , ("width", "525px")
                , ("border-top", "1px solid grey")
                , ("border-left", "1px solid grey")
                ]
            ]
            ( model.board
                |> to2DBoard
                |> Array.indexedMap
                    (\i r ->
                        div [ style
                                [ ("display", "flex")
                                , ("width", "100%")
                                , ("flex-direction", "column")
                                ]
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
                                        div [ style
                                                [ ("display", "flex")
                                                , ("border-bottom", "1px solid grey")
                                                , ("border-right", "1px solid grey")
                                                , ("padding", "8px")
                                                , ("cursor", "pointer")
                                                , ("user-select", "none")
                                                , ("text-align", "center")
                                                , ("justify-content", "center")
                                                ]
                                            ]
                                            [ case played of
                                                Played p ->
                                                    div
                                                        [ style
                                                            [ ("width", "40px")
                                                            , ("height", "40px")
                                                            , ("border-radius", "50px")
                                                            , ("background-color",
                                                                case p of
                                                                    P1 ->
                                                                        "blue"
                                                                    P2 ->
                                                                        "orange"
                                                                    AI ->
                                                                        "red"
                                                              )
                                                            ]
                                                        ]
                                                        []

                                                NotPlayed ->
                                                    div [ style [ ("width", "40px") , ("height", "40px") ] ] []
                                            ]
                                    )
                                |> Array.toList
                            )
                    )
                |> Array.toList
            )
        , div
            [ style
                [ ("margin-top", "20px")
                ]
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


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        }
