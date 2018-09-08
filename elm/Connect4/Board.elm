module Connect4.Board exposing (..)

import Connect4.Models exposing (..)
import Array exposing (..)


{-| Init our board
-}
initBoard : Board
initBoard =
    Array.initialize
        (cols * rows)
        (\_ -> NotPlayed)


{-| Make a move, put token in a column.
    If it fails, eg. column is filled, it will return Fail
-}
makeMove : Int -> Player -> Board -> MoveSuccess
makeMove col player board =
    let
        (offsetLo, offsetHi) =
            getColBounds col

        checkIndex c i =
            if i == Nothing then
                board
                    |> Array.get c
                    |> Maybe.andThen (\v -> if v == NotPlayed then Just c else Nothing)
            else
                i
    in
    offsetHi
        |> List.range offsetLo
        |> List.foldl
            checkIndex
            Nothing
        |> Maybe.map (\idx -> Success (board |> Array.set idx (Played player)))
        |> Maybe.withDefault Fail


{-| Check if player won!
    Create mask out of current board and compare with win masks.
-}
checkWin : Player -> Board -> Bool
checkWin player board =
    let
        boardState =
            board
                |> Array.foldl
                    (\p l -> (if p == Played player then '1' else '0') :: l)
                    []
    in
    winMasks
        |> List.foldl
            (\mask win ->
                if not win then
                    boardState
                        |> List.map2
                            (\b1 b2 -> if b1 == '1' && b2 == '1' then '1' else '0')
                            mask
                        |> String.fromList
                        |> \res -> res == (String.fromList mask)
                else
                    win
            )
            False


{-| Transform 1D board to 2D for UI
-}
to2DBoard : Board -> Array ( Array PlayStatus )
to2DBoard board =
    List.range 0 (cols - 1)
        |> List.foldl
            (\col arr ->
                let
                    (idxLo, idxHi) =
                        getColBounds col

                    part =
                        board
                            |> Array.slice idxLo (idxHi + 1)
                            |> Array.toList
                            |> List.reverse
                            |> Array.fromList
                in
                arr |> Array.set col part 
            )
            ( Array.initialize
                cols
                (\_ -> Array.empty)
            )


{-| Returns min and max index of what would be a column in 1D array
-}
getColBounds : Int -> (Int, Int)
getColBounds col =
    col * rows |> (\idxLo -> (idxLo, idxLo + rows - 1))
