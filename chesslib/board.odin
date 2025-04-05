package chess 

import "core:unicode"
import "core:fmt"
import "core:strconv"

BOARD_WIDTH  :: 8;
BOARD_HEIGHT :: 8;

WHITE_BASE_LINE :: 7;
BLACK_BASE_LINE :: 0;

FEN_START_POS :: "rnbkqrnb/pppppppp/8/8/8/8/PPPPPPPP/RNBKQRNB"
FEN_TEST_POS :: "r1bqk2r/pp1nbppp/2p1pn2/3p4/3P1B2/2NBPN2/PPP2PPP/R2QK2R"
FEN_TEST_POS2 :: "8/8/8/8/8/8/8/R3K2R"
FEN_EMPTY :: "8/8/8/8/8/8/8/8"

Board :: struct {
    field: [BOARD_WIDTH][BOARD_HEIGHT]Square,
    last_move: Move,
}

set_board :: proc(board: ^Board, fen_string: string = FEN_START_POS) -> bool {
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

print_board :: proc{print_board_normal, print_board_with_moves, print_board_with_moves_square}

print_board_normal :: proc(board: ^Board) {
    fmt.println("");
    for y in 0..<BOARD_HEIGHT {
        fmt.printf("%d|", y)
        for x in 0..<BOARD_WIDTH {
            if board.field[y][x].piece.type != .Empty {
                fmt.print(piece_to_char(board.field[y][x].piece));
            } else do fmt.print(" ");
        }
        fmt.println("");
    }
    fmt.println("-+--------")
    fmt.println(" |01234567")
}

print_board_with_moves :: proc(board: ^Board, moves: []Move) {
    fmt.println("");
    for y in 0..<BOARD_HEIGHT {
        fmt.printf("%d|", y)
        for x in 0..<BOARD_WIDTH {
            has_move, move := moves_contain_square_to(moves, i8(x), i8(y));
            is_moved, _ := moves_contain_square_from(moves, i8(x), i8(y));
            DEFAULT_COLOR :: "\x1b[0m";
            color_esc := DEFAULT_COLOR;
            is_capture := has_move && board.field[move.y_to][move.x_to].piece.type != .Empty;
            if is_capture    do color_esc = "\x1b[31m"; // Red
            else if has_move do color_esc = "\x1b[32m"; // Green
            else if is_moved do color_esc = "\x1b[34m"; // Blue

            if board.field[y][x].piece.type == .Empty {
                printed_move: bool;
                if has_move {
                    printed_move = true;
                    symbol := piece_to_char(board.field[move.y_from][move.x_from].piece);
                    fmt.printf("%s%c%s", color_esc, symbol, DEFAULT_COLOR);
                }
                if !printed_move do fmt.print(" ");
                continue;
            } 

            char := piece_to_char(board.field[y][x].piece);
            fmt.printf("%s%c%s", color_esc, char, DEFAULT_COLOR);
        }
        fmt.println("");
    }
    fmt.println("-+--------")
    fmt.println(" |01234567")
}

print_board_with_moves_square :: proc(board: ^Board, x: i8, y: i8) {
    moves: [dynamic]Move;
    defer delete(moves);
    get_valid_moves_for_square(board, x, y, &moves);
    if len(moves) > 0 {
        print_board_with_moves(board, moves[:]);
        fmt.println("Movecount:", len(moves));
    } else {
        fmt.println("No Moves for x:", x, "y:", y, "Symbol:", piece_to_char(board.field[y][x].piece));
    }
}

print_board_for_every_piece :: proc(board: ^Board) {
    for y in 0..<BOARD_HEIGHT {
        for x in 0..<BOARD_WIDTH {
            if board.field[y][x].piece.type != .Empty {
                print_board_with_moves_square(board, i8(x), i8(y));
            }
        }
    }
}

play_move :: proc(board: ^Board, valid_move: Move) {
    square_from: ^Square = &board.field[valid_move.y_from][valid_move.x_from];
    square_to: ^Square   = &board.field[valid_move.y_to][valid_move.x_to];
    square_to.piece = square_from.piece;
    if is_move_en_passant(board, valid_move) {
        pawn_dir := get_pawn_move_dir(square_from.piece.color);
        board.field[valid_move.y_to - i8(pawn_dir)][valid_move.x_to].piece.type = .Empty;
    } 
    if is_move_castling(board, valid_move) {
        rook_move: Move;
        if valid_move.x_to < valid_move.x_from { 
            rook_move.x_from = 0;
            rook_move.x_to   = valid_move.x_to + 1;
        } else {
            rook_move.x_from = 7;
            rook_move.x_to   = valid_move.x_to - 1;
        }
        rook_move.y_from = valid_move.y_from;
        rook_move.y_to   = valid_move.y_from;
        play_move(board, rook_move);
    }
    square_from.piece.type = .Empty;

    square_to.piece.moved = true;
    board.last_move = valid_move;
}

is_in_bounds :: proc(x: i8) -> bool {
    return x >= 0 && x < BOARD_WIDTH;
}
