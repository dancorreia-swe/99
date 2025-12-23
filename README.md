## The AI Agent That Neovim Deserves

### TODO
- if the function's definition in typescript is mutli-line

```typescript
function display_text(
  game_state: GameState,
  text: string,
  x: number,
  y: number,
): void {
  const ctx = game_state.canvas.getContext("2d");
  assert(ctx, "cannot get game context");
  ctx.fillStyle = "white";
  ctx.fillText(text, x, y);
}
```

Then the virtual text will be displayed one line below "function" instead of first line in body

### Feature
able to use visual selection to send off a request to the ai and have the visual selection replaced by ai
