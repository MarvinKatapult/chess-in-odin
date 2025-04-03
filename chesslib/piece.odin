package chess

import "core:unicode"

Piece :: struct {
    type: PieceType,
    color: PieceColor,
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
    Black
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
