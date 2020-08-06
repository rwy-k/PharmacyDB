USE Pharmacy;
#Отримати відомості про конкретні ліки (їх тип, спосіб приготування, назви всіх компонент, ціни, кількість компонент на складі). 
DROP PROCEDURE IF EXISTS info_med;
DELIMITER //
CREATE PROCEDURE info_med(IN med VARCHAR(45))
BEGIN
	SELECT NameOfMedicine as 'Name', TypeOfMedicine as 'Type', Preparation, Component, (Cost*CountOfComponent) as Cost, Count 
    FROM guideofpreparation g JOIN (storagecomponent s JOIN componentinmedicine i ON s.idComponent = i.idComponent)
    ON g.ID = i.idMedicine WHERE NameOfMedicine = med
    UNION 
    SELECT s.NameOfMedicine, TypeOfMedicine, Preparation, '-', Cost, Count
    FROM guideofpreparation g JOIN storagemedicine s ON g.NameOfMedicine = s.NameOfMedicine
    WHERE s.NameOfMedicine = med
    UNION
    SELECT 'Total:', '','', '', SUM(Cost*CountOfComponent), SUM(Count)
	FROM guideofpreparation g JOIN (storagecomponent s JOIN componentinmedicine i ON s.idComponent = i.idComponent)
    ON g.ID = i.idMedicine WHERE NameOfMedicine = med;
END//

CALL info_med('Barvoval');