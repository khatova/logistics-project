%#include <incmode>.
#program base.

% parts of asprilo input
robot(R)                     :- init(object(robot,R),          _).
shelf(S)                     :- init(object(shelf,S),          _).
position(           (X,Y))   :- init(object(node,_),           value(at,(X,Y))).
position(  robot(R),(X,Y),0) :- init(object(robot,R),          value(at,(X,Y))).
position(  shelf(S),(X,Y),0) :- init(object(shelf,S),          value(at,(X,Y))).

% initial positions:
used_pos(C) :- position(robot(R),C,T).
used_pos(C) :- used_alt(_,_,_,C,_).

% priority of a robot equals to its ordering number (maybe we can use a better heuristic later).
priority(R,R) :- robot(R).
r1_higherthan_r2(R1,R2) :- priority(R1,P1), priority(R2,P2), P1>P2. % TODO: ordering?

%num_steps(0,-1).
total_num_steps(0,-1).

new_position1(R,C,ps(0),ss(0)) :- used_pos(C), position(robot(R),C,0).
prev_position(R,C,ps(0),ss(0)) :- new_position(R,C,ps(0),ss(0)).
% This was the first step of initial plans:
initial_step(R,0,ps(0),ss(0)) :- robot(R).

% we need only alt paths for triplets that are on the initial paths of our robots
used_alt(C1,C2,C3,C,AS) :- position(robot(R),C1,T), position(robot(R),C2,T+1), position(robot(R),C3,T+2),
				alt(C1,C2,C3,C,AS).

#program pstep(progression_step).

progrstep(progression_step).
private_zone(R,ps(progression_step),ss(0),C) :- new_position(R,C,ps(progression_step),ss(0)).
% copy the previous positions for the 0th substep of the new progression step.
new_position2(R,C,ps(progression_step),ss(0)) :- pos(R,C,ps(progression_step-1),ss(SS)), repositioning_done(ps(progression_step-1),ss(SS)),
				not position(shelf(R),C,0).
initial_step(R,T,ps(progression_step),ss(0)) :- time_(T), initial_step(R,T,ps(progression_step-1),ss(SS)), 
				repositioning_done(ps(progression_step-1),ss(SS)).

#program sstep(progression_step, sub_step).

substep(progression_step,sub_step).

% private zone = all cels visited by a robot at one progression step before the specified substep
% private_zone(R,ps(progression_step),ss(sub_step),C) :- private_zone(R,ps(progression_step),ss(sub_step-1),C), sub_step>0.
% private zone = current and previous positions of a robot.
private_zone(R,ps(progression_step),ss(sub_step),C) :- prev_position(R,C,ps(progression_step),ss(sub_step)), not finished(R,ps(progression_step),ss(sub_step)),
				not pushed_before(R,ps(progression_step),ss(sub_step)).

% A. WAIT if the robot was pushed from its initial path during the current progression step
%pushed(R,ps(PS),ss(SS)) :- push(R, _, _, ps(PS), ss(SS')), substep(SS), substep(SS'), SS'<SS.
wait1(R,ps(progression_step),ss(sub_step)) :- pushed_before(R,ps(progression_step),ss(sub_step)),
				#false : progr_done(ps(progression_step),ss(SS')), SS'<=sub_step.

% B. WAIT if next step belongs to the private zone of a robot with higher priority

wait2(R,ps(progression_step),ss(sub_step)) :- position(robot(R),C,T+1), initial_step(R,T,ps(progression_step),ss(sub_step-1)),
				private_zone(R',ps(progression_step),ss(sub_step),C), r1_higherthan_r2(R',R),
				#false : progr_done(ps(progression_step),ss(SS')), SS'<=sub_step.

wait_can_be_pushed(R,ps(progression_step),ss(sub_step)) :- wait1(R,ps(progression_step),ss(sub_step)).
wait_can_be_pushed(R,ps(progression_step),ss(sub_step)) :- wait2(R,ps(progression_step),ss(sub_step)).

wait3(R,ps(progression_step),ss(sub_step)) :- position(robot(R),C,T+1), initial_step(R,T,ps(progression_step),ss(sub_step-1)),
				can_bring_blank(R1,C,_,_,_,ps(progression_step),ss(sub_step)), r1_higherthan_r2(R1,R), brought_blank(R1,_,ps(progression_step),ss(sub_step)),
				#false : progr_done(ps(progression_step),ss(SS')), SS'<=sub_step.

wait(R,ps(progression_step),ss(sub_step)) :- wait1(R,ps(progression_step),ss(sub_step)), not robot_push(R,ps(progression_step),ss(sub_step)).
wait(R,ps(progression_step),ss(sub_step)) :- wait2(R,ps(progression_step),ss(sub_step)), not robot_push(R,ps(progression_step),ss(sub_step)).
wait(R,ps(progression_step),ss(sub_step)) :- wait3(R,ps(progression_step),ss(sub_step)), not robot_push(R,ps(progression_step),ss(sub_step)).
%prev_position(R,C,C',ps(PS),ss(SS)) :- prev_position(R,C,C',ps(PS),ss(SS-1)), wait(R,ps(PS),ss(SS)).


% wait if arrived at goal
wait(R,ps(progression_step),ss(sub_step)) :- pos(R,C,ps(progression_step),ss(sub_step-1)), position(shelf(R),C,0).


% -> transform wait() into new_position() (needed for bring blank algorithm)
new_position3(R,C,ps(progression_step),ss(sub_step)) :- new_position(R,C,ps(progression_step),ss(sub_step-1)), wait(R,ps(progression_step),ss(sub_step)).

% we're staying on the same time_(T) of an initial plan if we wait at the current substep
initial_step1(R,T,ps(progression_step),ss(sub_step)) :- time_(T), initial_step(R,T,ps(progression_step),ss(sub_step-1)), wait(R,ps(progression_step),ss(sub_step)).

% C. MOVE to next step if there is blank
% next cell on initial path is blank if it doesn't belong to a private zone of a robot with higher priority
%no_next_blank_1(R,C,ps(PS),ss(SS+1)) :- new_position(R',C,ps(PS),ss(SS)), R' != R.
%no_next_blank_2(R,C,ps(PS),ss(SS+1)) :- new_position(R',C,ps(PS),ss(SS+1)), R' != R.

% node conflict
next_occupied1(R,C,ps(progression_step),ss(sub_step)) :- pos(R,C',ps(progression_step),ss(sub_step-1)), pos(R',C,ps(progression_step),ss(sub_step-1)),
				initial_step(R,T-1,ps(progression_step),ss(sub_step-1)), position(robot(R),C,T),
				initial_step(R',T'-1,ps(progression_step),ss(sub_step-1)), position(robot(R'),C',T'),
				not wait(R',_,ps(progression_step),ss(sub_step)), r1_higherthan_r2(R',R),
				#false : progr_done(ps(progression_step),ss(SS')), SS' <= sub_step.

next_occupied2(R,C,ps(progression_step),ss(sub_step)) :- pos(R,C',ps(progression_step),ss(sub_step-1)), pos(R',C,ps(progression_step),ss(sub_step-1)),
				initial_step(R,T-1,ps(progression_step),ss(sub_step-1)), position(robot(R),C,T), wait(R',ps(progression_step),ss(sub_step-1)),
				not wait(R',_,ps(progression_step),ss(sub_step)), 
				#false : progr_done(ps(progression_step),ss(SS')), SS' <= sub_step.

next_occupied(R,C,ps(progression_step),ss(sub_step)) :- next_occupied1(R,C,ps(progression_step),ss(sub_step)).
next_occupied(R,C,ps(progression_step),ss(sub_step)) :- next_occupied2(R,C,ps(progression_step),ss(sub_step)).

want(R,C,ps(progression_step),ss(sub_step)) :- initial_step(R,T,ps(progression_step),ss(sub_step-1)), position(robot(R),C,T+1),
				not blocked2(R,C,ps(progression_step),ss(sub_step)), not pushed_before(R,ps(progression_step),ss(sub_step)).

next_blank(R,C,ps(progression_step),ss(sub_step)) :- want(R,C,ps(progression_step),ss(sub_step)),
				#false : new_position(R',C,ps(progression_step),ss(sub_step)), R' != R;
				#false : private_zone(R'',ps(progression_step),ss(sub_step),C), r1_higherthan_r2(R'',R);
				#false : blocked(R1,ps(progression_step),ss(sub_step)), pos(R1,C,ps(progression_step),ss(sub_step-1)), R1 != R.

%blocked1(R,ps(progression_step),ss(sub_step)) :- need_blank(R,C,ps(progression_step),ss(sub_step)), 
%				not can_bring_blank(R,_,_,_,C,ps(progression_step),ss(sub_step)).
blocked2(R,ps(progression_step),ss(sub_step)) :- robot_push(R,ps(progression_step),ss(SS)), SS<sub_step.
blocked3(R,ps(progression_step),ss(sub_step)) :- want(R,C,ps(progression_step),ss(sub_step)), want(R1,C,ps(progression_step),ss(sub_step)), r1_higherthan_r2(R1,R).
blocked4(R,ps(progression_step),ss(sub_step)) :- want(R,C,ps(progression_step),ss(sub_step)), private_zone(R',ps(progression_step),ss(sub_step),C), r1_higherthan_r2(R',R).

%blocked5(R,ps(progression_step),ss(sub_step)) :- blocked(R,ps(progression_step),ss(sub_step-1)).

blocked(R,ps(progression_step),ss(sub_step)) :- blocked1(R,ps(progression_step),ss(sub_step)).
blocked(R,ps(progression_step),ss(sub_step)) :- blocked2(R,ps(progression_step),ss(sub_step)).
blocked(R,ps(progression_step),ss(sub_step)) :- blocked3(R,ps(progression_step),ss(sub_step)).
blocked(R,ps(progression_step),ss(sub_step)) :- blocked4(R,ps(progression_step),ss(sub_step)).
blocked(R,ps(progression_step),ss(sub_step)) :- blocked5(R,ps(progression_step),ss(sub_step)).

wait(R,ps(progression_step),ss(sub_step)) :- blocked(R,ps(progression_step),ss(sub_step)), not robot_push(R,ps(progression_step),ss(sub_step)),
				not brought_blank(R,_,ps(progression_step),ss(sub_step)), 
				#false : progr_done(ps(progression_step),ss(SS)), SS < sub_step.

finished(R,ps(progression_step),ss(sub_step)) :- pos(R,C,ps(progression_step),ss(sub_step)), position(shelf(R),C,0).
finished(R,ps(progression_step),ss(sub_step)) :- finished(R,ps(progression_step),ss(sub_step-1)).

%next_blank(R,C,ps(progression_step),ss(sub_step)) :- initial_step(R,T-1,ps(progression_step),ss(sub_step-1)), position(robot(R),C,T),
%				not next_occupied(R,C,ps(progression_step),ss(sub_step)), %not robot_push(R,ps(progression_step),ss(sub_step)),
%				#false : new_position(R',C,ps(progression_step),ss(sub_step)), R' != R;
%				#false : private_zone(R'',ps(progression_step),ss(sub_step),C), r1_higherthan_r2(R'',R);
%				#false : need_blank(R''',C,ps(progression_step),ss(sub_step)), r1_higherthan_r2(R''',R);
%				not need_blank(R,_,ps(progression_step),ss(sub_step)),
%				#false : wait_can_be_pushed(RP,ps(progression_step),ss(sub_step)), r1_higherthan_r2(R,RP).

% in previous line "not new_position()"" maybe is redundant
movement(R,C,ps(progression_step),ss(sub_step)) :- next_blank(R,C,ps(progression_step),ss(sub_step)), not wait(R,ps(progression_step),ss(sub_step)),
				not blocked(R,ps(progression_step),ss(sub_step)).
%movement_(R,C,ps(progression_step),ss(sub_step)) :- next_blank(R,C,ps(progression_step),ss(sub_step)), not wait(R,ps(progression_step),ss(sub_step)).
any_movement(ps(progression_step),ss(sub_step)) :- movement(R,C,ps(progression_step),ss(sub_step)).
private_zone(R,ps(progression_step),ss(sub_step),C) :- movement(R,C,ps(progression_step),ss(sub_step)).
new_position4(R,C,ps(progression_step),ss(sub_step)) :- movement(R,C,ps(progression_step),ss(sub_step)).
%prev_position(R,C,C',ps(PS),ss(SS)) :- movement(R,C,ps(PS),ss(SS)), new_position(R,C',ps(PS),ss(SS-1)).

% go to next initial step if movement() done.
initial_step2(R,T,ps(progression_step),ss(sub_step)) :- time_(T), initial_step(R,T-1,ps(progression_step),ss(sub_step-1)), movement(R,C,ps(progression_step),ss(sub_step)), used_pos(C).
% TODO: move only if goal not achieved yet (maybe it already works?)

% D. BRING BLANK

pushed_before(R,ps(progression_step),ss(sub_step)) :- push(R,C1,C2,I,ps(progression_step),ss(SS')), SS'<sub_step, used_pos(C1), used_pos(C2).
need_blank(R,C,ps(progression_step),ss(sub_step)) :- want(R,C,ps(progression_step),ss(sub_step)), not next_blank(R,C,ps(progression_step),ss(sub_step)),
				not blocked(R,ps(progression_step),ss(sub_step)).

%need_blank(R,C,ps(progression_step),ss(sub_step)) :- initial_step(R,T,ps(progression_step),ss(sub_step-1)), position(robot(R),C,T+1),
%				next_occupied(R,C,ps(progression_step),ss(sub_step)),
%				#false : R1!=R, new_position(R1,C,ps(progression_step),ss(sub_step-1)), next_blank(R1,C1,ps(progression_step),ss(sub_step)), C!=C1, used_pos(C1);
%				#false : movement(R,C',ps(progression_step),ss(sub_step)), used_pos(C'); 
%				not pushed_before(R,ps(progression_step),ss(sub_step)), 
%				#false : progr_done(ps(progression_step),ss(SS')), SS' <= sub_step;
%				#false : wait(R,ps(progression_step),ss(SS')), SS'<=sub_step.

%need_blank(R,C,ps(progression_step),ss(sub_step)) :- initial_step(R,T,ps(progression_step),ss(sub_step-1)), position(robot(R),C,T+1),
%				pos(R2,C,ps(progression_step),ss(sub_step-1)), push(R',_,C,_,ps(progression_step),ss(_)),
%				#false : R1!=R, new_position(R1,C,ps(progression_step),ss(sub_step-1)), next_blank(R1,C1,ps(progression_step),ss(sub_step)), C!=C1, used_pos(C1);
%				#false : movement(R,C',ps(progression_step),ss(sub_step)), used_pos(C'); 
%				not pushed_before(R,ps(progression_step),ss(sub_step)), 
%				#false : progr_done(ps(progression_step),ss(SS')), SS' <= sub_step;
%				#false : wait(R,ps(progression_step),ss(SS')), SS'<=sub_step.

%need_blank(R,C,ps(progression_step),ss(sub_step)) :- initial_step(R,T,ps(progression_step),ss(sub_step-1)), position(robot(R),C,T+1),
%				pos(R2,C,ps(progression_step),ss(sub_step-1)), wait_can_be_pushed(R2,ps(progression_step),ss(sub_step)), r1_higherthan_r2(R,R2),
%				#false : R1!=R, new_position(R1,C,ps(progression_step),ss(sub_step-1)), next_blank(R1,C1,ps(progression_step),ss(sub_step)), C!=C1, used_pos(C1);
%				#false : movement(R,C',ps(progression_step),ss(sub_step)), used_pos(C'); 
%				not pushed_before(R,ps(progression_step),ss(sub_step)), 
%				#false : progr_done(ps(progression_step),ss(SS')), SS' <= sub_step;
%				#false : wait(R,ps(progression_step),ss(SS')), SS'<=sub_step.

% Blank here is defined as non-occupied cell on the alt path from the position at the previous time step t-1 
% to the position at the next step t+1, which doesn't belong to a private zone of any robot with higher priority

% 1) Check if such position exists (it ALWAYS exists for the robot with the highest priority, and it may exist
% for some oter robots too)

% alt_blank() fires if there's a blank on the alt path if we consider robot R tring to do his step from C2 to C3, 
% with its previous osition being C1.
private_of_higher(R,C,ps(progression_step),ss(sub_step)) :- need_blank(R,C',ps(progression_step),ss(sub_step)), 
				private_zone(R',ps(progression_step),ss(sub_step),C), r1_higherthan_r2(R',R).
position_of_any(C,ps(progression_step),ss(sub_step)) :- new_position(R',C,ps(progression_step),ss(sub_step)), robot(R').%, r1_higherthan_r2(R',R).
%position_of_higher(R,C,ps(PS),ss(SS)) :- need_blank(R,C',ps(PS),ss(SS+1)), used_pos(C'), new_position(R',C,ps(PS),ss(SS)), r1_higherthan_r2(R',R).
need_alt(C1,C2,C3,ps(progression_step),ss(sub_step)) :- new_position(R,C2,ps(progression_step),ss(sub_step-1)), 
				prev_position(R,C1,ps(progression_step),ss(sub_step-1)), need_blank(R,C3,ps(progression_step),ss(sub_step)),
				not used_alt(C1,C2,C3,_,_), substep(progression_step,sub_step).
got_alt(C1,C2,C3,C,AS,ps(progression_step),ss(sub_step)) :- need_alt(C1,C2,C3,ps(progression_step),ss(sub_step)), 
				alt(C1,C2,C3,C,AS), substep(progression_step,sub_step).

used_alt1(C1,C2,C3,C_is_blank,AS,ps(progression_step),ss(sub_step)) :- got_alt(C1,C2,C3,C_is_blank,AS,ps(progression_step),ss(sub_step)).
used_alt1(C1,C2,C3,C_is_blank,AS,ps(progression_step),ss(sub_step)) :- used_alt(C1,C2,C3,C_is_blank,AS), substep(progression_step,sub_step).

alt_blank(R,C_is_blank,C1,C2,C3,ps(progression_step),ss(sub_step),AS) :- new_position(R,C2,ps(progression_step),ss(sub_step-1)), 
				prev_position(R,C1,ps(progression_step),ss(sub_step-1)), need_blank(R,C3,ps(progression_step),ss(sub_step)), 
				used_alt1(C1,C2,C3,C_is_blank,AS,_,_), not position_of_any(C_is_blank,ps(progression_step),ss(sub_step-1)), 
				not private_of_higher(R,C_is_blank,ps(progression_step),ss(sub_step-1)).

shorter_alt_blank(R,C_is_blank,C1,C2,C3,ps(progression_step),ss(sub_step),AS) :- alt_blank(R,C_is_blank,C1,C2,C3,ps(progression_step),ss(sub_step),AS), 
				alt_blank(R,C',C1,C2,C3,ps(progression_step),ss(sub_step),AS'), AS'>AS.
cant_push(R,C_is_blank,C1,C2,C3,ps(progression_step),ss(sub_step)) :- alt_blank(R,C_is_blank,C1,C2,C3,ps(progression_step),ss(sub_step),AS), 
				used_alt1(C1,C2,C3,C',AS',_,_), AS'>AS, 
				need_blank(R,C'',ps(progression_step),ss(sub_step)), used_pos(C''), new_position(R',C',ps(progression_step),ss(sub_step-1)), 
				not wait_can_be_pushed(R,ps(progression_step),ss(sub_step)),
				r1_higherthan_r2(R',R).
can_bring_blank(R,C_is_blank,C1,C2,C3,ps(progression_step),ss(sub_step)) :- alt_blank(R,C_is_blank,C1,C2,C3,ps(progression_step),ss(sub_step),AS), 
				not cant_push(R,C_is_blank,C1,C2,C3,ps(progression_step),ss(sub_step)), 
				not shorter_alt_blank(R,C_is_blank,C1,C2,C3,ps(progression_step),ss(sub_step),AS). 

% robots need to be pushed along the alt path from the cells positioned between blank and our next step.
% robot(R) here is the robot which needs blank on his next step, not a robot that we need to push!
% push_from_cell() fires for cells C from which robots need to be pushed along the alt path for a triplet(C1,C2,C_need_blank)
push_from_cell(R,R',C,C1,C2,C_need_blank,ps(progression_step),ss(sub_step)) :- can_bring_blank(R,C_is_blank,C1,C2,C_need_blank,ps(progression_step),ss(sub_step)),
				used_alt1(C1,C2,C_need_blank,C_is_blank,AS,_,_), used_alt1(C1,C2,C_need_blank,C,AS',_,_),
				AS'>AS, new_position(R',C,ps(progression_step),ss(sub_step-1)),
				r1_higherthan_r2(R,R'), not next_blank(R',_,ps(progression_step),ss(sub_step)).

% 2) push robots with lower priority back along the alt path (this brings blank to the first cell of the triplet)
% - need to transform pushes and waits into new_positions because it can be its new_position() if it was already pushed 
%   or position() if it waited.
any_push(ps(progression_step),ss(sub_step)) :- push(R,C1,C2,I,ps(progression_step),ss(sub_step)).
robot_push(R,ps(progression_step),ss(sub_step)) :- push(R,C1,C2,I,ps(progression_step),ss(sub_step)).
{push(R',C_from,C_to,I,ps(progression_step),ss(sub_step))} :- push_from_cell(R,R',C_from,C1,C2,C_need_blank,ps(progression_step),ss(sub_step)), 
					used_alt1(C1,C2,C_need_blank,C_from,AS,_,_),  
					used_alt1(C1,C2,C_need_blank,C_to,AS-1,_,_), I = #count{SS' : any_push(ps(progression_step),ss(SS')), SS' < sub_step},
					#false : pos(R1,C_to,ps(progression_step),ss(sub_step)), r1_higherthan_r2(R1,R');
					#false : private_zone(R',ps(progression_step),ss(sub_step),C), r1_higherthan_r2(R',R).%, progrstep(PS).


% 3) finally, we brought blank and can move now
%brought_blank(R,C,ps(progression_step),ss(sub_step)) :- push_from_cell(R,R',C',C1,C2,C,ps(progression_step),ss(sub_step)), 
%				push(R',C',C3,I,ps(progression_step),ss(sub_step)).
brought_blank(R,C,ps(progression_step),ss(sub_step)) :- push_from_cell(R,R',C',C1,C2,C,ps(progression_step),ss(sub_step)), 
				push(R',C',C3,I,ps(progression_step),ss(sub_step)).
new_position5(R,C,ps(progression_step),ss(sub_step)) :- brought_blank(R,C,ps(progression_step),ss(sub_step)).
private_zone(R,ps(progression_step),ss(sub_step),C) :- brought_blank(R,C,ps(progression_step),ss(sub_step)).
initial_step3(R,T,ps(progression_step),ss(sub_step)) :- time_(T), initial_step(R,T-1,ps(progression_step),ss(sub_step-1)), 
				brought_blank(R,C,ps(progression_step),ss(sub_step)).

% OR, if a robot couldn't bring blank and wasn't pushed, then it waits
wait(R,ps(progression_step),ss(sub_step)) :- need_blank(R,C,ps(progression_step),ss(sub_step)), 
				not can_bring_blank(R,_,_,_,C,ps(progression_step),ss(sub_step)), not push(R,_,_,_,ps(progression_step),ss(sub_step)).

wait(R,ps(progression_step),ss(sub_step)) :- need_blank(R,_,ps(progression_step),ss(sub_step)), 
				push_from_cell(R,R',_,_,_,_,ps(progression_step),ss(sub_step)),
				not push(R',_,_,_,ps(progression_step),ss(sub_step)).

% translate push into new_position()
new_position6(R,C,ps(progression_step),ss(sub_step)) :- push(R,_,C,_,ps(progression_step),ss(sub_step)).
%private_zone(R,ps(progression_step),ss(sub_step),C) :- push(R,_,C,_,ps(progression_step),ss(sub_step)).
%prev_position(R,C,C',ps(PS),ss(SS)) :- new_position(R,C,ps(PS),ss(SS)), push(R,C',C,I,ps(PS),ss(SS)).

% we're staying on the same step of the initial plan if we were pushed
initial_step4(R,T,ps(progression_step),ss(sub_step)) :- time_(T), initial_step(R,T,ps(progression_step),ss(sub_step-1)), 
				robot_push(R,ps(progression_step),ss(sub_step)).


% finish progression step if no robots can move
%progr_done(ps(progression_step),ss(sub_step-1)).
progr_done(ps(progression_step),ss(sub_step-1)) :- not any_movement(ps(progression_step),ss(sub_step)), not any_push(ps(progression_step),ss(sub_step)), 
				sub_step != 0, #false : progr_done(ps(progression_step),ss(SS')), SS' < sub_step-1.
%progr_done(ps(progression_step),ss(sub_step)) :- A == F + B, A == #count{R : active_robot(R,ps(progression_step),_)},
%				F == #count{R : finished(R,ps(progression_step),ss(sub_step))}, B == #count{R : blocked(R,ps(progression_step),ss(sub_step))}.

% E. REPOSITIONING 
% if no moves possible for the current substep of the current progression step, then we need to revert all pushes.
count_push(I,ps(progression_step),ss(sub_step)) :- push(_,_,_,I,ps(progression_step),ss(sub_step)).
%num_pushes(N,ps(PS)) :- N = #count{I : count_push(I,ps(PS))}, progrstep(PS).
%total_num_pushes(N,ps(PS)) :- N = #max{NN : num_pushes(NN,ps(PS))}, progrstep(PS).


want_push_back(R,C_from,C_to,ps(progression_step),ss(sub_step)) :- push(R,C_to,C_from,I,ps(progression_step),ss(SS')), SS'<sub_step,
				count_push(N,ps(progression_step),_), #false : count_push(N',ps(progression_step),_), N' > N;
				progr_done(ps(progression_step),ss(PD)), sub_step == PD + (N + 1 - I).%, substep(SS). %PD + (N + 2 - I)

% we can't push back if there's a robot waiting in that position.
cant_push_back(R,C_from,C_to,ps(progression_step),ss(sub_step)) :- want_push_back(R,C_from,C_to,ps(progression_step),ss(sub_step)), 
				re_position1(R1,C_to,ps(progression_step),ss(sub_step)), R1!=R.
% we can't do further push_backs if we already missed one push_back before.
cant_push_back(R,C_from,C_to,ps(progression_step),ss(sub_step)) :- cant_push_back(R,_,_,ps(progression_step),ss(SS)), SS<sub_step,
				want_push_back(R,C_from,C_to,ps(progression_step),ss(sub_step)).

do_push_back(R,C_from,C_to,ps(progression_step),ss(sub_step)) :- want_push_back(R,C_from,C_to,ps(progression_step),ss(sub_step)), 
				not cant_push_back(R,C_from,C_to,ps(progression_step),ss(sub_step)).

robot_push_back(R,ps(progression_step),ss(sub_step)) :- do_push_back(R,C_from,C_to,ps(progression_step),ss(sub_step)).

% if the robot doesn't need to do repositioning at the current substep, its position stays the same.
re_position1(R,C,ps(progression_step),ss(sub_step)) :- want_push_back(R',_,_,ps(progression_step),ss(sub_step)), R' != R, 
				not robot_push_back(R,ps(progression_step),ss(sub_step)),
				pos(R,C,ps(progression_step),ss(sub_step-1)), robot(R), used_pos(C).

% Stay if can't push back
re_position1(R,C,ps(progression_step),ss(sub_step)) :- pos(R,C,ps(progression_step),ss(sub_step-1)), 
				cant_push_back(R,_,_,ps(progression_step),ss(sub_step)).

% translate push_back into re_position()
re_position2(R,C,ps(progression_step),ss(sub_step)) :- do_push_back(R,C',C,ps(progression_step),ss(sub_step)).
re_position(R,C,ps(progression_step),ss(sub_step)) :- re_position1(R,C,ps(progression_step),ss(sub_step)).
re_position(R,C,ps(progression_step),ss(sub_step)) :- re_position2(R,C,ps(progression_step),ss(sub_step)).
any_re_position(ps(progression_step),ss(sub_step)) :- re_position(R,C,ps(progression_step),ss(sub_step)).
%prev_position(R,C,C',ps(PS),ss(SS)) :- re_position2(R,C,ps(PS),ss(SS)), push_back(R,C',C,ps(PS),ss(SS)).
%prev_position(R,C,C',ps(PS),ss(SS)) :- prev_position(R,C,C',ps(PS),ss(SS-1)), re_position1(R,C,ps(PS),ss(SS)).

% we need to save the info about cant_push_back() for the next progression step.
% We need to remember their correct order.
save_push_back(R,C_from,C_to,ps(progression_step),ss(sub_step),J) :- cant_push_back(R,C_from,C_to,ps(progression_step),ss(sub_step)), push(R,C_to,C_from,_,ps(progression_step),ss(SS)),
				progr_done(ps(progression_step),ss(PD)), J=sub_step-PD, SS<sub_step.
re_save_push_back(R,C_from,C_to,ps(progression_step),ss(sub_step),J) :- saved_push_back(R,C_from,C_to,ps(progression_step-1),ss(_),J), cant_push_back(R,C_from,C_to,ps(progression_step),ss(sub_step)),
				#false : saved_push_back(R,C1_from,C1_to,ps(progression_step-1),ss(_),J-1), do_push_back(R,C1_from,C1_to,ps(progression_step),ss(_)),
				progr_done(ps(progression_step),ss(PD)), J=sub_step-PD.
re_save_push_back(R,C_from,C_to,ps(progression_step),ss(sub_step),J-1) :- saved_push_back(R,C_from,C_to,ps(progression_step-1),ss(_),J), cant_push_back(R,C_from,C_to,ps(progression_step),ss(sub_step)),
				saved_push_back(R,C1_from,C1_to,ps(progression_step-1),ss(_),J-1), do_push_back(R,C1_from,C1_to,ps(progression_step),ss(_)),
				progr_done(ps(progression_step),ss(PD)), J=sub_step-PD.
				
% Do saved pushbacks.
want_push_back(R,C_from,C_to,ps(progression_step),ss(sub_step)) :- saved_push_back(R,C_from,C_to,ps(progression_step-1),ss(_),J), 
				progr_done(ps(progression_step),ss(PD)), sub_step=PD+J.

% we're staying on the same step of the initial plan if we were pushed back
initial_step5(R,T,ps(progression_step),ss(sub_step)) :- time_(T), initial_step(R,T,ps(progression_step),ss(sub_step-1)), 
				any_re_position(ps(progression_step),ss(sub_step)).

% repositioning is finished. We can move on to the next progression step.
repositioning_done(ps(progression_step),ss(sub_step-1)) :- progr_done(ps(progression_step),ss(SS'')), SS''<sub_step,
				not any_movement(ps(progression_step),ss(sub_step)), not any_re_position(ps(progression_step),ss(sub_step)),
				#false : repositioning_done(ps(progression_step),ss(SS')), SS' < sub_step-1.
%prev_position(R,C,C',ps(PS+1),ss(0)) :- prev_position(R,C,C',ps(PS),ss(SS)), repositioning_done(ps(PS),ss(SS)).
%new_position(R,C,ps(PS+1),ss(0)) :- re_position(R,C,ps(PS),ss(SS)), repositioning_done(ps(PS),ss(SS)).

new_position(R,C,ps(progression_step),ss(sub_step)) :- new_position1(R,C,ps(progression_step),ss(sub_step)).
new_position(R,C,ps(progression_step),ss(sub_step)) :- new_position2(R,C,ps(progression_step),ss(sub_step)).
new_position(R,C,ps(progression_step),ss(sub_step)) :- new_position3(R,C,ps(progression_step),ss(sub_step)).
new_position(R,C,ps(progression_step),ss(sub_step)) :- new_position4(R,C,ps(progression_step),ss(sub_step)).
new_position(R,C,ps(progression_step),ss(sub_step)) :- new_position5(R,C,ps(progression_step),ss(sub_step)).
new_position(R,C,ps(progression_step),ss(sub_step)) :- new_position6(R,C,ps(progression_step),ss(sub_step)).


any_new_position(ps(progression_step),ss(sub_step)) :- new_position(R,C,ps(progression_step),ss(sub_step)).
initial_step6(R,T,ps(progression_step+1),ss(0)) :- time_(T), initial_step(R,T,ps(progression_step),ss(sub_step-1)), 
				repositioning_done(ps(progression_step),ss(sub_step)).

initial_step(R,T,ps(progression_step),ss(sub_step)) :- initial_step1(R,T,ps(progression_step),ss(sub_step)).
initial_step(R,T,ps(progression_step),ss(sub_step)) :- initial_step2(R,T,ps(progression_step),ss(sub_step)).
initial_step(R,T,ps(progression_step),ss(sub_step)) :- initial_step3(R,T,ps(progression_step),ss(sub_step)).
initial_step(R,T,ps(progression_step),ss(sub_step)) :- initial_step4(R,T,ps(progression_step),ss(sub_step)).
initial_step(R,T,ps(progression_step),ss(sub_step)) :- initial_step5(R,T,ps(progression_step),ss(sub_step)).
initial_step(R,T,ps(progression_step),ss(sub_step)) :- initial_step6(R,T,ps(progression_step),ss(sub_step)).

% common predicate for new_position() and re_position()
pos(R,(X1,Y1),ps(progression_step),ss(sub_step)) :- new_position(R,(X1,Y1),ps(progression_step),ss(sub_step)).
pos(R,(X1,Y1),ps(progression_step),ss(sub_step)) :- re_position(R,(X1,Y1),ps(progression_step),ss(sub_step)).

% translate wait() and pos() into move_
%move_(R,(0,0),T) :- wait(R,_,ss(T)).
%num_steps(N,progression_step) :- N1 = #count {SS : any_new_position(ps(progression_step),ss(SS))},
%				N2 = #count {SS : any_re_position(ps(progression_step),ss(SS))}, N=N1+N2-1.
total_num_steps(TN,progression_step) :- total_num_steps(TN', progression_step-1), repositioning_done(ps(progression_step),ss(sub_step-1)), 
				TN = TN' + sub_step - 1.


%:- not repositioning_done(ps(PS),ss(SS)), substep(SS), PS = #max{PS' : progrstep(PS')}.

% We need to remember the previous positions at each substep
prev_position1(R,C,ps(progression_step),ss(sub_step)) :- pos(R,C',ps(progression_step),ss(sub_step)), pos(R,C,ps(progression_step),ss(sub_step-1)), 
				C!=C', sub_step!=0.
prev_position2(R,C,ps(progression_step),ss(sub_step)) :- pos(R,C',ps(progression_step),ss(sub_step)), pos(R,C',ps(progression_step),ss(sub_step-1)), 
				prev_position(R,C,ps(progression_step),ss(sub_step-1)), sub_step!=0.
prev_position3(R,C,ps(progression_step),ss(0)) :- prev_position(R,C,ps(progression_step-1),ss(SS)), repositioning_done(ps(progression_step-1),ss(SS)).
prev_position(R,C,ps(progression_step),ss(sub_step)) :- prev_position1(R,C,ps(progression_step),ss(sub_step)).
prev_position(R,C,ps(progression_step),ss(sub_step)) :- prev_position2(R,C,ps(progression_step),ss(sub_step)).
prev_position(R,C,ps(progression_step),ss(0)) :- prev_position3(R,C,ps(progression_step),ss(0)).

active_robot(R,ps(progression_step),ss(sub_step)) :- pos(R,C,ps(progression_step),ss(sub_step-1)),repositioning_done(ps(progression_step),ss(sub_step-1)),
				position(shelf(R),C',0), C' != C.

:- pos(R1,C,ps(progression_step),ss(sub_step)), pos(R2,C,ps(progression_step),ss(sub_step)), R1!=R2.
:- pos(R,C,ps(progression_step),ss(sub_step-1)), pos(R,_,ps(progression_step),ss(0)), not pos(R,_,ps(progression_step),ss(sub_step)), 
				not position(shelf(R),C,0), sub_step>0, not repositioning_done(ps(progression_step),ss(sub_step-1)).
%:- push(R,C_from,C_to,_,ps(progression_step),ss(sub_step)), position(robot(R),C_from,T-1), position(robot(R),C_to,T).

#show.
#show init/2.
#show initial_step/4.
#show pos/4.
#show active_robot/3.
#show total_num_steps/2.
#show move_/4.

#show progrstep/1.
#show substep/2.

#show new_position/4.
#show new_position1/4.
#show new_position2/4.
#show new_position3/4.
#show new_position4/4.
#show new_position5/4.
#show new_position6/4.
%#show position/3.
#show private_zone/4.
#show r1_higherthan_r2/2.
#show next_blank/4.
#show next_occupied1/4.
#show next_occupied2/4.
#show next_occupied/4.
#show need_blank/4.
#show alt_blank/8.
#show initial_step/4.
#show initial_step1/4.
#show initial_step2/4.
#show initial_step3/4.
#show initial_step4/4.
#show initial_step5/4.
#show initial_step6/4.
#show movement/4.
#show movement_/4.
#show push_from_cell/8.
#show push/6.
#show push_/6.
#show do_push_back/5.
#show want_push_back/5.
#show cant_push_back/5.
#show save_push_back/6.
#show re_save_push_back/6.
#show saved_push_back/6.

#show brought_blank/4.
#show brought_blank_/4.
#show wait/3.
#show wait1/3.
#show wait2/3.
#show wait3/3.
%#show wait_p/3.
#show can_bring_blank/7.
%#show position_of_higher/4.
%#show cant_push/7.
#show progr_done/2.
#show re_position/4.
#show re_position1/4.
#show re_position2/4.
#show repositioning_done/2.
#show pos/4.
#show move_/3.
#show num_steps/2.
#show mvmt/4.
#show total_num_steps/2.
#show total_num_pushes/2.
#show used_alt/5.
#show used_alt1/7.
#show used_pos/1.
#show any_movement/2.
#show any_push/2.
#show robot_push/3.
#show robot_push_back/3.
#show private_of_higher/4.
#show position_of_any/3.
#show num_pushes/2.

#show prev_position/4.
#show prev_position1/4.
#show prev_position2/4.
#show prev_position3/4.

#show position/3.
#show r1_higherthan_r2/2.

#show blocked/3.
#show blocked1/3.
#show blocked2/3.
#show blocked3/3.
#show blocked4/3.
#show blocked5/3.
#show want/4.

#show need_alt/5.
#show got_alt/7.

#show count_push/3.