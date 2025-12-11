// ---
// Copyright 2025 Alexandros F. G. Kapretsos
// SPDX-License-Identifier: MIT
// Email: alexandroskapretsos@gmail.com
// Project: https://github.com/Kapendev/joka
// ---

package com_kapendev_very_text

import rl "vendor:raylib"
import io "core:fmt"

when true {
    // SPDX-License-Identifier: MIT
    main :: proc() {
        beginWindow(1280, 720)
        for {
            beginLoop() or_break
		    rl.DrawRectangle(rl.GetMouseX(), rl.GetMouseY(), 32, 32, rl.PINK)
            rl.DrawText("Hello", 32, 32, 60, rl.BLUE) // The **SLOW** raylib version.
		    DrawTextEx({}, "Hello", {32, 90}, 60)     // The memory safe and blazing fast Odin version.
	    }
    }
}

// SPDX-License-Identifier: MIT
DrawTextEx :: proc(font: rl.Font, text: string, position: rl.Vector2, fontSize: f32, spacing: f32 = 6, tint: rl.Color = rl.WHITE, textLineSpacing: i32 = 2) {
    font := font
    
    if font.texture.id == 0 {
        font = rl.GetFontDefault() // Security check in case of not valid font
    }

    size: i32 = i32(len(text)); // Total size in bytes of the text, scanned by codepoints in loop
    textOffsetY: f32            // Offset between lines (on linebreak '\n')
    textOffsetX: f32            // Offset X to next character to draw

    scaleFactor: f32 = fontSize / f32(font.baseSize); // Character quad scaling factor

    i: i32 = 0
    for i < size {
        // Get next codepoint from byte string and glyph index in font
        codepointByteCount: i32 = 0;
        codepoint := rl.GetCodepointNext(cstring(&raw_data(text)[i]), &codepointByteCount);
        index: i32 = rl.GetGlyphIndex(font, codepoint);

        if codepoint == '\n' {
            // NOTE: Line spacing is a global variable, use SetTextLineSpacing() to setup
            textOffsetY += fontSize + f32(textLineSpacing)
            textOffsetX = 0.0
        } else {
            if (codepoint != ' ') && (codepoint != '\t') {
                rl.DrawTextCodepoint(font, codepoint, {position.x + textOffsetX, position.y + textOffsetY}, fontSize, tint)
            }
            if font.glyphs[index].advanceX == 0 {
                textOffsetX += font.recs[index].width * scaleFactor + spacing
            } else {
                textOffsetX += f32(font.glyphs[index].advanceX) * scaleFactor + spacing
            }
        }
        i += codepointByteCount; // Move text bytes counter to next codepoint
    }
}

// Nice.

Window :: distinct bool

@(deferred_out=endWindow)
beginWindow :: proc(width: int, height: int, title: cstring = "very_text") -> Window {
    rl.InitWindow(i32(width), i32(height), title)
    rl.SetTargetFPS(60)
    return true
}

endWindow :: proc(self: Window) {
    rl.CloseWindow()
}

Loop :: distinct bool

@(deferred_out=endLoop)
beginLoop :: proc() -> Loop {
    if !rl.WindowShouldClose() {
	    rl.BeginDrawing()
	    rl.ClearBackground({50, 50, 50, 255})
        return true
    } else {
        return false
    }
}

endLoop :: proc(self: Loop) {
    if self do rl.EndDrawing()
}
