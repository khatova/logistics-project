position(robot(6),(7,3),4).
position(shelf(6),(6,4),0).
occurs(object(robot,6),action(move,(0,-1)),5).
occurs(object(robot,6),action(move,(-1,0)),6).
occurs(object(robot,6),action(move,(0,1)),7).
occurs(object(robot,6),action(move,(0,1)),8).
position(robot(6),(7,2),5).
position(robot(6),(6,2),6).
position(robot(6),(6,3),7).
position(robot(6),(6,4),8).
new_illegal_from(6,(7,2),(7,3),5).
new_illegal_from(6,(6,2),(7,2),6).
new_illegal_from(6,(6,3),(6,2),7).
new_illegal_from(6,(6,4),(6,3),8).
