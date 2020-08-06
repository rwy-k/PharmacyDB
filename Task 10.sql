USE Pharmacy;
#Отримати всі технології приготування ліків зазначених типів, конкретних ліків, ліків, що знаходяться в довіднику замовлень у виробництві. 
DROP PROCEDURE IF EXISTS technology_type;
DROP PROCEDURE IF EXISTS technology_name;
DROP PROCEDURE IF EXISTS technology_inprogress;

DELIMITER //
CREATE PROCEDURE technology_type(IN med_type VARCHAR(45))
BEGIN
	SELECT NameOfMedicine, TypeOfMedicine, Preparation, Component, CountOfComponent 
    FROM guideofpreparation g JOIN (componentinmedicine i JOIN storagecomponent s ON i.idComponent = s.idComponent) ON g.ID=i.idMedicine
    WHERE TypeOfMedicine = med_type
    UNION
    SELECT NameOfMedicine, TypeOfMedicine, Preparation, '', ''
    FROM guideofpreparation WHERE Preparation = 'Done' AND TypeOfMedicine = med_type;
END//

DELIMITER //
CREATE PROCEDURE technology_name(IN med_name VARCHAR(45))
BEGIN
	SELECT NameOfMedicine, TypeOfMedicine, Preparation, Component, CountOfComponent 
    FROM guideofpreparation g JOIN (componentinmedicine i JOIN storagecomponent s ON i.idComponent = s.idComponent) ON g.ID=i.idMedicine
    WHERE NameOfMedicine = med_name
    UNION
    SELECT NameOfMedicine, TypeOfMedicine, Preparation, '', ''
    FROM guideofpreparation WHERE Preparation = 'Done' AND NameOfMedicine = med_name;
END//

DELIMITER //
CREATE PROCEDURE technology_inprogress()
BEGIN
	SELECT NameOfMedicine, TypeOfMedicine, Preparation, Component, CountOfComponent, OrderStatus
    FROM (recipes r JOIN orderbook o ON r.idRecipe = o.idOrder) JOIN
    (guideofpreparation g JOIN (componentinmedicine i JOIN storagecomponent s ON i.idComponent = s.idComponent) ON g.ID=i.idMedicine)
    ON r.Medicine = g.NameOfMedicine
    WHERE OrderStatus = 'InProgress'
	UNION
	SELECT NameOfMedicine, TypeOfMedicine, Preparation, '', '', OrderStatus
    FROM (recipes r JOIN orderbook o ON r.idRecipe = o.idOrder) JOIN guideofpreparation g ON r.Medicine = g.NameOfMedicine
    WHERE OrderStatus = 'InProgress' AND Preparation = 'Done';
END//

CALL technology_type('ointment');
CALL technology_name('Korvalol');
CALL technology_inprogress();