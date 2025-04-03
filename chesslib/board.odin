package chess 

import "core:unicode"
import "core:fmt"
import "core:strconv"

CHESS_BOARD_WIDTH  :: 8;
CHESS_BOARD_HEIGHT :: 8;

FEN_START_POS :: "rnbkqrnb/pppppppp/8/8/8/8/PPPPPPPP/RNBKQRNB"

Board :: struct {
    field: [CHESS_BOARD_WIDTH][CHESS_BOARD_HEIGHT]Square,
}

set_board :: proc(board: ^Board, fen_string: string) -> bool {
    len := len(fen_string);
    row: u8 = 0;
    col: u8 = 0;
    for c in fen_string {
        if row >= CHESS_BOARD_HEIGHT do return false;
        if col > CHESS_BOARD_WIDTH do return false;
        if c == '/' {
            if col != CHESS_BOARD_WIDTH do return false;
            row += 1;
            col = 0;
            continue;
        }

        if unicode.is_digit(c) {
            col += u8(c) - u8('0');
            continue;
        }

        p, ok := char_to_piece(c);
        if !ok do return false;

        board.field[row][col].piece = p;
        col += 1;
    }
    return true;
}

print_board :: proc(board: ^Board) {
    fmt.println("");
    for y in 0..<CHESS_BOARD_HEIGHT {
        fmt.printf("%d|", CHESS_BOARD_HEIGHT - y)
        for x in 0..<CHESS_BOARD_WIDTH {
            if board.field[y][x].piece.type != .Empty {
                fmt.print(piece_to_char(board.field[y][x].piece));
            } else do fmt.print(" ");
        }
        fmt.println("");
    }
    fmt.println("-+--------")
    fmt.println(" |ABCDEFGH")
}

play_move :: proc(board: ^Board, move: Move) -> (bool, MoveError) {
    ok, err := check_move(board, move);
    if ok do play_valid_move(board, move);
    return ok, err;
}

play_valid_move :: proc(board: ^Board, move: Move) {
    board.field[move.y_to][move.x_to].piece = board.field[move.y_from][move.x_from].piece;
}
