position(robot(4),(3,5),5).
position(shelf(4),(6,7),0).
occurs(object(robot,4),action(move,(0,1)),6).
occurs(object(robot,4),action(move,(1,0)),7).
occurs(object(robot,4),action(move,(1,0)),8).
occurs(object(robot,4),action(move,(1,0)),9).
occurs(object(robot,4),action(move,(0,1)),10).
position(robot(4),(3,6),6).
position(robot(4),(4,6),7).
position(robot(4),(5,6),8).
position(robot(4),(6,6),9).
position(robot(4),(6,7),10).
new_illegal_from(4,(3,6),(3,5),6).
new_illegal_from(4,(4,6),(3,6),7).
new_illegal_from(4,(5,6),(4,6),8).
new_illegal_from(4,(6,6),(5,6),9).
new_illegal_from(4,(6,7),(6,6),10).
