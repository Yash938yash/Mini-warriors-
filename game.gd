
extends Node2D

const FLOOR_Y = 590.0
var player_pos = Vector2(180, FLOOR_Y)
var player_hp = 100
var bullets = []
var enemies = []
var move_dir = 0
var firing = false
var jumping = false
var jump_speed = 0.0
var score = 0
var game_over = false

func _ready():
    for i in range(4):
        enemies.append({"pos": Vector2(600 + i * 140, FLOOR_Y), "hp": 100})
    queue_redraw()

func _process(delta):
    if game_over:
        queue_redraw()
        return

    player_pos.x = clamp(player_pos.x + move_dir * 300 * delta, 25, 1255)

    if jumping:
        jump_speed += 1000 * delta
        player_pos.y += jump_speed * delta
        if player_pos.y >= FLOOR_Y:
            player_pos.y = FLOOR_Y
            jumping = false
            jump_speed = 0

    if firing:
        bullets.append({"pos": player_pos + Vector2(25, -35), "life": 1.2})

    firing = false

    for b in bullets:
        b.pos.x += 700 * delta
        b.life -= delta
        for e in enemies:
            if e.hp > 0 and b.pos.distance_to(e.pos + Vector2(0, -25)) < 35:
                e.hp -= 35
                b.life = 0
                if e.hp <= 0:
                    score += 1

    bullets = bullets.filter(func(b): return b.life > 0)

    for e in enemies:
        if e.hp > 0 and abs(e.pos.x - player_pos.x) < 500:
            e.pos.x = move_toward(e.pos.x, player_pos.x + 200, 40 * delta)

    queue_redraw()

func _input(event):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_A:
            move_dir = -1
        elif event.keycode == KEY_D:
            move_dir = 1
        elif event.keycode == KEY_SPACE and not jumping:
            jumping = true
            jump_speed = -420
        elif event.keycode == KEY_J:
            firing = true
    elif event is InputEventKey and not event.pressed:
        if event.keycode == KEY_A or event.keycode == KEY_D:
            move_dir = 0

func _draw():
    draw_rect(Rect2(0, 0, 1280, 720), Color("#17263b"))
    draw_rect(Rect2(0, FLOOR_Y, 1280, 130), Color("#42604b"))

    for i in range(8):
        draw_rect(Rect2(i * 180 + 50, 450, 90, 20), Color("#657d91"))

    draw_rect(Rect2(player_pos.x - 15, player_pos.y - 50, 30, 45), Color("#45d6b7"))
    draw_circle(player_pos + Vector2(0, -60), 15, Color("#f1c7a0"))
    draw_rect(Rect2(player_pos.x + 10, player_pos.y - 42, 35, 7), Color("#b7c9dc"))

    for e in enemies:
        if e.hp > 0:
            draw_rect(Rect2(e.pos.x - 15, e.pos.y - 45, 30, 45), Color("#e36d5b"))
            draw_circle(e.pos + Vector2(0, -55), 14, Color("#e9bd9a"))
            draw_rect(Rect2(e.pos.x - 20, e.pos.y - 75, 40 * e.hp / 100.0, 5), Color("#70e09d"))

    for b in bullets:
        draw_circle(b.pos, 5, Color("#ffe38b"))

    draw_string(ThemeDB.fallback_font, Vector2(30, 40), "MINI WARRIORS  |  HP: %d  |  KOs: %d" % [player_hp, score], HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
    draw_string(ThemeDB.fallback_font, Vector2(30, 690), "A/D: MOVE     SPACE: JUMP     J: FIRE", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
