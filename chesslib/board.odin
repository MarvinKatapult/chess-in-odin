package chess 

import "core:unicode"
import "core:fmt"
import "core:strconv"

BOARD_WIDTH  :: 8;
BOARD_HEIGHT :: 8;

FEN_START_POS :: "rnbkqrnb/pppppppp/8/8/8/8/PPPPPPPP/RNBKQRNB"
FEN_TEST_POS  :: "rnbkqrnb/pppppppp/8/4p3/3P4/8/PPPPPPPP/RNBKQRNB"

Board :: struct {
    field: [BOARD_WIDTH][BOARD_HEIGHT]Square,
}

set_board :: proc(board: ^Board, fen_string: string) -> bool {
    len := len(fen_string);
    row: i8 = 0;
    col: i8 = 0;
    for c in fen_string {
        if row >= BOARD_HEIGHT do return false;
        if col > BOARD_WIDTH do return false;
        if c == '/' {
            if col != BOARD_WIDTH do return false;
            row += 1;
            col = 0;
            continue;
        }

        if unicode.is_digit(c) {
            col += i8(c) - i8('0');
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
    for y in 0..<BOARD_HEIGHT {
        fmt.printf("%d|", BOARD_HEIGHT - y)
        for x in 0..<BOARD_WIDTH {
            if board.field[y][x].piece.type != .Empty {
                fmt.print(piece_to_char(board.field[y][x].piece));
            } else do fmt.print(" ");
        }
        fmt.println("");
    }
    fmt.println("-+--------")
    fmt.println(" |abcdefgh")
}

play_move :: proc(board: ^Board, move: Move) -> (bool, MoveError) {
    ok, err := check_move(board, move);
    if ok do play_valid_move(board, move);
    return ok, err;
}

@(private="file")
play_valid_move :: proc(board: ^Board, move: Move) {
    board.field[move.y_to][move.x_to].piece = board.field[move.y_from][move.x_from].piece;
}

is_in_bounds :: proc(x: i8) -> bool {
    return x >= 0 && x < BOARD_WIDTH;
}
