package chess

import "core:fmt"

Move :: struct {
    x_from: i8,
    y_from: i8,
    x_to: i8,
    y_to: i8,
}

MoveError :: enum {
    Oob,
    NoPiece,
    FriendlyFire,
    PieceRules,
}

check_move :: proc(board: ^Board, move: Move) -> (bool, MoveError) {
    square_from: ^Square = &board.field[move.y_from][move.x_from];
    square_to  : ^Square = &board.field[move.y_to][move.x_to];
    if square_from.piece.type == .Empty                 do return false, .NoPiece;
    if square_from.piece.color == square_to.piece.color do return false, .FriendlyFire;

    // TODO: Für jedes Piece checken ob der move richtig ist
    // if false do return false, .PieceRules;

    return true, nil;
}

get_piece_to_move :: proc(board: Board, move: Move) -> Piece {
    return board.field[move.y_from][move.x_from].piece;
}

get_valid_moves :: proc(board: ^Board) -> (moves: [dynamic]Move) {

    for y in 0..<BOARD_HEIGHT {
        for x in 0..<BOARD_WIDTH {
            get_valid_moves_for_square(board, i8(x), i8(y), &moves);
        }
    }

    return moves;
}

get_valid_moves_for_square :: proc(board: ^Board, x: i8, y: i8, moves: ^[dynamic]Move) {
    piece_type := board.field[y][x].piece.type;
    if piece_type == .Empty do return;
    
    switch piece_type {
        case .Pawn:
            get_valid_moves_pawn(board, x, y, moves);
        case .Knight:
            get_valid_moves_knight(board, x, y, moves);
        case .Bishop:
            get_valid_moves_bishop(board, x, y, moves);
        case .Rook:
            get_valid_moves_rook(board, x, y, moves);
        case .Queen:
            get_valid_moves_queen(board, x, y, moves);
        case .King:
            get_valid_moves_king(board, x, y, moves);
        case .Empty:
            assert(false, "Unreachable Code");
    }
}

@(private="file")
get_valid_moves_pawn :: proc(board: ^Board, x: i8, y: i8, moves: ^[dynamic]Move) {
    piece := board.field[y][x].piece;

    move_direction := get_pawn_move_dir(piece.color);

    // Standard Pawn Moving
    new_y := y + i8(move_direction);
    new_move: Move;
    new_move.x_from = x;
    new_move.y_from = y;
    new_move.x_to = x;
    new_move.y_to = new_y;
    if basic_is_move_valid(board, new_move) {
        fmt.println("Appending Move for Pawn");
        append(moves, new_move);

        // Start Row
        if is_pawn_start_row(board, y, piece.color) {
            fmt.println("Pawn at startrow");
            new_move.y_to += i8(move_direction);
            if basic_is_move_valid(board, new_move) {
                append(moves, new_move);
                fmt.println("Appending Move for Pawn (Startrow)");
            }
        }
    }

    // Capturing
    possible_capture: Move;
    possible_capture.x_from = x;
    possible_capture.y_from = y;
    possible_capture.y_to   = y + i8(move_direction);

    possible_capture.x_to   = x - 1;
    if basic_is_move_valid(board, possible_capture) {
        capture_piece := board.field[possible_capture.y_to][possible_capture.x_to].piece;
        if capture_piece.type != .Empty do append(moves, possible_capture);
    }

    possible_capture.x_to   = x + 1;
    if basic_is_move_valid(board, possible_capture) {
        capture_piece := board.field[possible_capture.y_to][possible_capture.x_to].piece;
        if capture_piece.type != .Empty do append(moves, possible_capture);
    }
}

@(private="file")
get_valid_moves_knight :: proc(board: ^Board, x: i8, y: i8, moves: ^[dynamic]Move) {

}

@(private="file")
get_valid_moves_bishop :: proc(board: ^Board, x: i8, y: i8, moves: ^[dynamic]Move) {

}

@(private="file")
get_valid_moves_rook :: proc(board: ^Board, x: i8, y: i8, moves: ^[dynamic]Move) {

}

@(private="file")
get_valid_moves_queen :: proc(board: ^Board, x: i8, y: i8, moves: ^[dynamic]Move) {

}

@(private="file")
get_valid_moves_king :: proc(board: ^Board, x: i8, y: i8, moves: ^[dynamic]Move) {

}

// Checks for basic move rules: Can't Move to square with piece of same color. And can check for capture
@(private="file")
basic_is_move_valid :: proc(board: ^Board, move: Move) -> bool {
    if !is_in_bounds(move.x_to) || !is_in_bounds(move.y_to) do return false;
    piece_from := board.field[move.y_from][move.x_from].piece;
    piece_to   := board.field[move.y_to][move.x_to].piece;
    can_move := is_piece_captureable(piece_from, piece_to) || piece_to.type == .Empty;
    return can_move;
}
