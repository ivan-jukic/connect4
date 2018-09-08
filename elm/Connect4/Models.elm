module Connect4.Models exposing (..)

import Array exposing (Array)


type Player
    = P1
    | P2
    | AI


type PlayStatus
    = Played Player
    | NotPlayed


type alias Board
    = Array PlayStatus


type MoveSuccess
    = Success Board
    | Fail


rows : Int
rows = 6


cols : Int
cols = 7


type alias Model =
    { current : Player
    , next : Player
    , winner : Maybe Player
    , board : Board
    , maxDepth : Int
    }


type alias Node =
    { current : Player
    , next : Player
    , depth : Int
    , maxDepth : Int
    , rand : Int
    }


{-| Calculates range of possible combinations that lead to victory in Connect4
    For 6r×7c board size in Connect 4 that's 69 possibilities.
-}
winMasks : List (List Char)
winMasks =
    (cols - 1)
        |> List.range 0
        |> List.map
            (\col ->
                (rows - 1)
                    |> List.range 0
                    |> List.map (\row -> (col, row))
            )
        |> List.concat
        |> List.map getWinPoints
        |> List.concat
        |> List.map
            (\winPoints ->
                winPoints
                    |> List.foldl
                        (\pt arr -> arr |> Array.set pt '1')
                        (Array.initialize (cols * rows) (\_ -> '0'))
                    |> Array.toList
            )


{-| Generate 4 in row points to check from a specified point
-}
getWinPoints : ( Int, Int ) -> List ( List Int )
getWinPoints (col, row) =
    let
        range fn =
            List.range 0 3
                |> List.map ( fn >> (\(c, r) -> (c * rows) + r ) )
    in
    List.concat

         -- checking up
        [ if row < rows - 3 then
            [ range (\x -> (col, row + x)) ] 
          else
            []

        -- checking right
        , if col < cols - 3 then 
            [ range (\y -> (col + y, row)) ]
          else
            []

        -- diagonal checks if we still have enough distance on the right
        , if col < cols - 3 then

            -- up diagonal
            if row < rows - 3 then
                [ range (\xy -> (col + xy, row + xy)) ]

            -- down diagonal
            else
                [ range (\xy -> (col + xy, row - xy)) ]

          else
            []
        ]
