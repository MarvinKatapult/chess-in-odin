package chessgui

import "../chesslib"
import rl "vendor:raylib"

import "core:fmt"
import "core:os"

@(private="file")
WINDOW_START_WIDTH :: 600;
@(private="file")
WINDOW_START_HEIGHT :: 600;

board: chesslib.Board;

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

start_chess_game :: proc() {

    load_textures();
    fmt.println("TEXTURES LOADED");
    defer unload_textures();
    chesslib.set_board(&board, chesslib.FEN_START_POS);
    rl.SetTargetFPS(60);
    rl.InitWindow(WINDOW_START_WIDTH, WINDOW_START_HEIGHT, "Chess");
    
    for !rl.WindowShouldClose() {
        rl.BeginDrawing();
            draw_board();
        rl.EndDrawing();
    }
}

load_textures :: proc() {
    WR_TEXTURE = rl.LoadTexture("~/dev/odin/chess-in-odin/Chess_rlt60.png")
    BR_TEXTURE = rl.LoadTexture("~/dev/odin/chess-in-odin/Chess_rdt60.png");
    WK_TEXTURE = rl.LoadTexture("~/dev/odin/chess-in-odin/Chess_klt60.png");
    BK_TEXTURE = rl.LoadTexture("~/dev/odin/chess-in-odin/Chess_kdt60.png");
    WB_TEXTURE = rl.LoadTexture("~/dev/odin/chess-in-odin/Chess_blt60.png");
    BB_TEXTURE = rl.LoadTexture("~/dev/odin/chess-in-odin/Chess_bdt60.png");
    WN_TEXTURE = rl.LoadTexture("~/dev/odin/chess-in-odin/Chess_nlt60.png");
    BN_TEXTURE = rl.LoadTexture("~/dev/odin/chess-in-odin/Chess_ndt60.png");
    WQ_TEXTURE = rl.LoadTexture("~/dev/odin/chess-in-odin/Chess_qlt60.png");
    BQ_TEXTURE = rl.LoadTexture("~/dev/odin/chess-in-odin/Chess_qdt60.png");
    WP_TEXTURE = rl.LoadTexture("~/dev/odin/chess-in-odin/Chess_plt60.png");
    BP_TEXTURE = rl.LoadTexture("~/dev/odin/chess-in-odin/Chess_pdt60.png");
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
            x_rect := i32(x) * rl.GetScreenWidth() / chesslib.BOARD_WIDTH;
            y_rect := i32(y) * rl.GetScreenHeight() / chesslib.BOARD_HEIGHT;
            size_rect := rl.GetScreenWidth() / chesslib.BOARD_WIDTH;

            color := (x % 2) == 0 ? rl.BLUE : rl.WHITE;
            if y % 2 == 0 do color = (color == rl.BLUE ? rl.WHITE : rl.BLUE);

            rl.DrawRectangle(x_rect, y_rect, size_rect, size_rect, color);
        }
    }

    // Pieces
    for y in 0..<chesslib.BOARD_HEIGHT {
        for x in 0..<chesslib.BOARD_WIDTH {
            piece := board.field[y][x].piece;
            text_rect: rl.Vector2 = {
                f32(x) * f32(WINDOW_START_WIDTH) / f32(chesslib.BOARD_WIDTH), 
                f32(y) * f32(WINDOW_START_HEIGHT) / f32(chesslib.BOARD_HEIGHT)
            }
            switch piece.type {
                case .Pawn:
                    rl.DrawTextureV(piece.color == .White ? WP_TEXTURE : BP_TEXTURE, text_rect, rl.WHITE);
                case .Rook:
                    rl.DrawTextureV(piece.color == .White ? WR_TEXTURE : BR_TEXTURE, text_rect, rl.WHITE);
                case .Bishop:
                    rl.DrawTextureV(piece.color == .White ? WB_TEXTURE : BB_TEXTURE, text_rect, rl.WHITE);
                case .Knight:
                    rl.DrawTextureV(piece.color == .White ? WN_TEXTURE : BN_TEXTURE, text_rect, rl.WHITE);
                case .Queen:
                    rl.DrawTextureV(piece.color == .White ? WQ_TEXTURE : BQ_TEXTURE, text_rect, rl.WHITE);
                case .King:
                    rl.DrawTextureV(piece.color == .White ? WK_TEXTURE : BK_TEXTURE, text_rect, rl.WHITE);
                case .Empty:
                    continue;
            }
            fmt.println("Piece:", piece);
        }
    }
}
