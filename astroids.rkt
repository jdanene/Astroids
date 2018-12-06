;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname astroids) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)

#|

                                            ASTROIDS


Game Description:
    The player controls a spaceships movement and shoots rocks floating through space. The
    player starts with 3 lifes, if a rock hits the spaceship the player loses a life. If a player shoots
    a rock, the rock is destoyed. After shooting a set amount of rocks the level increases in hardness
    by adding more rocks with possibly complex (lorenz movements) movements through space.
    The smaller the rock the faster it moves, and the more points you get for shooting it down.

    Once the ship begins moving in a direction, it will continue in that direction for a time without player intervention unless the player applies
    thrust in a different direction. A ship never stops once you hit the space bar... unless the ship
    the ship is destroyed. In this case the ship is reset in the middle of the screen. As the player
    shoots asteroids, they break into smaller asteroids that move faster and are more difficult to hit.
    There is a smallest astroid that will actually be destroyed and disppear if hit.

Game Controls:
   - up or "w" key: Accelerate the spaceship forwards
   - down or "s" key: Accelerate the spaceship backward
   - left or "a" key: Turns the spaceship's nose to the left
   - right key or "d": Turns the spaceship's nose to the right
   - spacebar: shoots projectile from nose of spaceship

 ------------ Add these functionality if time permits -----------------
    Two flying saucers appear periodically on the screen; the "big saucer" shoots randomly and poorly,
    while the "small saucer" fires frequently at the ship. After reaching a score of 40,000, only
    the small saucer appears. As the player's score increases, the angle range of the shots from the
    small saucer diminishes until the saucer fires extremely accurately. Add a level if have time, essentially
     the level will depend directly to `score`
|#

#| -----------   Main Definitions and Structs -----------   |#

;; An angle is a number between 0 and 360
;; Interpretation: Usual interpretation of a geometric angle

;; A spaceship is
;;   (make-spaceship posn  -- spaceships location
;;                   angle  - angle of spaceship
;;                   boolean -- tells if spaceship accelerating or not)
(define-struct spaceship (posn pos angle acc?))

;; A projectile is
;;   (make-projectile posn  -- prev location
;;                    posn  --next location)
(define-struct projectile (posn pos-prev pos-next))

;; A size is either a integer between 1 and 5
;; Interpretation:  If an astroid with n>1 is destroyed it splits into two astroids of size n-1.
;; When an astroid has size 1 it can be destroyed.

;; A astroid is
;;   (make-astroid posn  -- prev location
;;                 posn  -- next location
;;                 size -- tells the size of the astroid)
(define-struct astroid (posn pos-prev pos-next size))

;; a GameState is
;;   (make-game number  -- score
;;              number  -- number of life's left
;;              spaceship -- the spaceship
;;              [list-of astroid] -- the astroids in space
;;              [list-of projectile]) -- the projectiles shot from the space ship
(define-struct game (score life spaceship astroid-belt projectiles))


#| -----------   Image Constants -----------   |#

;; Smallest Astroid Radius
(define *ASTROID-RADIUS* 10)

;; The width of the world canvas
(define *WORLD-WIDTH* 900)

;; The length of the world canvas
(define *WORLD-HEIGHT* 700)

;; Canvas to render images on. 
(define *WORLD-CANVAS* (empty-scene *WORLD-WIDTH* *WORLD-HEIGHT* "Black"))

;; Spaceship Image
(define *SPACESHIP-IMG* (isosceles-triangle 26 22 "outline" "white")) 

;; Projectile Image
(define *PROJECTILE-IMG*  (line 0 20 "white"))

;; Todo: Check that we have overlay by size? Probably need redefinition of world
;;      So first place the large -> medium -> small astroids. 
;; Todo: Use scale function to scale a base astroid! (scale factor image)
;; Note: Acceleration only care about location of space ship and the angle of the ship/projectile determines
;; if an object has been hit.
;; Note: Spaceships and objects wrap around... projectiles do not. 



#| -----------   Functions for objects movement through space -----------   |#

;; acclerate-object: posn angle int -> posn
;; Moves and object `speed` pixel forward in the direction of the objects angle. 
(define (acclerate-object position angle speed) ...)

;; rotate-object: angle angle -> angle
;; Rotates the `orig-angle` by the `rot-angle`
(define (rotate-object orig-angle rot-angle) ... )
;Note: Use the mod function on 360

#| -----------   Functions for the PadEvent handler -----------   |#

;; acc-ship-backward: spaceship -> posn
;; Moves a spaceship in the exact opposite of spaceship-angle
(define (acclerate-object a-spaceship) ...)

;; shoot: spaceship -> projectile
;; Shoots a projectile from the head of the spaceship
(define (shoot a-spaceship) ...)
;Note: projectile will have same angle of spaceship until it exits the screen

;; pad-controller: GameState PadEvent -> GameState
;; Advances the world state each time a PadEvent is seem 
(define (pad-controller gs pad-event)
    (case (string->symbol k)
    [(up w) ...]
    [(down s) ...]
    [(left a) ...]
    [(right d) ...]
    [(| |) ...]))


#| -----------   Functions to call every tick of the clock -----------   |#

;; A deadORalive is a 
;; (make-deadORalive  [list-of astroid]
;;                    [list-of astroid]
;;                    [list-of projectile]
;;                    [list-of projectile])
(define-struct deadORalive (dead/astroids alive/astroids dead/projectiles alive/projectiles))

;; find-dead-or-alive : [list-of projectile] [list-of astroid] -> deadORalive
;; Returns the list of astroids and projectiles destroyed and alive. 
(define (find-dead-or-alive projectile-lst astroid-lst) ... )

;; get-score: int [list-of astroid] -> int
;; Returns the score by checking the properties of astroid hit
(define (get-score score  killed-astroids) ... )


;; get-life: int boolean -> int
;; Returns the life's left for the player by checking if ship is destroyed
(define (get-life life ship-destroyed?) ... )

;; get-ship: spaceship boolean -> spaceship
;; If spaceship is hit, reset spaceship at middle of screen otherwise move spaceship as usual
(defun (get-ship ship ship-destroyed?) ... )

;; get-astroid-belt: [list-of astroid] [list-of astroid] score-> [list-of astroid]
;; Returns the astroids that are left alive in the game.
;; Note: After an astroid is hit if the size is not 1 then the hit astroid is split into
;; two smaller pieces and then speed of smaller rocks increase as well.
;; How much the speed increases depends on the score, which encodes the hardness of the game. 
(define (get-astroid-belt alive-astroids astroids-destroyed score) ...)


;; tick-tock: GameState -> GameState
;; Advances the world state each tick of the clock
(define (tick-tock gs)
  (let* ([(ship (game-spaceship gs))]
         [(astroid-belt (game-astroid-belt gs))]
         [(projectiles (game-astroid-belt gs))]
         [(score (game-score gs))]
         [(dead-or-alive (find-dead-or-alive astroid-belt projectiles))]
         [(alive-astroids (deadORalive-alive/astroids dead-or-alive))]
         [(killed-astroids (deadORalive-dead/astroids dead-or-alive))]
         [(ship-destroyed? ship alive-astroids)])
  (make-game (get-score score killed-astroids)
             (get-life life ship-destroyed?)
             (get-ship ship ship-destroyed?) 
             (get-astroid-belt alive-astroids killed-astroids score)
             (deadORalive-alive/projectiles dead-or-alive))))


#| -----------   Functions to draw the Game to screen-----------   |#

;; display-score/life: int int -> image
;; Renders the score and life's onto the canvas and from score/life renders the level
(define (display-score/life score life canvas) ... ) 

;; display-astroids: [list-of astroid] -> image
;; Renders the astroids onto the canvas
(define (display-astroids astroid-belt canvas) ... ) 

;; display-projectiles: [list-of projectile] -> image
;; Renders the projectiles onto the canvas
(define (display-projectiles projectiles canvas) ... )

;; display-ship: spaceship -> image
;; Renders the spaceship onto the canvas
(define (display-ship spaceship canvas) ... )


;; render: GameState -> Image
;; Draws game to screen 
(define (render gs) (display-ship
                     (game-spaceship gs) (display-projectiles
                                          (game-projectiles gs)
                                          (display-astroids (game-astroid-belt gs)
                                                            (display-score/life (game-score gs)
                                                                                (game-lifegs)
                                                                                *WORLD-CANVAS*))))



#| -----------   Game Engine   -----------   |#
;; big-bang: GameState -> GameState
;; The game engine
(big-bang (make-game .... )
          [on-tick tick-tock ....]
          [on-pad pad-controller]
          [to-draw render])



