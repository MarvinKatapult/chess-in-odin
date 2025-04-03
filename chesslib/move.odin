package chess

Move :: struct {
    x_from: u8,
    y_from: u8,
    x_to: u8,
    y_to: u8,
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
