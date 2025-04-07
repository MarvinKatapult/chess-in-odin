package main

import "core:fmt"
import "core:os"
import chess "chesslib"

main :: proc() {
    board: chess.Board;
    if !chess.set_board(&board, chess.FEN_TEST_POS2) {
        fmt.println("\nFailed to set Fenstring");
        os.exit(-1);
    }

    moves := chess.get_valid_moves(&board);
    defer delete(moves);

    chess.print_board(&board);
}
