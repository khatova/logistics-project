#include "../asprilo-encodings/input.lp".

% we need to transform between input times, progression steps with their substeps, and output times.
progrstep(1..horizon).
substep(1..horizon). % what max amount of substeps will be there?
time_step(1,1,1,robot(R)).
time_step(progrstep(PS), substep(SS), time_(T), robot(R)) :- position(R,C,T), not repositioning_done().%TODO.
time_step(progrstep(PS), substep(SS)) :- time_step(PS,SS,_,_).

% robots are solved one by one (at least for now, later we maybe can use independency detection here)
% master unit = robot with the highest priority, which is not solved yet.
% priority of a robot equals to its ordering number (maybe we can use a better heuristic later).
priority(R,R) :- robot(R).
master(robot(R), PS) :- not solved(R, PS), priority(R,P), progrstep(PS),
				#max{P' : priority(R',P'), not solved(R, PS)}, P' < P.

%private zone = all cels visited by a robot at one progression step.
% maybe wrong! only visited before current substep?
private_zone(robot(R), progrstep(PS), node(C)) :- new_position(R,C,PS,_). 

% A. wait if the robot was pushed from its initial path
% - wait if current position not on initial path
pushed(robot(R), progrstep(PS), substep(SS)) :- not position(R,C,_).
wait(robot(R), progrstep(PS), substep(SS)) :- pushed(R,PS,SS).

% - wait if next step already visited in current progression step
pushed(robot(R), progrstep(PS), substep(SS)) :- position(R,C,T), position(R,C',T+1), new_position(R,C',PS',_), 
				progrstep(PS'), PS' < PS.

% B. wait if next step belongs to the private zone of a robot with higher priority
wait(robot(R), progrstep(PS), substep(SS)) :- position(R,C,T+1), private_zone(R',PS,C), priority(R,P1), 
				priority(R',P2), R'>R.

% C. move to next step if there is blanks
step_done(robot(R), time_(T)) :- new_position(R,_,PS,SS), time_step(PS,SS,T,R).
blank(robot(R), node(C), progrstep(PS), substep(SS)) :- step_done(R,T-1), position(R,C,T+1),
				not new_position(robot(R'),C,PS,SS), not private_zone(R'',PS,C), R != R, R'' != R.
new_position(robot(R), node(C), progrstep(PS), substep(SS)) :- blank(R,C,PS,SS).

% D. BRING BLANK
push(robot(R), node(C_from), node(C_to), progrstep(PS), substep(SS)) :- priority(R,P1), robot(R'), 
				priority(R',P2), P1<P2, position(R,C1,T), time_step()
progr_done(progrstep(PS), substep(SS)) :- not new_position(_,_,PS,SS).

% E. REPOSITIONING 
% if no moves possible for the current substep of the current progression step, then we need to revert all pushes.

push_back(robot(R), node(C_from), node(C_to), progrstep(PS), substep(SS)) :- push(R,C_to,C_from,PS,SS'),
				progr_done(PS,PD), SS = PD + (PD - SS').
repositioning_done(progrstep(PS), substep(SS)) :- not new_position(_,_,PS,SS), not push_back(_,_,PS,SS).


% translate waits, new_positions and pushes into move_


