module Connect4.Maximin exposing (maximin)

import Connect4.Models exposing (..)
import Connect4.Board exposing (makeMove, checkWin)
import Array exposing (Array)
import Dict exposing (Dict)


maximin : Move -> Board -> Array Node
maximin move board =
    let
        nextPlayer p =
            if p == move.current then move.next else move.current

        maxNodes =
            countNodesByDepth move.maxDepth

        emptyTree =
            Array.initialize maxNodes (\_ -> defaultNode)

        _ = Debug.log "len" (Array.length emptyTree)
    in
    (move.maxDepth - 1)
        |> List.range 0
        |> List.foldl
            (\depth (player, boards, tree) ->
                let
                    -- process nodes, returns tuple with parent id and its child nodes
                    processedNodes =
                        processBoards depth player boards                    

                    -- update parents with their new child ids
                    -- updatedTree =
                    --    updateNodeChildren processedNodes tree

                    -- Filter new nodes
                    newNodes =
                        processedNodes
                            |> List.map Tuple.second
                            |> List.concat

                    -- Filter net new boards to be passed for further processing
                    -- These nodes now become parent nodes in the next iteration
                    newBoards =
                        newNodes |> List.map (\node -> ( Just node.nodeId, node.board ))
                in
                ( nextPlayer player
                , newBoards
                , newNodes |> List.foldl (\n t-> Array.set (n.nodeId - 1) n t) tree -- add new nodes to the tree
                )
            )
            ( move.current, [ ( Nothing, board ) ], emptyTree )
        |> (\(_, _, tree) ->
                {--
                (move.maxDepth - 2)
                    |> List.range 0
                    |> List.foldr
                        (\d t ->
                            let
                                
                            in
                            t
                        )
                        tree
                    |> \_ -> tree
                --}
                tree
        )
    {-- }
    ( move.maxDepth - 1 )
        |> List.range 0
        |> List.foldl
            (\depth (player, boards, tree) ->
                let
                    -- process nodes, returns tuple with parent id and its child nodes
                    processedNodes =
                        processBoards depth player boards                    

                    -- update parents with their new child ids
                    updatedTree =
                        updateNodeChildren processedNodes tree

                    -- Filter new nodes
                    newNodes =
                        processedNodes
                            |> List.map Tuple.second
                            |> List.concat

                    -- Filter net new boards to be passed for further processing
                    -- These nodes now become parent nodes in the next iteration
                    newBoards =
                        newNodes |> List.map (\node -> ( Just node.nodeId, node.board ))
                in
                ( nextPlayer player
                , newBoards
                , newNodes
                    |> Array.fromList
                    |> Array.append updatedTree
                )
            )
            ( move.current, [ ( Nothing, board ) ], Array.empty )
        |> (\(_, _, tree) -> tree)
    --}

{-| Process boards, get their next states
-}
processBoards : Int -> Player -> List ( Maybe Int, Board ) -> List ( Maybe Int, List Node )
processBoards depth player boards =
    boards
        |> List.map
            (\( parentId, parentBoard ) ->
                ( parentId
                , parentBoard
                    |> playPossibleMoves depth player parentId
                )
            )


{-| Play all possible moves for a node, create possible child nodes
-}
playPossibleMoves : Int -> Player -> Maybe Int -> Board -> List Node
playPossibleMoves depth player parentId board =
    let
        -- calc node id depending on the depth and parent id
        offsetIdx =
            getNodeIndex depth parentId
    in
    (cols - 1)
        |> List.range 0
        |> List.map (maximinMove player board)
        |> List.filterMap identity
        |> List.map
            (\(c, b) ->
                { nodeId = offsetIdx + c
                , player = player
                , board = b
                , win = checkWin player b
                , depth = depth
                , parentId = parentId
                , childNodes = []
                }
            )


{-| Make move, return tuple of colum where the token was added
    and the new board state. If the move failed, Nothing is
    returned.
-}
maximinMove : Player -> Board -> Int -> Maybe (Int, Board)
maximinMove player board col =
    case makeMove col player board of
        Success b ->
            Just (col, b)
        _ ->
            Nothing


{-| Update node children list. Node id is its index, so get it and update.
    Array indices start form 0, node ids from 1
-}
updateNodeChildren : List ( Maybe Int, List Node ) -> Array Node -> Array Node
updateNodeChildren processedNodes tree =
    processedNodes
        |> List.foldl
            (\(mpid, children) t ->
                case mpid of
                    Just parentId ->
                        let
                            pidx =
                                parentId - 1
                        in
                        case Array.get pidx t of
                            Just n ->
                                Array.set pidx { n | childNodes = children |> List.map .nodeId } t

                            Nothing ->
                                t

                    Nothing ->
                        t
            )
            tree


{-| calculates max num of nodes in tree
-}
countNodesByDepth : Int -> Int
countNodesByDepth d =
    ((1 - (cols ^ (d + 1))) // (1 - cols)) - 1


{-| calculate tree node id depending on the parent and depth
-}
getNodeIndex : Int -> Maybe Int -> Int
getNodeIndex depth parentId =
    if depth == 0 then
        1
    else
        parentId
            |> Maybe.withDefault 1
            |> (\pid ->
                let
                    prevCount =
                        countNodesByDepth (depth - 1)

                    currCount =
                        countNodesByDepth depth
                in
                -- total nodes before current depth nodes, plus add offset to the current node depending on the parent
                -- offset by the parent depends on the parent id, for full tree it will produce squential ids, but
                -- in case when the tree is not full it will produce ids that would be like for a full one.
                currCount + ((pid - prevCount - 1) * cols + 1)
            )


{-- }
logTree : Array Node -> Array Node
logTree tree =
    let
        _ =
            tree |> Array.map
                (\n ->
                    Debug.log "n"
                        { d = n.depth
                        , id = n.nodeId
                        , p = n.player
                        , cn = n.childNodes
                        , pid = n.parentId
                        , w = n.win
                        }
                )
    in
    tree
--}
