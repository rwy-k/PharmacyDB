USE Pharmacy;
#Отримати перелік і типи ліків, які досягли своєї критичної норми або закінчилися. 
/*
UPDATE storagecomponent SET Count = 1 WHERE idComponent = 1;
UPDATE storagecomponent SET Count = 2 WHERE idComponent = 2;
UPDATE storagecomponent SET Count = 3 WHERE idComponent = 3;
UPDATE storagecomponent SET Count = 0 WHERE idComponent = 4;
*/

DROP PROCEDURE IF EXISTS component_ended;
DROP PROCEDURE IF EXISTS medicine_ended;

DELIMITER //
CREATE PROCEDURE component_ended ()
BEGIN
	SELECT Component, Count, CriticalCount FROM storagecomponent WHERE (Count<=CriticalCount)
    GROUP BY Component
    HAVING COUNT(*)>0;
END//

DELIMITER //
CREATE PROCEDURE medicine_ended ()
BEGIN
	SELECT s.NameOfMedicine, TypeOfMedicine, Count, CriticalCount FROM storagemedicine s JOIN guideofpreparation g ON s.NameOfMedicine = g.NameOfMedicine
    WHERE (Count<=CriticalCount)
    GROUP BY s.NameOfMedicine
    HAVING COUNT(*)>0;
END//

CALL component_ended ();
CALL medicine_ended ();