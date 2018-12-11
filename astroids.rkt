;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname astroidsv3) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)

#|

                                            ASTROIDS


Game Description:
    The player controls a spaceships movement and shoots rocks floating through space. The
    player starts with 3 life's, if a rock hits the spaceship the player loses a life. If a player shoots
    a rock, the the rocks break into twp smaller asteroids that move faster and are more difficult to hit.
    After achieving a certain score the level increases in hardness, by possibly adding rocks w/ faster speeds
    or lorenz movements movements through space. The smaller the rock the more points you get for shooting it down.

    Once the ship begins moving in a direction, it will continue in that direction for a
    time without player intervention unless the player applies
    thrust in a different direction. A ship never stops once you hit the space bar... unless the ship
    the ship is destroyed. In this case the ship is reset in the middle of the screen.


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

;; A object is one of
;; - projectile
;; - spaceship
;; - astroid

;; An angle is a number between 0 and 360
;; Interpretation: Usual interpretation of a geometric angle

;; An object-location is
;; (make-object-location angle int posn)
(define-struct object-location (angle speed posn))

;; A spaceship is
;;   (make-spaceship object-location) -angle speed and position of spaceship.
(define-struct spaceship (loc))

;; A projectile is
;;   (make-projectile object-location)  --  angle speed and position of projectile
(define-struct projectile (loc))
;; ToDo: Add functionality for different type of projectile? In case add enemy space ship. 

;; A radius is one of:
;; *SmallRadius* , *MediumRadius*, or *LargeRadius*
;; Interpretation: Indicates the size of the radius for a specific astroid.

;; A astroid is
;;   (make-astroid object-location -- angle speed and position of astroid
;;                 radius -- tells the size of the astroid)
(define-struct astroid (loc radius))

;;  keyStroke is
;; (make keyStrokes boolean boolean boolean boolean)
(define-struct keyStrokes (left? up? right? down?))
;; Interpretation: left? =1 if left key is down and left? =0 if left key is up. Same for up? right? down?

;; a GameState is
;;   (make-game number  -- score
;;              number  -- number of life's left
;;              spaceship -- the spaceship
;;              [list-of astroid] -- the astroids in space
;;              [list-of projectile] -- the projectiles shot from the space ship
;;              keyStrokes --  Tells if turn/acc keys are up or down
;;              ticks -- number of clock ticks since intialization)
(define-struct game (score life spaceship astroid-belt projectiles key))
#| -----------   Game and Image Constants -----------   |#
;; Size configuration for the radius of astroids
(define *SmallRadius*   16)
(define *MediumRadius*  32)
(define *LargeRadius*   64)

; Score settings for hitting small, medium or large astroid. 
(define *ScoreSmallRadius*   100)
(define *ScoreMediumRadius*  50)
(define *ScoreLargeRadius*   25)

; Speed settings for small, medium or large astroid. 
(define *SpeedSmallRadius*   5)
(define *SpeedMediumSize*  2.5)
(define *SpeedLargeRadius*   1)

;; Level: How many points to increase hardness
(define *LEVEL* 40000)

;; Projectile Speed
(define *Projectile-Speed* 2)

;; Projectile Length
(define *Projectile-Length* 10)

;; Spaceship Height
(define *Spaceship-Height* 26)

;; Spaceship Width
(define *Spaceship-Width* 24)

;; Spaceship Speed
(define *Spaceship-Speed* 1)

;; Spaceship turn sensitivity
(define *Spaceship-Sensitvity* 1)


;; Smallest Astroid Radius
(define *ASTROID-RADIUS* 10)

;; The width of the world canvas
(define *WORLD-WIDTH* 900)

;; The length of the world canvas
(define *WORLD-HEIGHT* 700)

;; Canvas to render images on. 
(define *WORLD-CANVAS* (empty-scene *WORLD-WIDTH* *WORLD-HEIGHT* "Black"))

;; Astroid Image
(define *SmallAstroid-IMG* (circle  *SmallRadius* "outline" "white"))
(define *MediumAstroid-IMG* (circle  *MediumRadius* "outline" "white"))
(define *LargeAstroid-IMG* (circle  *LargeRadius* "outline" "white"))

;; Spaceship Image
(define *SPACESHIP-IMG* (isosceles-triangle *Spaceship-Height* *Spaceship-Width* "outline" "white")) 

;; Projectile Image
(define *PROJECTILE-IMG*  (line 0 *Projectile-Length* "white"))

;; Todo: Check that we have overlay by size? Probably need redefinition of world
;;      So first place the large -> medium -> small astroids. 
;; Todo: Use scale function to scale a base astroid! (scale factor image)
;; Note: Acceleration only care about location of space ship and the angle of the ship/projectile determines
;; if an object has been hit.
;; Note: Spaceships and objects wrap around... projectiles do not. 




#| -----------   Functions to move objects through space  -----------   |#
#| test keyStroke, projectiles, astroids, ships |#
#| defining testing posn|#
(define origin (make-posn 0 0))
(define unit (make-posn 1 1))
#| defining testing object-location|#
(define angle45_origin_1 (make-object-location 45 1 origin))
(define angle45_unit_1 (make-object-location 45 1 unit))
(define angle45_unit_pi (make-object-location 45 pi unit))
(define angle60_origin_1 (make-object-location 60 1 origin))

(define ship\angle45_origin_1 (make-spaceship angle45_origin_1))
(define ship\angle45_unit_1 (make-spaceship angle45_unit_1))
(define ship\angle45_unit_pi (make-spaceship angle45_unit_pi))
(define ship\angle60_origin_1 (make-spaceship angle60_origin_1)) 

(define test-key1 (make-keyStrokes 1 0 1 0))
(define test-key2 (make-keyStrokes 0 1 0 1))
(define basic-projectiles (list (make-projectile angle45_origin_1)
                                (make-projectile angle45_unit_1)
                                (make-projectile angle45_unit_pi)
                                (make-projectile angle60_origin_1)))

(define basic-astroids (list (make-astroid angle45_origin_1 1)
                                (make-astroid angle45_unit_1 2)
                                (make-astroid angle45_unit_pi 3)
                                (make-astroid angle60_origin_1 3)))

;; to_radians: angle -> number
;; converts angle to radian
(define (to_radians angle) (* angle (/ pi 180)))
(check-within (to_radians 1) .0175 .01)
(check-within (to_radians 23) .4014 .01)


;;posn-wrapper: posn -> posn
;; wraps a `a-posn` around the screen.
 (define (posn-wrapper a-posn)
   (let* ((y (posn-y a-posn))
          (x (posn-x a-posn))
          (y.whole (floor y ))
          (x.whole (floor x))
          (x.diff (abs (- x.whole x)))
          (y.diff (abs (- y.whole y))))
     (cond [(and (< y 0) (< x 0))
            (make-posn (+ (modulo (abs (+ *WORLD-WIDTH* x.whole))  *WORLD-WIDTH*) x.diff)
                       (+ (modulo (abs (+ *WORLD-HEIGHT* y.whole))  *WORLD-HEIGHT*) y.diff))]
           [(and (>= y 0) (< x 0))
            (make-posn (+ (modulo (abs (+ *WORLD-WIDTH* x.whole))  *WORLD-WIDTH*) x.diff)
                       (+ (modulo y.whole  *WORLD-HEIGHT*) y.diff))]
           [(and (< y 0) (>= x 0))
            (make-posn (+ (modulo x.whole  *WORLD-WIDTH*) x.diff)
                       (+ (modulo (abs (+ *WORLD-HEIGHT* y.whole))  *WORLD-HEIGHT*) y.diff))]
           [else
            (make-posn (+ (modulo x.whole  *WORLD-WIDTH*) x.diff)
                       (+ (modulo y.whole  *WORLD-HEIGHT*) y.diff))])))

(check-expect (posn-wrapper (make-posn 900 700)) (make-posn 0 0))
(check-expect (posn-wrapper (make-posn 900 0)) (make-posn 0 0))
(check-expect (posn-wrapper (make-posn 0 700)) (make-posn 0 0))
(check-expect (posn-wrapper (make-posn 0 700.5)) (make-posn 0 0.5))
(check-expect (posn-wrapper (make-posn -1 700.5)) (make-posn 899 0.5))

 
;FIXME: Test. 

;; move-object: object-location -> object-location
;; moves obj-loc to next location using speed, location, and angle. 
(define (move-object obj-loc)
  (let* ([angle (object-location-angle obj-loc)]
        [radians (to_radians angle)]
        [position (object-location-posn obj-loc)]
        [speed (object-location-speed obj-loc)])
    (make-object-location angle speed
                          (make-posn (+ (* (cos radians) speed) (posn-x position))
                                     (+ (* (sin radians) speed) (posn-y position))))))



; check that 45degree turn for a object moving at unit speed at the origin => (√2/2, √2/2)
(check-within  (move-object angle45_origin_1) (make-object-location 45 1 (make-posn (/ (sqrt 2) 2)  (/ (sqrt 2) 2))) 0.01) 
; check that 45degree turn for a object moving at unit speed at  (1,1) => (√2/2 +1, √2/2 +1)
(check-within  (move-object angle45_unit_1) (make-object-location 45 1 (make-posn (+ (/ (sqrt 2) 2) 1) (+ (/ (sqrt 2) 2) 1))) 0.01)
; check that 45degree turn for a object moving at pi speed at  (1,1) => (pi*√2/2 +1, pi*√2/2 +1)
(check-within (move-object angle45_unit_pi) (make-object-location 45 pi (make-posn (+ (* (/ (sqrt 2) 2) pi) 1)  (+ (* (/ (sqrt 2) 2) pi) 1))) 0.01)
; check that 60degree turn for a object moving at unit speed at the origin => (1/2, √3/2)
(check-within (move-object angle60_origin_1) (make-object-location 60 1 (make-posn (/ 1 2)  (/ (sqrt 3) 2))) 0.01)

;; rotate-object: angle angle -> angle
;; rotates the `orig-angle` by the `rot-angle`
(define (rotate-object orig-angle rot-angle)
  (modulo (+ orig-angle  rot-angle) 360))

(check-expect (rotate-object 30 30) 60) 
(check-expect (rotate-object 0 1) 1)
(check-expect (rotate-object 10 359) 9)

;; add-to-posn: number posn ->posn
;; adds a `const` to each coordinate in `pos`
(define (add-to-posn const pos) (make-posn (+ (posn-x pos) const) (+ (posn-y pos) const)))


(check-expect (add-to-posn 5 origin) (make-posn 5 5))
(check-within (add-to-posn pi unit) (make-posn (+ 1 pi) (+ 1 pi)) 0.01)
#| ---------------------------   Linear Algebra -------------------------------   |#
;; dot-product: posn posn -> number
;; calculates the dot product between two posns. 
(define (dot-product vec0 vec1)
  (+ (* (posn-x vec0) (posn-x vec1)) (* (posn-y vec0) (posn-y vec1))))

(check-expect (dot-product (make-posn 5 5) (make-posn 4 4)) 40)

;; euclids-distance: posn posn-> number
;; Calulates the eudclidean distance between twos posn's
(define (euclids-distance vec0 vec1)
  (sqrt (dot-product vec0 vec1)))

(check-within (euclids-distance (make-posn 5 5) (make-posn 4 4)) 6.3245 .01)
;; vec-subtract: posn posn -> posn
;; posn subtraction `p1` - `p3`  
(define (vec-subtract p1 p3)
  (make-posn (- (posn-x p1) (posn-x p3)) (- (posn-y p1) (posn-y p3))))

(check-expect (vec-subtract (make-posn 5 5) (make-posn 4 4)) (make-posn 1 1))

;; A line paramaterized by two points `p1` and `p2` is
;; L={θ ∈ R: p1 + θ(p2-p1)}

;; get-parametric: posn posn number -> posn
;; instantiates a posn on the parametized line defined by `p1` `p2`, by using the input coefficient `theta`. 
(define (get-parametric p1 p2 theta)
  (make-posn (+ (posn-x p1) (* (- (posn-x p2) (posn-x p1)) theta))
                                (+ (posn-y p1) (* (- (posn-y p2) (posn-y p1)) theta))))

(check-expect (get-parametric (make-posn 4 4) (make-posn 5 5) 5) (make-posn 9 9))

;; A projection is a
;; (make-projection number posn)
(define-struct projection (theta posn))
  
;; get-projection: posn posn posn -> projection
;; To find closest point to  `p3`  on the line paramaterized by `p1` and `p2  by solving for  θ in the 
;; equation <p3 - p2 + θ(p1-p2), p2 - p1> = 0. The solution is to this equation is
;;  θ^* = [<p1,p2> + <p3,p1> -(<p1,p1> + <p3,p2>)]/[- <p2,p2> - <p1,p1> + 2<p1,p2>], and this function returns
;; the projection vector, p2+θ^*(p1-p2).
(define (get-projection p1 p2 p3)
  (let* ((denominator (- (* 2 (dot-product p1 p2)) (+ (dot-product p2 p2) (dot-product p1 p1))))
         (numerator (- (+ (dot-product p1 p2) (dot-product p3 p1)) (+ (dot-product p1 p1) (dot-product p3 p2))))
         (theta (/ numerator denominator))
         (vec (get-parametric p1 p2 theta)))
(make-projection theta vec)))

(check-expect (get-projection (make-posn 1 1) (make-posn 4 1) (make-posn 3 3)) (make-projection 2/3 (make-posn 3 1)))
(check-within (get-projection (make-posn 1 1) (make-posn 4 2) (make-posn 3 3)) (make-projection 0.8 (make-posn 3.4 1.8)) .01)
(check-expect (get-projection (make-posn 1 1) (make-posn 4 1) (make-posn 5 3))   (make-projection 4/3 (make-posn 5 1)))

;; bounds-check?: posn posn posn -> bool
;; checks if a `point' on the line paramaterized by `object.begin` and `object.end` is between `object.begin` and `object.end`
(define (bounds-check? point object.begin object.end)
  (let* ((point.dist.tozero (sqrt (dot-product point point)))
         (object.begin.dist.tozero (sqrt (dot-product object.begin object.begin)))
         (object.end.dist.tozero (sqrt (dot-product object.end object.end)))
         (object.max.dist.tozero (max object.end.dist.tozero object.begin.dist.tozero))
         (object.min.dist.tozero (min object.end.dist.tozero object.begin.dist.tozero)))
    (and (>= point.dist.tozero object.min.dist.tozero)
         (<= point.dist.tozero object.max.dist.tozero)))) 

;; (2,2) is on the path and within the intervals
(check-expect (bounds-check? (make-posn 3 3) (make-posn 2 2) (make-posn 4 4)) #t)
;; (5,5) is on the path and greater than internval 
(check-expect (bounds-check? (make-posn 5 5) (make-posn 2 2) (make-posn 4 4)) #f)
;; (1,1) is on the path and less than internval 
(check-expect (bounds-check? (make-posn 1 1) (make-posn 2 2) (make-posn 4 4)) #f)
;; switch the order of min & max and redo experiments
(check-expect (bounds-check? (make-posn 3 3) (make-posn 4 4) (make-posn 2 2)) #t)
(check-expect (bounds-check? (make-posn 5 5) (make-posn 4 4) (make-posn 2 2)) #f)
(check-expect (bounds-check? (make-posn 1 1) (make-posn 4 4) (make-posn 2 2)) #f)

;; ray-intersect-sphere?: posn posn posn -> bool
;; Checks if a ray with endpoints `p1` `p2`  intersects a sphere with center `p3` and radius `radius`
(define (ray-intersect-sphere? p1 p2 p3 radius)
  (let* ((projection (get-projection p1 p2 p3))
         (projection.posn (projection-posn projection))
         (projection.theta (projection-theta projection))
         (projection.diff (vec-subtract p3 projection.posn))
         (projection.len (euclids-distance (vec-subtract projection.posn p1) (vec-subtract projection.posn p1)))
         (projection.diff.len (euclids-distance projection.diff projection.diff))
         (dist.projection=>intersect (sqrt (- (sqr radius) (sqr projection.diff.len)))));using pythagorean theorem 
    (cond [(and (bounds-check? projection.posn p1 p2) (<= projection.diff.len radius)) #t]
          [else (let* ((point-of-intersect-slope1 (* projection.theta (- 1 (/ dist.projection=>intersect projection.len))))
                 (point-of-intersect-slope2 (* projection.theta (/ (+ dist.projection=>intersect projection.len) projection.len)))
                 (point-of-intersect1 (get-parametric p1 p2 point-of-intersect-slope1))
                 (point-of-intersect2 (get-parametric p1 p2 point-of-intersect-slope2)))      
           (cond [(and (<= projection.diff.len radius) (bounds-check? point-of-intersect1 p1 p2)) #t]
                 [(and (<= projection.diff.len radius) (bounds-check? point-of-intersect2 p1 p2)) #t]
                 [else  #f]))])))




;ball right on top of line radius large enough for intersect
(check-expect (ray-intersect-sphere? (make-posn 1 1) (make-posn 4 1) (make-posn 3 3) 3) #t)
(check-expect (ray-intersect-sphere? (make-posn 1 1) (make-posn 4 1) (make-posn 3 3) 2) #t)
;ball right on top of line radius too small for intersect
(check-expect (ray-intersect-sphere? (make-posn 1 1) (make-posn 4 1) (make-posn 3 3) 1) #f)
; projection point off of line but radius just large enough for intersect
(check-expect (ray-intersect-sphere? (make-posn 1 1) (make-posn 4 1) (make-posn 5 1) 1) #t)
; projection point off of line and radius too small for intersect
(check-expect (ray-intersect-sphere? (make-posn 1 1) (make-posn 4 1) (make-posn 5 1) .9) #f)
; ball off of line but radius large enough for intersect. 
(check-expect (ray-intersect-sphere? (make-posn 1 1) (make-posn 4 1) (make-posn 5 2) 2) #t)
; ball off of line and radius too small  for intersect. 
(check-expect (ray-intersect-sphere? (make-posn 1 1) (make-posn 4 1) (make-posn 5 2) 1) #f)

#| ---------------------------   Functions for the PadEvent handler -------------------------------   |#

;; shoot: spaceship int-> projectile
;; Shoots a projectile from the head of the spaceship
(define (shoot a-spaceship speed)
  (let ((spaceship-location (spaceship-loc a-spaceship)))
    (make-projectile (move-object (make-object-location (object-location-angle spaceship-location)
                                                        speed
                                                        (add-to-posn (/ *Spaceship-Height* 2) (object-location-posn spaceship-location)))))))


;TODO: write Tests

;; update-keyStroke: keyStroke symbol -> keyStroke
;; Updates keyStroke so we know if things are pressed down or not
(define (update-keyStrokes key-stroke k)
  (cond [(or (equal? k 'up) (equal? 'w k)) (make-keyStrokes (keyStrokes-left? key-stroke) 1 (keyStrokes-right? key-stroke) 0)]
        [(or (equal? k 'down) (equal? 's k)) (make-keyStrokes (keyStrokes-left? key-stroke) 0 (keyStrokes-right? key-stroke) 1)]
        [(or (equal? k 'left) (equal? 'a k)) (make-keyStrokes 1 (keyStrokes-up? key-stroke) 0 (keyStrokes-down? key-stroke))]
        [(or (equal? k 'right) (equal? 'd k)) (make-keyStrokes 0 (keyStrokes-up? key-stroke) 1 (keyStrokes-down? key-stroke))]
        [else key-stroke]))

;; ToDo: Repeated operations maybe switch to local 
(check-expect (update-keyStrokes test-key1 'up) (make-keyStrokes 1 1 1 0)) 
(check-expect (update-keyStrokes test-key1 'w) (make-keyStrokes 1 1 1 0))
(check-expect (update-keyStrokes test-key1 'down) (make-keyStrokes 1 0 1 1))
(check-expect (update-keyStrokes test-key1 's) (make-keyStrokes 1 0 1 1))
(check-expect (update-keyStrokes  test-key2 'left) (make-keyStrokes 1 1 0 1))  
(check-expect (update-keyStrokes test-key2 'a) (make-keyStrokes 1 1 0 1))
(check-expect (update-keyStrokes test-key2 'right) (make-keyStrokes 0 1 1 1))
(check-expect (update-keyStrokes test-key2 'd) (make-keyStrokes 0 1 1 1))

;; pad-controller: GameState Pad-Event -> GameState
;; Advances the world state each time a PadEvent is seen 
(define (pad-controller gs pad-event)
  (let ((sym-key (string->symbol pad-event))
        (projectiles (game-projectiles gs))
        (space-ship (game-spaceship gs)))
  (make-game (game-score gs)
             (game-life gs)
              space-ship
             (game-astroid-belt gs)
             (if (equal? sym-key '| |) (cons (shoot space-ship *Projectile-Speed*) projectiles) projectiles)
             (update-keyStrokes (game-key gs) sym-key))))


(pad-controller (make-game 5 2 ship\angle45_origin_1 basic-astroids basic-projectiles test-key1) " ")
                    
#| -----------   Functions to call every tick of the clock -----------   |#
;; collide? astroid [spaceship or projectile] -> boolean
;; Tells if `object` has collided with `a-astroid`
(define (collide? a-astroid object)
  (let* ((object.moving (if (projectile? object) (projectile-loc object) (spaceship-loc object)))       
         (astroid.radius (astroid-radius a-astroid))
         (astroid.posn (object-location-posn (astroid-loc a-astroid)))                    
         (object.moving.posn (object-location-posn object.moving))      
         (object.moving.next.posn (object-location-posn (move-object object.moving))))
    (ray-intersect-sphere? object.moving.posn object.moving.next.posn astroid.posn astroid.radius)))          

; projectile & astroid objects at the same location
(check-expect (collide? (make-astroid angle45_unit_pi 4) (make-projectile (make-object-location 60 2 (make-posn 1 1)))) #t)
; projectile is very far away from astroid. 
(check-expect (collide? (make-astroid angle45_unit_pi 3) (make-projectile (make-object-location 45 pi (make-posn 900 900)))) #f)
;projectile is close to astroid but not at same exact point
(check-expect (collide? (make-astroid angle45_unit_pi 4) (make-projectile (make-object-location 45 pi (make-posn 1.2 1)))) #t)

;projectile is kind of  close to astroid is moving fast so it absolutely demolishes it. going right through the middle
(check-expect (collide? (make-astroid angle45_unit_pi 4) (make-projectile (make-object-location 45 90 (make-posn 0 0)))) #t)
;projectile is kind of  close to astroid is moving fast and hits w/ a glancing blow
(check-expect (collide? (make-astroid angle45_unit_pi 4) (make-projectile (make-object-location 60 90 (make-posn 0 0)))) #t)

;; next-posn: object -> posn
;; Get the next positive position on the path of the `obj-loc`
 
;; object-collision?: [list-of astroid] object -> (astroid or #f)
;; Check `astroid-belt` see if object has hit at-least one astroid returns the first astroid hit
(define (object-collision?  astroid-belt obj)
  (cond [(empty? astroid-belt) #f]
        [else (let ([a-astroid (car astroid-belt)]
                    [astroid-belt (cdr astroid-belt)])
                (if (collide? a-astroid obj)
                    a-astroid
                    (object-collision? astroid-belt obj)))]))
                         
(define test-astroids1 (list (make-astroid (make-object-location 45 pi (make-posn 40 1)) 1)
                            (make-astroid (make-object-location 45 pi (make-posn 40 40)) 1)
                            (make-astroid (make-object-location 45 pi (make-posn 900 99)) 1)
                            (make-astroid (make-object-location 45 3 (make-posn 1 1)) 4)))

(define test-projectile1 (make-projectile (make-object-location 45 3 (make-posn 6/5 1))))
(define test-spaceship1 (make-spaceship (make-object-location 45 3 (make-posn 6/5 1))))
(define test-projectile2 (make-projectile (make-object-location 45 3 (make-posn 900 1))))
(check-expect (object-collision? test-astroids1 test-projectile1) (make-astroid (make-object-location 45 3 (make-posn 1 1)) 4))
(check-expect (object-collision? test-astroids1 test-projectile2)  #f)
(check-expect (object-collision? test-astroids1 test-spaceship1) (make-astroid (make-object-location 45 3 (make-posn 1 1)) 4))
;; A deadORalive is a 
;; (make-deadORalive [list-of astroid]
;;                   [list-of projectile]
;;                   [list-of astroid]
;;                   [list-of projectile])
(define-struct deadORalive (alive/astroids alive/projectiles kill/astroids kill/projectiles))

;; merge-deadORalive: deadORalive deadORalive -> deadORalive
;; merges `deadORalive1` and `deadORalive2` into one. 
(define (merge-deadORalive deadORalive1 deadORalive2)
  (make-deadORalive  (append (deadORalive-alive/astroids deadORalive1) (deadORalive-alive/astroids deadORalive2))
                     (append (deadORalive-alive/projectiles deadORalive1) (deadORalive-alive/projectiles deadORalive2))
                     (append (deadORalive-kill/astroids deadORalive1) (deadORalive-kill/astroids deadORalive2))
                     (append (deadORalive-kill/projectiles deadORalive1) (deadORalive-kill/projectiles deadORalive2))))

(check-expect (merge-deadORalive (make-deadORalive test-astroids1 (list test-projectile1) test-astroids1 (list test-projectile1))
                                 (make-deadORalive test-astroids1 (list test-projectile1) test-astroids1 (list test-projectile1)))
              (make-deadORalive (append test-astroids1 test-astroids1) (list test-projectile1 test-projectile1)
                                (append test-astroids1 test-astroids1) (list test-projectile1 test-projectile1)))

;; get-deadORalive: [list-of projectile] [list-of astroid] -> deadORalive
;; iterates through `astroid-belt` and `projectiles` finds dead or alive astroids and projectites
(define (get-deadORalive projectiles astroid-belt)
  (cond [(and (empty? projectiles) (empty? astroid-belt))
         (make-deadORalive '() '() '() '())]
        [(and (empty? projectiles) (not (empty? astroid-belt)))
         (make-deadORalive astroid-belt '() '() '())]
        [(and (not (empty? projectiles))  (empty? astroid-belt))
         (make-deadORalive '() projectiles '() '())]
        [else (let* ([a-projectile (car projectiles)]
                     [tail-projectiles (cdr projectiles)]
                     [astroid-hit (object-collision? astroid-belt a-projectile)])
                (cond [(boolean? astroid-hit) ;not hit
                       (merge-deadORalive (make-deadORalive '() (list a-projectile)'()'())
                                          (get-deadORalive tail-projectiles astroid-belt))]
                      [else (merge-deadORalive (make-deadORalive '() '() (list astroid-hit) (list a-projectile))
                                          (get-deadORalive tail-projectiles
                                                           (remove astroid-hit astroid-belt)))]))]))

;; TODO: write tests
 (get-deadORalive (list test-projectile1) test-astroids1)

;; Testing! deadORalive object. 
(define test.deadORalive  (make-deadORalive test-astroids1 basic-projectiles (list test-projectile1 test-projectile2) basic-astroids))

;; get-score: int [list-of astroid] -> int
;; Returns the score by checking the properties of astroid hit
(define (get-score score  killed-astroids)
  (let ((get.score (lambda (a-astroid) (let ((astroid.size (astroid-radius a-astroid)))
                                         (cond [(equal? astroid.size *SmallRadius*) *ScoreSmallRadius*]
                                               [(equal? astroid.size *MediumRadius*) *ScoreMediumRadius*]
                                               [else *ScoreLargeRadius*])))))
    (foldr + score (map get.score killed-astroids))))

;Testing!
(define astroid-lst (list (make-astroid (make-object-location 45 3 (make-posn 1 1)) *SmallRadius*)
                          (make-astroid (make-object-location 45 3 (make-posn 1 1)) *SmallRadius*)
                          (make-astroid (make-object-location 45 3 (make-posn 1 1)) *MediumRadius*)
                          (make-astroid (make-object-location 45 3 (make-posn 1 1)) *LargeRadius*)))
(check-expect (get-score 5 astroid-lst) (+ *ScoreSmallRadius* *ScoreSmallRadius* *ScoreMediumRadius* *ScoreLargeRadius* 5))

;; get-life: int (astroid or #f) -> int
;; Returns the life's left for the player by checking if ship is destroyed
(define (get-life life ship-destroyed?) (if (boolean? ship-destroyed?) life (sub1 life)))

(check-expect (get-life 3 (make-astroid angle45_origin_1 1)) 2)
(check-expect (get-life 3 #f) 3)

;; keyStrokes=>object-location: shaceship keyStrokes  -> object-location
;; 2^4 ways keystrokes can be tapped. Adjust a ships location for each scenario
(define (keyStrokes=>object-location ship key)
  (let* ([ship.loc (spaceship-loc ship)]
        [speed (object-location-speed ship.loc)]
        [angle (object-location-angle ship.loc)]
        [position (object-location-posn ship.loc)]
        [left (keyStrokes-left? key)]
        [right (keyStrokes-right? key)]
        [up (keyStrokes-up? key)]
        [down (keyStrokes-down? key)])
      (cond [(= left right up down 1) ship.loc] ;; dont move
            [(and (= left right 1) (= up down 0))
             ship.loc] ;;dont move
            [(and (= left right 0) (= up down 1))
             ship.loc] ;;dont move
            [(and (= left up 1)  (= right down 0))
             (move-object (make-object-location (rotate-object angle -1) speed position))] ;;go foward w/ left tilt
            [(and (= left up 0) (= right down 1))
             (move-object (make-object-location (rotate-object angle 181) speed position))]
            [(and (= left down 1) (= right up 0))
             (move-object (make-object-location (rotate-object angle 179) speed position))]
            [(and (= left down 0)  (= right up 1))
             (move-object (make-object-location (rotate-object angle 1) speed position))]
            [(and (= left 1) (= right up down 0))
             (make-object-location (rotate-object angle -1) speed position)]
            [(and (= left 0) (= right up down 1))
             (make-object-location (rotate-object angle 1) speed position)]
            [(and (= right 1) (= left up down 0))
             (make-object-location  (rotate-object angle 1) speed position)]
            [(and (= right 0) (= left up down 1))
             (make-object-location  (rotate-object angle -1) speed position)]
            [(and (= up 1) (= left right down 0))
             (move-object ship.loc) ]
            [(and (= up 0) (= left right down 1))
             (move-object (make-object-location  (rotate-object angle 180) speed position))]
            [(and (= down 1) (= left right up 0))
             (move-object (make-object-location  (rotate-object angle 180) speed position))]
            [(and (= down 0) (= left right up 1))
             (move-object ship.loc)]
            [else ship.loc]))) ;;dont move

;TODO: TEST
;(keyStrokes=>object-location ship\angle45_origin_1 (make-keyStrokes 1 1 1 1))
;(keyStrokes=>object-location ship\angle45_origin_1 (make-keyStrokes 0 1 1 1))
;(keyStrokes=>object-location ship\angle45_origin_1 (make-keyStrokes 0 0 0 1))
;(left? up? right? down?)

;; get-ship: spaceship (astroid or #f) keyStrokes -> spaceship
;; If spaceship is hit, reset spaceship at middle of screen otherwise move spaceship as usual
(define (get-ship ship ship-destroyed? key)
  (cond [(boolean? ship-destroyed?) (let* ([ship.loc.next (keyStrokes=>object-location ship key)]
                                           [ship.loc.posn  (object-location-posn ship.loc.next)])
                                      (make-spaceship (make-object-location (object-location-angle ship.loc.next)
                                                                            (object-location-speed ship.loc.next)
                                                                            (posn-wrapper ship.loc.posn))))]
        [else (make-spaceship (make-object-location 90 (object-location-speed (spaceship-loc ship))
                                                    (make-posn (/ *WORLD-WIDTH* 2)
                                                               (/ *WORLD-HEIGHT* 2))))]))
;; TODO: TEST

;; get-key: keyStrokes (astroid or #f) ->keyStrokes
;; resets the keys if killed
(define (get-key key ship-destroyed?)
  (if (boolean? ship-destroyed?)
      key
      (make-keyStrokes 0 0 0 0)))

(check-expect (get-key (make-keyStrokes 0 0 0 1) #f) (make-keyStrokes 0 0 0 1)) 
(check-expect (get-key (make-keyStrokes 0 0 0 1) (make-astroid angle45_origin_1 1)) (make-keyStrokes 0 0 0 0))

;; propogate: astroid int -> [list-of astroid]
;; If the dead astroid is not size *SmallRadius*, then it is split into two astroids
;; one size less than current traveling at 45degree angles from parent. Speed goes
;; up by speed*(curr-lvl+1)
(define (propogate  a-astroid curr-lvl)
  (let* ([radius (astroid-radius a-astroid)]
         [loc (astroid-loc a-astroid)]
         [posn (object-location-posn loc)]
         [speed (object-location-speed loc)]
         [angle (object-location-angle loc)])
    (cond [(= radius *SmallRadius*) '()]
          [(= radius *MediumRadius*)
           (list (make-astroid
                  (make-object-location (rotate-object angle 45)
                                        (* *SpeedSmallRadius* curr-lvl) posn)
                  *SmallRadius*)
                 (make-astroid
                  (make-object-location (rotate-object angle -45)
                                        (* *SpeedSmallRadius* curr-lvl) posn)
                  *SmallRadius*))]
          [else (list (make-astroid
                       (make-object-location (rotate-object angle 45)
                                             (* *SpeedMediumSize* curr-lvl) posn)
                       *MediumRadius*)
                      (make-astroid
                       (make-object-location (rotate-object angle -45)
                                             (* *SpeedMediumSize* curr-lvl) posn)
                       *MediumRadius*))])))


(check-expect (propogate (make-astroid (make-object-location 30 *SpeedMediumSize* (make-posn 20 22)) *MediumRadius*) 1)
              (list (make-astroid (make-object-location 75 5 (make-posn 20 22)) 4) (make-astroid (make-object-location 345 5 (make-posn 20 22)) 4)))

(check-expect (propogate (make-astroid (make-object-location 30 *SpeedLargeRadius* (make-posn 20 22)) *ScoreLargeRadius*) 2)
              (list (make-astroid (make-object-location 75 5 (make-posn 20 22)) *MediumRadius*) (make-astroid (make-object-location 345 5 (make-posn 20 22)) *MediumRadius*)))

(check-expect (propogate (make-astroid (make-object-location 30 *SpeedSmallRadius* (make-posn 20 22)) *SmallRadius*) 1) '())

;;propogate-the-dead: [list-of astroid] int -> [list-of astroid]
;; splits and deletes the astroids that should be. 
(define (propogate-the-dead astroid-belt curr-lvl)
  (cond [(empty? astroid-belt) '()]
        [else (append (propogate (car astroid-belt) curr-lvl) (propogate-the-dead (cdr astroid-belt) curr-lvl))]))
  
  (define astroid-lst2 (list (make-astroid (make-object-location 60 *SpeedSmallRadius* (make-posn 4 4)) *SmallRadius*)
                          (make-astroid (make-object-location 45 *SpeedSmallRadius* (make-posn 10 1)) *SmallRadius*)
                          (make-astroid (make-object-location 30 *SpeedMediumSize* (make-posn 20 22)) *MediumRadius*)
                          (make-astroid (make-object-location 45 *SpeedLargeRadius*  (make-posn 1  70)) *LargeRadius*)))
  
  (check-expect (propogate-the-dead astroid-lst2 1) (list (make-astroid (make-object-location 75 5 (make-posn 20 22))  4)
                                                          (make-astroid (make-object-location 345 5 (make-posn 20 22)) 4)
                                                          (make-astroid (make-object-location 90 2.5 (make-posn 1 70)) 8)
                                                          (make-astroid (make-object-location 0 2.5 (make-posn 1 70)) 8)))

;; get-astroids: [list-of astroid] [list-of astroid] int -> [list-of astroid]
;; Advances astroid to new state
(define (get-astroids alive-rocks dead-rocks curr-lvl)
  (let ([fn (lambda (a-astroid) (let ((next.loc (move-object (astroid-loc a-astroid))))
                                  (make-astroid (make-object-location (object-location-angle next.loc)
                                                                      (object-location-speed next.loc)
                                                                      (posn-wrapper (object-location-posn next.loc)))
                                                (astroid-radius a-astroid))))])
   (append (map fn alive-rocks) (propogate-the-dead dead-rocks curr-lvl))))

;; get-projectile: [list-of projectile] -> [list-of projectile]
;; advances projectile to new state
(define (get-projectiles projectiles)
  (let ([fn (lambda (a-projectile) (let* ([next.loc (move-object (projectile-loc a-projectile))]
                                          [next.posn (object-location-posn next.loc)]
                                          [x (posn-x next.posn)] [y (posn-y next.posn)])
                                     (if (and (<= x *WORLD-WIDTH*) (>= x 0) (<= y *WORLD-HEIGHT*) (>= y 0))
                                              (list (make-projectile (make-object-location (object-location-angle next.loc)
                                                                                           (object-location-speed next.loc)
                                                                                           (object-location-posn next.loc))))
                                              '())))])
    (apply append (map fn projectiles))))

;TODO: MORE TEST
(check-expect (get-projectiles (list (make-projectile (make-object-location 1 1 (make-posn -1 -1))))) '())


  
;; tick-tock: GameState -> GameState
;; Advances the world state each tick of the clock
(define (tick-tock gs)
  (let* ([ship (game-spaceship gs)]
         [astroid-belt (game-astroid-belt gs)]
         [projectiles (game-projectiles gs)]
         [score (game-score gs)]
         [key (game-key gs)]
         [curr-lvl (add1 (quotient score *LEVEL*))]
         [dead-or-alive (get-deadORalive projectiles astroid-belt)]
         [alive-astroids (deadORalive-alive/astroids dead-or-alive)]
         [killed-astroids (deadORalive-kill/astroids dead-or-alive)]
         [alive-projectiles (deadORalive-alive/projectiles dead-or-alive)]
         [ship-destroyed? (object-collision? alive-astroids ship)])
  (make-game (get-score score killed-astroids) ; 
             (get-life (game-life gs) ship-destroyed?)
             (get-ship ship ship-destroyed? key) 
             (get-astroids alive-astroids killed-astroids curr-lvl)
             (get-projectiles alive-projectiles )
              key)))


#| -----------   Functions to draw the Game to screen-----------   |#

;; monospaced-text: string int-> image
;; Outputs text as an image
;; strategy: Instructor defined function
(define (monospaced-text str size)
  (text/font str
             size
             "yellow"
             "Menlo" 'modern
             'normal 'normal #f))
 
;; display-text: number number image ->image
;; Renders the score and life's onto the canvas and from score/life renders the level
(define (display-text score life canvas)
  (place-image
   (monospaced-text (string-append  "     Life: " (number->string life)
                                    "     Level: " (number->string (add1 (quotient score *LEVEL*)))
                                    "     Score: "(number->string score))
                    14)
   (* (/ 150 900) *WORLD-WIDTH*) (* (/ 20 700) *WORLD-HEIGHT*) canvas)) ;Default is to fit a 900 x 700  screen

;; astroid=>image: astroid angle-> image
;; outputs appropriate image for an astroid.
(define (astroid=>image a-astroid obj-angle)
  (let ([radius (astroid-radius a-astroid)])
    (cond [(= radius *SmallRadius*) (rotate obj-angle *SmallAstroid-IMG*)]
          [(= radius *MediumRadius*) (rotate obj-angle *MediumAstroid-IMG*)]
          [else (rotate obj-angle *LargeAstroid-IMG*)])))
;
;(astroid=>image (make-astroid (make-object-location 75 5 (make-posn 20 22)) *MediumRadius*))

;; object=>image: object image-> image
;; Renders the astroids onto the canvas
(define (object=>image object image)
  (let* ([obj-loc (cond [(projectile? object) (projectile-loc object)]
                        [(astroid? object) (astroid-loc object)]
                        [else (spaceship-loc object)])]
         [obj-posn (object-location-posn obj-loc)]
         [obj-angle (object-location-angle obj-loc)])
    (place-image (cond [(projectile? object) (rotate obj-angle *PROJECTILE-IMG*)]
                       [(spaceship? object) (rotate obj-angle *SPACESHIP-IMG*)]
                       [else (astroid=>image object obj-angle)])
                 (posn-x obj-posn) (posn-y obj-posn) image)))  

(define test-astroids (list (make-astroid (make-object-location 75 5 (make-posn 20 22)) *MediumRadius*)
                           (make-astroid (make-object-location 345 5 (make-posn 100 200)) *MediumRadius*)
                           (make-astroid (make-object-location 345 5 (make-posn 500 90)) *LargeRadius*)
                           (make-astroid (make-object-location 345 5 (make-posn 600 90)) *SmallRadius*)))
(define test-projectiles   (list (make-projectile (make-object-location 75 5 (make-posn 300 300)))
                                (make-projectile (make-object-location 75 5 (make-posn 450 600)))))
(define garbage-ship   (list (make-spaceship (make-object-location 90 1
                                                             (make-posn (/ *WORLD-WIDTH* 2)
                                                                        (/ *WORLD-HEIGHT* 2))))))

;; render: GameState -> Image
;; draws game to screen 
(define (render gs)
  (foldr object=>image (display-text (game-score gs) (game-life gs) *WORLD-CANVAS*)
         (append (game-astroid-belt gs) (game-projectiles gs) (list (game-spaceship gs)))))

#| -----------   Functions end the game-----------   |#

;;last-world?: GameState -> boolean
;; returns true if total life <=  0.
(define (last-world? gs) (<= (game-life gs) 0))
  
;;last-picture: GameState -> image
;; returns the last picture you will see when you die
(define (last-picture gs)
  (display-text (game-score gs) (game-life gs) (foldr object=>image (place-image (monospaced-text "Game Over" 100) (/ *WORLD-WIDTH* 2) (/ *WORLD-HEIGHT* 2) *WORLD-CANVAS*)
                                                      (append (game-astroid-belt gs) (game-projectiles gs) (list (game-spaceship gs))))))

  
#| -----------   Game Engine   -----------   |#

(define G0 (make-game 0 3 (make-spaceship (make-object-location 90 1
                                       (make-posn (/ *WORLD-WIDTH* 2)
                                                  (/ *WORLD-HEIGHT* 2)))) test-astroids test-projectiles (make-keyStrokes 0 0 0 0)))

;; big-bang: GameState -> GameState
;; The game engine
(big-bang G0
  [on-tick tick-tock]
  [on-pad pad-controller]
  [to-draw render]
  [stop-when last-world? last-picture])


#|
(<= 0 (game-life G0))

(last-world? G0)
(define-struct game (score life spaceship astroid-belt projectiles key))
 |#