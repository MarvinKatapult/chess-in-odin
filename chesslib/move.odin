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

get_piece_to_move :: proc(board: Board, move: Move) -> Piece {
    return board.field[move.y_from][move.x_from].piece;
}

get_valid_moves :: proc(board: ^Board, allocator := context.allocator) -> [dynamic]Move {
    moves := make([dynamic]Move, allocator);

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

    return;
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
    // Pawns can't capture pieces in front of them
    // That's why we check if the square we wan't to move to is also empty.
    valid, _ := basic_is_move_valid(board, new_move);
    if valid && board.field[new_y][x].piece.type == .Empty {
        append(moves, new_move);

        // Start Row
        if is_pawn_start_row(board, y, piece.color) {
            new_move.y_to += i8(move_direction);
            // Here again (Look above)
            valid, _ = basic_is_move_valid(board, new_move);
            if valid && board.field[new_y][x].piece.type == .Empty {
                append(moves, new_move);
            }
        }
    }

    // Capturing
    new_move.x_from = x;
    new_move.y_from = y;
    new_move.y_to   = y + i8(move_direction);

    new_move.x_to   = x - 1;
    capture: bool;
    valid, capture = basic_is_move_valid(board, new_move)
    if valid && capture do append(moves, new_move);

    new_move.x_to   = x + 1;
    valid, capture = basic_is_move_valid(board, new_move)
    if valid && capture do append(moves, new_move);

    // En Passant
    last_piece_moved := board.field[board.last_move.y_to][board.last_move.x_to].piece;
    if last_piece_moved.type != .Pawn do return;

    was_last_move_double_pawn := abs(board.last_move.y_from - board.last_move.y_to) == 2;
    if !was_last_move_double_pawn do return;

    was_last_move_enemy_pawn  := last_piece_moved.color != piece.color; 
    if !was_last_move_enemy_pawn do return;

    is_enemy_pawn_neighbor := abs(board.last_move.x_to - x) == 1;
    if !is_enemy_pawn_neighbor do return;

    new_move.x_from = x;
    new_move.y_from = y;
    new_move.x_to = board.last_move.x_to;
    new_move.y_to = y + i8(move_direction);

    valid, _ = basic_is_move_valid(board, new_move);
    if valid do append(moves, new_move);
}

@(private="file")
get_valid_moves_knight :: proc(board: ^Board, x: i8, y: i8, moves: ^[dynamic]Move) {
    for y_off in -2..=2 {
        for x_off in -2..=2 {
            if abs(y_off) == abs(x_off) do continue;
            if x_off == 0 || y_off == 0 do continue;

            possible_move: Move;
            possible_move.x_from = x;
            possible_move.y_from = y;
            possible_move.y_to = y + i8(y_off);
            possible_move.x_to = x + i8(x_off);

            valid, _ := basic_is_move_valid(board, possible_move);
            if valid do append(moves, possible_move);
        }
    }
}

@(private="file")
get_valid_moves_bishop :: proc(board: ^Board, x: i8, y: i8, moves: ^[dynamic]Move) {
    get_moves_directional(board, x, y, moves, vert_horz = false, diagonal = true);
}

@(private="file")
get_valid_moves_rook :: proc(board: ^Board, x: i8, y: i8, moves: ^[dynamic]Move) {
    get_moves_directional(board, x, y, moves, vert_horz = true, diagonal = false);
}

@(private="file")
get_valid_moves_queen :: proc(board: ^Board, x: i8, y: i8, moves: ^[dynamic]Move) {
    get_moves_directional(board, x, y, moves, vert_horz = true, diagonal = true);
}

@(private="file")
get_valid_moves_king :: proc(board: ^Board, x: i8, y: i8, moves: ^[dynamic]Move) {
    // Basic Movement
    for y_off in -1..=1 {
        for x_off in -1..=1 {
            if x_off == 0 && y_off == 0 do continue;

            move: Move;
            move.x_from = x;
            move.y_from = y;
            move.x_to   = x + i8(x_off);
            move.y_to   = y + i8(y_off);

            valid, _ := basic_is_move_valid(board, move);
            if valid do append(moves, move);
        }
    }

    // Castling
    king := board.field[y][x].piece;
    if king.moved do return;

    color := king.color;
    first_row := color == .White ? WHITE_BASE_LINE : BLACK_BASE_LINE;
    left_rook := board.field[first_row][0].piece;
    right_rook := board.field[first_row][7].piece;
    if left_rook.type == .Rook && !left_rook.moved {
        // Check if pieces are between them
        pieces: [3]Piece;
        pieces[0] = board.field[first_row][1].piece;
        pieces[0] = board.field[first_row][2].piece;
        pieces[0] = board.field[first_row][3].piece;
        if pieces[0].type == .Empty && pieces[1].type == .Empty && pieces[2].type == .Empty {
            move: Move;
            move.x_from = x;
            move.y_from = y;
            move.x_to = x - 2;
            move.y_to = y;
            assert(is_in_bounds(move.x_to), "X Out of Bounds, probably because moved-field for piece was not set correctly");
            append(moves, move);
        }
    }
    if right_rook.type == .Rook && !right_rook.moved {
        // Check if pieces are between them
        pieces: [2]Piece;
        pieces[0] = board.field[first_row][6].piece;
        pieces[0] = board.field[first_row][5].piece;
        if pieces[0].type == .Empty && pieces[1].type == .Empty {
            move: Move;
            move.x_from = x;
            move.y_from = y;
            move.x_to = x + 2;
            move.y_to = y;
            assert(is_in_bounds(move.x_to), "X Out of Bounds, probably because moved-field for piece was not set correctly");
            append(moves, move);
        }
    }
}

// Checks for basic move rules: Can't Move to square with piece of same color. And can check for capture
@(private="file")
basic_is_move_valid :: proc(board: ^Board, move: Move) -> (valid: bool, capture: bool) {
    if !is_in_bounds(move.x_to) || !is_in_bounds(move.y_to) do return false, false;
    piece_from := board.field[move.y_from][move.x_from].piece;
    piece_to   := board.field[move.y_to][move.x_to].piece;
    capture  = is_piece_captureable(piece_from, piece_to) 
    valid    = capture || piece_to.type == .Empty;
    return valid, capture;
}

@(private="file")
get_moves_directional :: proc(board: ^Board, x: i8, y: i8, moves: ^[dynamic]Move, vert_horz: bool, diagonal: bool) {
    for dir in 0..<4 {
        move: Move;
        move.x_from = x;
        move.y_from = y;
        still_diagonal := diagonal;
        still_vert_horz := vert_horz;

        for i in 1..<BOARD_WIDTH {
            if still_diagonal {
                switch dir {
                    case 0:
                        move.x_to = x + i8(i);
                        move.y_to = y + i8(i);
                    case 1:
                        move.x_to = x - i8(i);
                        move.y_to = y + i8(i);
                    case 2:
                        move.x_to = x + i8(i);
                        move.y_to = y - i8(i);
                    case 3:
                        move.x_to = x - i8(i);
                        move.y_to = y - i8(i);
                }
                valid, capture := basic_is_move_valid(board, move);
                if valid {
                    append(moves, move);
                    if capture do still_diagonal = false;
                } else do still_diagonal = false;
            }

            if still_vert_horz {
                switch dir {
                    case 0:
                        move.x_to = x + i8(i);
                        move.y_to = y;
                    case 1:
                        move.x_to = x - i8(i);
                        move.y_to = y;
                    case 2:
                        move.x_to = x;
                        move.y_to = y + i8(i);
                    case 3:
                        move.x_to = x;
                        move.y_to = y - i8(i);
                }
                valid, capture := basic_is_move_valid(board, move);
                if valid {
                    append(moves, move);
                    if capture do still_vert_horz = false;
                } else do still_vert_horz = false;
            }
        }
    }
}

is_move_en_passant :: proc(board: ^Board, move: Move) -> bool {
    moved_piece := board.field[move.y_from][move.x_from].piece;
    square_to   := board.field[move.y_to][move.x_to];
    if moved_piece.type != .Pawn do return false;
    
    return move.x_from != move.x_to && square_to.piece.type == .Empty;
}

is_move_castling :: proc(board: ^Board, move: Move) -> bool {
    moved_piece := board.field[move.y_from][move.x_from].piece;
    return moved_piece.type == .King && abs(move.x_to - move.x_from) == 2;
}

@(private="package")
moves_contain_square_to :: proc(moves: []Move, x: i8, y: i8) -> (bool, ^Move) {
    for &move in moves {
        if move.x_to == x && move.y_to == y do return true, &move;
    }
    return false, nil;
}

@(private="package")
moves_contain_square_from :: proc(moves: []Move, x: i8, y: i8) -> (bool, ^Move) {
    for &move in moves {
        if move.x_from == x && move.y_from == y do return true, &move;
    }
    return false, nil;
}

print_move_with_symbol :: proc(board: ^Board, move: Move) {
    symbol := piece_to_char(board.field[move.y_from][move.x_from].piece);
    fmt.printfln("Move:[x_from:%d; y_from:%d; x_to:%d; y_to:%d; symbol:%c]", move.x_from, move.y_from, move.x_to, move.y_to, symbol);
}
