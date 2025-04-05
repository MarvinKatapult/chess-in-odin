package chess

import "core:unicode"

KING_START_X :: 4
KING_START_Y_BLACK :: 7
KING_START_Y_WHITE :: 0

Piece :: struct {
    type: PieceType,
    color: PieceColor,
    moved: bool,
}

PieceType :: enum {
    Empty = 0,
    Pawn,
    Bishop,
    Knight,
    Rook,
    Queen,
    King,
}

PieceColor :: enum {
    White = 0,
    Black,
}

@(private="file")
PawnMoveDir :: enum {
    Up = -1,
    Down = 1,
}

char_to_piece :: proc(c: rune) -> (p: Piece, ok: bool) {
    p.color = unicode.is_upper(c) ? .White : .Black;
    c := unicode.to_upper(c);
    
    switch c {
        case 'P':
            p.type = .Pawn;
        case 'B':
            p.type = .Bishop;
        case 'N':
            p.type = .Knight;
        case 'R':
            p.type = .Rook;
        case 'Q':
            p.type = .Queen;
        case 'K':
            p.type = .King;
    }

    ok = p.type != .Empty;
    return p, ok;
}

piece_to_char :: proc(p: Piece) -> (c: rune) {
    switch p.type {
        case .Pawn:
            c = p.color == .White ? 'P' : 'p';
        case .Bishop:
            c = p.color == .White ? 'B' : 'b';
        case .Knight:
            c = p.color == .White ? 'N' : 'n';
        case .Rook:
            c = p.color == .White ? 'R' : 'r';
        case .Queen:
            c = p.color == .White ? 'Q' : 'q';
        case .King:
            c = p.color == .White ? 'K' : 'k';
        case .Empty:
            c = ' ';
    }
    return c;
}

is_pawn_start_row :: proc(board: ^Board, y: i8, color: PieceColor) -> bool {
    return color == .White ? y == BOARD_HEIGHT - 1 : y == 1;
}

get_pawn_move_dir :: proc(color: PieceColor) -> PawnMoveDir {
    return color == .White ? .Up : .Down;
}

is_piece_captureable :: proc(my_piece: Piece, enemy_piece: Piece) -> bool {
    return my_piece.color != enemy_piece.color && enemy_piece.type != .Empty;
}
