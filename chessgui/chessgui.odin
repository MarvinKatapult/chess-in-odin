package chessgui

import "../chesslib"
import rl "vendor:raylib"

import "core:fmt"
import "core:os"

@(private="file")
WINDOW_START_WIDTH :: 600;
@(private="file")
WINDOW_START_HEIGHT :: 600;

SQUARE_SIZE :: WINDOW_START_WIDTH / chesslib.BOARD_WIDTH;

board: chesslib.Board;
valid_moves: [dynamic]chesslib.Move;
turn: chesslib.PieceColor = .White;

WR_TEXTURE: rl.Texture2D;
BR_TEXTURE: rl.Texture2D;
WK_TEXTURE: rl.Texture2D;
BK_TEXTURE: rl.Texture2D;
WB_TEXTURE: rl.Texture2D;
BB_TEXTURE: rl.Texture2D;
WN_TEXTURE: rl.Texture2D;
BN_TEXTURE: rl.Texture2D;
WQ_TEXTURE: rl.Texture2D;
BQ_TEXTURE: rl.Texture2D;
WP_TEXTURE: rl.Texture2D;
BP_TEXTURE: rl.Texture2D;

SelectedSquare :: struct {
    x: i8,
    y: i8,
}

selected_square: SelectedSquare = {-1,-1};

start_chess_game :: proc() {

    fmt.println("TEXTURES LOADED");
    defer unload_textures();
    chesslib.set_board(&board, chesslib.FEN_START_POS);
    rl.InitWindow(WINDOW_START_WIDTH, WINDOW_START_HEIGHT, "Chess");
    load_textures();
    rl.SetTargetFPS(60);
    
    for !rl.WindowShouldClose() {
        handle_input();
        rl.BeginDrawing();
            draw_board();
        rl.EndDrawing();
    }
}

@(private="file")
handle_input :: proc() {
    if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {

        square := get_square_under_mouse();
        contains, move := chesslib.moves_contain_square_to(valid_moves[:], square.x, square.y)
        if contains {
            chesslib.play_move(&board, move^);
            clear(&valid_moves);
            turn = turn == .White ? .Black : .White;
            return;
        }

        piece  := board.field[square.y][square.x].piece;
        if piece.color == turn {
            clear(&valid_moves);
            chesslib.get_valid_moves_for_square(&board, square.x, square.y, &valid_moves);
        }
    }
}

@(private="file")
get_square_under_mouse :: proc() -> SelectedSquare {
    return {i8(rl.GetMouseX() / SQUARE_SIZE), i8(rl.GetMouseY() / SQUARE_SIZE)};
}

@(private="file")
load_textures :: proc() {
    load_texture("assets/Chess_plt60.png", &WP_TEXTURE);
    load_texture("assets/Chess_pdt60.png", &BP_TEXTURE);
    load_texture("assets/Chess_blt60.png", &WB_TEXTURE);
    load_texture("assets/Chess_bdt60.png", &BB_TEXTURE);
    load_texture("assets/Chess_nlt60.png", &WN_TEXTURE);
    load_texture("assets/Chess_ndt60.png", &BN_TEXTURE);
    load_texture("assets/Chess_rlt60.png", &WR_TEXTURE);
    load_texture("assets/Chess_rdt60.png", &BR_TEXTURE);
    load_texture("assets/Chess_qlt60.png", &WQ_TEXTURE);
    load_texture("assets/Chess_qdt60.png", &BQ_TEXTURE);
    load_texture("assets/Chess_klt60.png", &WK_TEXTURE);
    load_texture("assets/Chess_kdt60.png", &BK_TEXTURE);
}

@(private="file")
load_texture :: proc(path: cstring, var: ^rl.Texture) {
    image: rl.Image = rl.LoadImage(path);
    defer rl.UnloadImage(image);
    if !rl.IsImageValid(image) do os.close(-1);
    rl.ImageResize(&image, SQUARE_SIZE, SQUARE_SIZE);
    var^ = rl.LoadTextureFromImage(image);
}

unload_textures :: proc() {
    rl.UnloadTexture(WR_TEXTURE);
    rl.UnloadTexture(BR_TEXTURE);
    rl.UnloadTexture(WK_TEXTURE);
    rl.UnloadTexture(BK_TEXTURE);
    rl.UnloadTexture(WB_TEXTURE);
    rl.UnloadTexture(BB_TEXTURE);
    rl.UnloadTexture(WN_TEXTURE);
    rl.UnloadTexture(BN_TEXTURE);
    rl.UnloadTexture(WQ_TEXTURE);
    rl.UnloadTexture(BQ_TEXTURE);
    rl.UnloadTexture(WP_TEXTURE);
    rl.UnloadTexture(BP_TEXTURE);
}

draw_board :: proc() {
    // Squares
    for y in 0..<chesslib.BOARD_HEIGHT {
        for x in 0..<chesslib.BOARD_WIDTH {
            x_rect := i32(x) * WINDOW_START_WIDTH / chesslib.BOARD_WIDTH;
            y_rect := i32(y) * WINDOW_START_HEIGHT / chesslib.BOARD_HEIGHT;
            size_rect := rl.GetScreenWidth() / chesslib.BOARD_WIDTH;
    
            color := (x % 2) == 0 ? rl.PINK : rl.WHITE;
            if y % 2 == 0 do color = (color == rl.PINK ? rl.WHITE : rl.PINK);
    
            rl.DrawRectangle(x_rect, y_rect, size_rect, size_rect, color);
        }
    }

    // Pieces
    for y in 0..<chesslib.BOARD_HEIGHT {
        for x in 0..<chesslib.BOARD_WIDTH {
            piece := board.field[y][x].piece;
            x_pos := i32(x) * SQUARE_SIZE;
            y_pos := i32(y) * SQUARE_SIZE;
            switch piece.type {
                case .Pawn:
                    texture := piece.color == .White ? WP_TEXTURE : BP_TEXTURE;
                    rl.DrawTexture(texture, x_pos, y_pos, rl.WHITE);
                case .Rook:
                    texture := piece.color == .White ? WR_TEXTURE : BR_TEXTURE;
                    rl.DrawTexture(texture, x_pos, y_pos, rl.WHITE);
                case .Bishop:
                    texture := piece.color == .White ? WB_TEXTURE : BB_TEXTURE;
                    rl.DrawTexture(texture, x_pos, y_pos, rl.WHITE);
                case .Knight:
                    texture := piece.color == .White ? WN_TEXTURE : BN_TEXTURE;
                    rl.DrawTexture(texture, x_pos, y_pos, rl.WHITE);
                case .Queen:
                    texture := piece.color == .White ? WQ_TEXTURE : BQ_TEXTURE;
                    rl.DrawTexture(texture, x_pos, y_pos, rl.WHITE);
                case .King:
                    texture := piece.color == .White ? WK_TEXTURE : BK_TEXTURE;
                    rl.DrawTexture(texture, x_pos, y_pos, rl.WHITE);
                case .Empty:
                    continue;
            }
        }
    }

    // Valid Moves
    for move in valid_moves {
        rl.DrawCircle(i32(move.x_to) * SQUARE_SIZE + SQUARE_SIZE / 2, i32(move.y_to) * SQUARE_SIZE + SQUARE_SIZE / 2, 15, {55, 55, 55, 55});
    }
}
