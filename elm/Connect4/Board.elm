module Connect4.Board exposing (..)

import Connect4.Models exposing (..)
import Array exposing (..)
import Bitwise


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
        (moveLo, moveHi) =
            board
                |> Array.indexedMap (\i v -> (i, v))
                |> Array.foldl
                    (\(idx, p) mask ->
                        if p == Played player then
                            calcMask idx mask
                        else
                            mask
                    )
                    (0, 0)
    in
    winMasks
        |> List.foldl
            (\(mlo, mhi) win ->
                if not win then
                    ( Bitwise.and mlo moveLo, Bitwise.and mhi moveHi )
                        |> \( resLo, resHi ) -> resLo == mlo && resHi == mhi
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
