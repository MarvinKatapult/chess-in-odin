package main

import "core:fmt"
import "core:os"
import chess "chesslib"

main :: proc() {
    board: chess.Board;
    if !chess.set_board(&board, chess.FEN_START_POS) {
        fmt.println("\nFailed to set Fenstring");
        os.exit(-1);
    }
    chess.print_board(&board);
    valid_moves := chess.get_valid_moves(&board);
    for move in valid_moves {
        fmt.println(move);
    }
    fmt.println("Movecount:", len(valid_moves));
}
