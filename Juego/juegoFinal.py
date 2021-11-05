#!/usr/bin/env python
# -*- coding: utf-8 -*-
import random
import time
import pygame
from pygame.locals import *

from block import *
from bullet import *
from global_constants import *




pygame.init()
# Display
screen = pygame.display.set_mode((WIDTH, HEIGHT))
fullscreen = False
# Window titlebar
pygame.display.set_caption('Corona Attack v1')
pygame.display.set_icon(pygame.image.load('bullet.png'))
fondoIntro=pygame.image.load('fondo0101.png')
fondoGame=pygame.image.load('fondoGame.jpg')
fondoFin=pygame.image.load('fondo0101.png')

# Timing
fps_clock = pygame.time.Clock()
FPS = 60

default_font = pygame.font.Font(None, 28)


def draw_text(text, font, surface, x, y, main_color, background_color=None):
    textobj = font.render(text, True, main_color, background_color)
    textrect = textobj.get_rect()
    textrect.centerx = x
    textrect.centery = y
    surface.blit(textobj, textrect)


def toggle_fullscreen():
    if pygame.display.get_driver() == 'x11':
        pygame.display.toggle_fullscreen()
    else:
        global screen, fullscreen
        screen_copy = screen.copy()
        if fullscreen:
            screen = pygame.display.set_mode((WIDTH, HEIGHT))
        else:
            screen = pygame.display.set_mode((WIDTH, HEIGHT), pygame.FULLSCREEN)
        fullscreen = not fullscreen
        screen.blit(fondo, [0, 0])


def start_screen():
    screen.blit(fondoIntro, [0, 0])
    pygame.mouse.set_cursor(*pygame.cursors.diamond)
    pygame.mixer.music.load("Sonidos/intro.mp3")
    pygame.mixer.music.play(2)
    while True:
        title_font = pygame.font.Font('freesansbold.ttf', 65)
        big_font = pygame.font.Font(None, 36)
        medium_font = pygame.font.Font(None, 20)
        small_font = pygame.font.Font(None, 15)
        draw_text('CORONA ATTACK', title_font, screen,
                  WIDTH / 2, HEIGHT / 5, RED, YELLOW)
        draw_text('Usa el mouse para esquivar los virus', big_font, screen,
                  WIDTH / 2, HEIGHT / 2, GREEN, BLACK)
        draw_text('Presiona cualquier botón del mouse o S cuando estés listo.',
                  default_font, screen, WIDTH / 2, HEIGHT / 1.7, GREEN, BLACK)
        draw_text('Presiona P para pausar.',
                  medium_font, screen, WIDTH / 2, HEIGHT / 1.5, GREEN, BLACK)
        draw_text('By: Damian Granda-Agustin Di Carlo-Luca Fattorini-Lucas Figueroa-Francisco Gomez- Jonathan diaz',small_font, screen,
                  WIDTH / 2, HEIGHT / 1.05, GREEN, BLACK)
        
        pygame.display.update()
        for event in pygame.event.get():
            if event.type == pygame.MOUSEBUTTONDOWN:
                main_loop()
                return
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_s:
                    main_loop()
                    return
                if event.key == K_F11:
                    toggle_fullscreen()
            if event.type == QUIT:
                return

def pausa():
    pausado = True

    while pausado:
        title_font = pygame.font.Font('freesansbold.ttf', 65)
        big_font = pygame.font.Font(None, 36)
        draw_text('Juego en pausa', title_font, screen,
                  WIDTH / 2, HEIGHT / 5, RED, YELLOW)
        draw_text('Precione SPACE para reanudar, o presione R para resetear', big_font, screen,
                  WIDTH / 2, HEIGHT / 2, GREEN, BLACK)
        pygame.display.update()

        for event in pygame.event.get():
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_SPACE:
                    pausado = False
                if event.key == pygame.K_r:
                    start_screen()
                    return

def main_loop():
    pygame.mouse.set_visible(False)
    pygame.mixer.music.stop()
    pygame.mixer.music.load("Sonidos/intro3.mp3")
    pygame.mixer.music.play(2)
    square = Block()
    square.set_pos(*pygame.mouse.get_pos())
    bullets = pygame.sprite.Group()
    running = True
    game_over = False
    points = 0
    min_bullet_speed = 1
    max_bullet_speed = 6
    bullets_per_gust = 1

    while running:
        pygame.display.update()
        fps_clock.tick(FPS)
        screen.blit(fondoGame, [0, 0])
        if points >= 2000:
            bullets_per_gust = 3000
            max_bullet_speed = 80
        elif points >= 1000:
            bullets_per_gust = 3
            min_bullet_speed = 3
            max_bullet_speed = 15
        elif points >= 800:
            max_bullet_speed = 20
        elif points >= 600:
            bullets_per_gust = 2
            max_bullet_speed = 10
        elif points >= 500:
            min_bullet_speed = 2
        elif points >= 400:
            max_bullet_speed = 8
        elif points >= 200:
            # The smaller this number is, the probability for a bullet
            # to be shot is higher
            odds = 8
            max_bullet_speed = 5
        elif points >= 100:
            odds = 9
            max_bullet_speed = 4
        elif points >= 60:
            odds = 10
            max_bullet_speed = 3
        elif points >= 30:
            odds = 11
            max_bullet_speed = 2
        elif points < 30:
            odds = 12

        if random.randint(1, odds) == 1:
            for _ in range(0, bullets_per_gust):
                bullets.add(random_bullet(random.randint(min_bullet_speed,
                                                         max_bullet_speed)))
                points += 1
        draw_text('{}  Puntos'.format(points), default_font, screen,
                  WIDTH / 2, 20, GREEN)
        bullets.update()
        bullets.draw(screen)

        if square.collide(bullets):
            game_over = True
            pygame.mixer.music.load("Sonidos/gameover.mp3")
            pygame.mixer.music.play(2)

        screen.blit(square.img, square.rect)
        for event in pygame.event.get():
            if event.type == pygame.MOUSEMOTION:
                mouse_pos = pygame.mouse.get_pos()
                square.set_pos(*mouse_pos)
            if event.type == QUIT:
                running = False
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_p:
                   pausa()




        
    
        while game_over:
            screen.blit(fondoFin, [0, 0])
            pygame.mouse.set_visible(True)
            # Texto
            draw_text('{}  Puntos'.format(points), default_font, screen,
                      WIDTH / 2, 20, GREEN)
            # Transparent surface
            transp_surf = pygame.Surface((WIDTH, HEIGHT))
            transp_surf.set_alpha(200)
            screen.blit(transp_surf, transp_surf.get_rect())

            draw_text('Perdiste', pygame.font.Font(None, 40), screen,
                      WIDTH / 2, HEIGHT / 3, RED)
            draw_text('Para jugar de nuevo presione C o cualquier botón del mouse',
                      default_font, screen, WIDTH / 2, HEIGHT / 2.1, GREEN)
            draw_text('Para salir del juego presione Q', default_font, screen,
                      WIDTH / 2, HEIGHT / 1.9, GREEN)
            #pygame.mixer.music.stop()
            pygame.display.update()
            pygame.display.update()

            for event in pygame.event.get():
                if event.type == pygame.KEYDOWN:
                    if event.key == K_F11:
                        toggle_fullscreen()
                    if event.key == pygame.K_q:
                        game_over = False
                        running = False
                    elif event.key == pygame.K_c:
                        game_over = False
                        main_loop()
                        return  # Avoids recursionp

                if event.type == pygame.MOUSEBUTTONDOWN:
                    game_over = False
                    main_loop()
                    return
                if event.type == QUIT:
                    game_over = False
                    running = False

start_screen()
pygame.quit()