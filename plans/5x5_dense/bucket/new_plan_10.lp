position(robot(10),(2,3),2).
position(shelf(10),(3,1),0).
occurs(object(robot,10),action(move,(0,1)),3).
occurs(object(robot,10),action(move,(-1,0)),4).
occurs(object(robot,10),action(move,(1,0)),5).
occurs(object(robot,10),action(move,(0,-1)),6).
occurs(object(robot,10),action(move,(-1,0)),7).
occurs(object(robot,10),action(move,(0,-1)),8).
occurs(object(robot,10),action(move,(0,-1)),9).
occurs(object(robot,10),action(move,(1,0)),10).
occurs(object(robot,10),action(move,(1,0)),11).
position(robot(10),(2,4),3).
position(robot(10),(1,4),4).
position(robot(10),(2,4),5).
position(robot(10),(2,3),6).
position(robot(10),(1,3),7).
position(robot(10),(1,2),8).
position(robot(10),(1,1),9).
position(robot(10),(2,1),10).
position(robot(10),(3,1),11).
new_illegal_from(10,(2,4),(2,3),3).
new_illegal_from(10,(1,4),(2,4),4).
new_illegal_from(10,(2,4),(1,4),5).
new_illegal_from(10,(2,3),(2,4),6).
new_illegal_from(10,(1,3),(2,3),7).
new_illegal_from(10,(1,2),(1,3),8).
new_illegal_from(10,(1,1),(1,2),9).
new_illegal_from(10,(2,1),(1,1),10).
new_illegal_from(10,(3,1),(2,1),11).
