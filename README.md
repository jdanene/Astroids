# Final Project

For the final project, you must work alone. You will design a video game
in ISL+λ or C++. This must be a big-bang or ge211 game in the same style
as the falling game from assignment 4 (but not, obviously, the falling
game).

There are three deliverables, each with its own due date, and two
presentation events:

 - The proposal: due by email between Fri., Nov 30 and Sun., Dec. 2

 - The check-in: due by email on Tue., Dec. 4

 - The final code: due by email on Tue., Dec. 11

 - The final code walk: in person on Wed., Dec. 12

## Proposal

**The proposal must be written in the text of an email. No attachments,
please.**

In the proposal, you will describe the game that you intend to build. In
particular, you must list at least 8 *functional requirements* that your
game will satisfy. These are things that the game does, explained as
clearly and concisely as you can.

For example, for the faller game, you might write these requirements:

> 1. Objects fall from the top of the screen.
>
> 2. The user controls a continuously moving paddle at the bottom of the
>    screen by hitting a key to change its direction.
>
> 3. A score is maintained and displayed.
>
> 4. Whenever the user changes directions of the paddle, the score
>    decrements (but does not go negative).
>
> 5. Whenever an object strikes the paddle, it disappears and the score
>    increases by 10.
>
> 6. Objects that are directly above the paddle (en route to hit it) are
>    displayed differently than objects that aren't.
>
> 7. A special kind of object, displayed differently, causes the paddle
>    to increase in size when caught.
>
> 8. A special kind of object, displayed differently, causes the paddle
>    to decrease in size when caught.

You must have your proposal approved before you begin the next phase of
your design. We will try to get you feedback as quickly as possible, but
note that if you wait until Sun., Dec. 2 to turn it in, you will not
have much time to work on the next step. Consequently, we *strongly
suggest* you send us a first draft of your proposal as early as Fri.,
Nov. 30. Then if there are problems you will have a chance to revise it.

If you need inspiration, check out http://www.gamedesign.jp/. See also
[Chat Noir](https://docs.racket-lang.org/games/chat-noir.html) in the
PLT Games app that comes with Racket. This was a final project that one
of the instructors implemented because he didn’t want only the students
to have fun.

## Check-in

One week before the final project is due, we will ask you to submit
steps 1 and 2 of the design recipe for your game. In particular, we want
to see:

1. The data definition for your world and all its parts.

2. A wishlist of functions that you expect you will need to write, each
   with a signature and purpose. (We expect this to be at least 10
   functions, but if you think carefully, you may have many more. Some
   will be obvious helpers for others. Please don’t include trivial
   functions, however.)

The check-in is your chance to get feedback on the essentials of your
design before you actually write all your code. Because the course staff
are experienced designers, we are likely to have suggestions for you
that will improve your design. If you work hard before the check-in,
this could be very valuable to you and may save you more trouble later.

## Final code

This is the final code of your game. Not much to say here—follow the
Design Recipe!

## Final code walk

We will do a code walk of your game, like you are accustomed to.
