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

    chess.print_board_for_every_piece(&board);
    chess.print_board(&board);
}
