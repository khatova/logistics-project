position(robot(3),(6,2),2).
position(shelf(3),(5,5),0).
occurs(object(robot,3),action(move,(0,-1)),3).
occurs(object(robot,3),action(move,(0,1)),4).
occurs(object(robot,3),action(move,(0,1)),5).
occurs(object(robot,3),action(move,(0,1)),6).
occurs(object(robot,3),action(move,(0,1)),7).
occurs(object(robot,3),action(move,(-1,0)),8).
position(robot(3),(6,1),3).
position(robot(3),(6,2),4).
position(robot(3),(6,3),5).
position(robot(3),(6,4),6).
position(robot(3),(6,5),7).
position(robot(3),(5,5),8).
new_illegal_from(3,(6,1),(6,2),3).
new_illegal_from(3,(6,2),(6,1),4).
new_illegal_from(3,(6,3),(6,2),5).
new_illegal_from(3,(6,4),(6,3),6).
new_illegal_from(3,(6,5),(6,4),7).
new_illegal_from(3,(5,5),(6,5),8).
