position(robot(8),(2,2),3).
position(shelf(8),(2,4),0).
occurs(object(robot,8),action(move,(1,0)),4).
occurs(object(robot,8),action(move,(0,1)),5).
occurs(object(robot,8),action(move,(0,1)),6).
occurs(object(robot,8),action(move,(0,1)),7).
occurs(object(robot,8),action(move,(-1,0)),8).
occurs(object(robot,8),action(move,(0,-1)),9).
position(robot(8),(3,2),4).
position(robot(8),(3,3),5).
position(robot(8),(3,4),6).
position(robot(8),(3,5),7).
position(robot(8),(2,5),8).
position(robot(8),(2,4),9).
new_illegal_from(8,(3,2),(2,2),4).
new_illegal_from(8,(3,3),(3,2),5).
new_illegal_from(8,(3,4),(3,3),6).
new_illegal_from(8,(3,5),(3,4),7).
new_illegal_from(8,(2,5),(3,5),8).
new_illegal_from(8,(2,4),(2,5),9).
