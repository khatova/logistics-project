# Crossing paths vertically
:- occurs(object(robot,A),action(move,(0,-1)),1), occurs(object(robot,B),action(move,(0,1)),1), position(robot(A), (X,Y)), position(robot(B), (X,Y-1).