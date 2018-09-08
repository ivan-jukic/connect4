module Connect4.Maximin exposing (..)

import Connect4.Models exposing (..)


{-|  1  AI win
     0  No winner
    -1  Player win
-}
maximin : Node -> Board -> Int
maximin node board =
    0


{--

    (cols - 1)
        |> List.range 0 
        |> List.filter (canAddToCol board)
        |> List.map (\c -> (c, makeMove c node.current board))
        |> List.filterMap toBoardTuple
        |> List.map
            (\(col, board) ->
                let
                    weight =
                        node.maxDepth - node.depth + 1
                in
                case checkWin board of
                    Just AI ->
                        ( col, 1 * weight)

                    Nothing ->
                        if node.depth <= node.maxDepth then
                            ( col
                            , maximin
                                { node
                                    | current = node.next
                                    , next = node.current
                                    , depth = node.depth + 1
                                }
                                board
                            )
                        else
                            ( col, 0 )

                    _ ->
                        ( col, -1 * weight)
            )
        |> maximinHandleResult node


maximinHandleResult : Node -> List (Int, Int) -> Int
maximinHandleResult node results =
    case node.depth == 0 of
        True ->
            let
                getMoves eval =
                    results |> List.filterMap (\(col, res) -> if eval res then Just col else Nothing)

                winMoves =
                    getMoves (\r -> r > 0)

                drawMoves =
                    getMoves (\r -> r == 0)

                _ = Debug.log "final moves" results
            in
            case (List.length winMoves > 0, List.length drawMoves > 0) of
                (True,  _ ) ->
                    minmaxSelectMove node.rand winMoves

                (False, True) ->
                    minmaxSelectMove node.rand drawMoves

                _ ->
                    results
                        |> List.map Tuple.first
                        |> minmaxSelectMove node.rand

        False ->
            results
                |> List.map Tuple.second
                |> (if node.current == AI then List.maximum else List.minimum)
                |> Maybe.withDefault 0


minmaxSelectMove : Int -> List Int -> Int
minmaxSelectMove rand moves =
    let
        idx =
            rand % (List.length moves)
    in
    moves
        |> Array.fromList
        |> Array.get idx
        |> Maybe.withDefault -1 -- basically some error happened


canAddToCol : Board -> Int -> Bool
canAddToCol board col =
    board
        |> Array.get col
        |> Maybe.map (\c -> Array.length c < rows)
        |> Maybe.withDefault False


toBoardTuple : (Int, Maybe Board) -> Maybe (Int, Board)
toBoardTuple tuple =
    case tuple of
        ( col, Just board ) ->
            Just (col, board )

        _ ->
            Nothing

--}