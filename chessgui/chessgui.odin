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

start_chess_game :: proc() {

    chesslib.set_board(&board, chesslib.FEN_START_POS);
    rl.InitWindow(WINDOW_START_WIDTH, WINDOW_START_HEIGHT, "Chess");
    
    for !rl.WindowShouldClose() {
        rl.BeginDrawing();
            draw_board();
        rl.EndDrawing();
    }
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
            image_path: cstring;
            piece := board.field[y][x].piece;
            switch piece.type {
                case .Pawn:
                    image_path = piece.color == .White ? "Chess_plt60.png" : "Chess_pdt60.png";
                case .Rook:
                    image_path = piece.color == .White ? "Chess_rlt60.png" : "Chess_rdt60.png";
                case .Bishop:
                    image_path = piece.color == .White ? "Chess_blt60.png" : "Chess_bdt60.png";
                case .Knight:
                    image_path = piece.color == .White ? "Chess_nlt60.png" : "Chess_ndt60.png";
                case .Queen:
                    image_path = piece.color == .White ? "Chess_qlt60.png" : "Chess_qdt60.png";
                case .King:
                    image_path = piece.color == .White ? "Chess_klt60.png" : "Chess_kdt60.png";
                case .Empty:
                    image_path = "";
            }
            if image_path != "" {
                texture := rl.LoadTexture(image_path)
                if !rl.IsTextureValid(texture) {
                    fmt.eprintln("Texture not loaded");
                    os.exit(1);
                }
                defer rl.UnloadTexture(texture);

                rl.DrawTexture(texture, i32(x) * WINDOW_START_WIDTH / chesslib.BOARD_WIDTH, i32(y) * WINDOW_START_HEIGHT / chesslib.BOARD_HEIGHT, {255, 255, 255, 255});
            }
        }
    }
}
