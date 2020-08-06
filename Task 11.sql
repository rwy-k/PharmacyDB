USE Pharmacy;
#Отримати відомості про ціни на вказані ліки в готовому вигляді, про обсяг і ціни на всі компоненти, потрібні для цих ліків. 
DROP PROCEDURE IF EXISTS med_price;
DELIMITER //
CREATE PROCEDURE med_price(IN med VARCHAR(45))
BEGIN
	IF med = (SELECT NameOfMedicine FROM storagemedicine WHERE NameOfMedicine = med) THEN 
		SELECT NameOfMedicine, Cost FROM storagemedicine WHERE NameOfMedicine = med;
	ELSE 
		SELECT Component, CountOfComponent, Cost
        FROM guideofpreparation g JOIN (storagecomponent s JOIN componentinmedicine i ON s.idComponent = i.idComponent) ON g.ID = i.idMedicine
        WHERE NameOfMedicine = med
        UNION
        SELECT CONCAT('**Total of ',NameOfMedicine),  SUM(CountOfComponent), SUM(Cost*CountOfComponent)
        FROM guideofpreparation g JOIN (storagecomponent s JOIN componentinmedicine i ON s.idComponent = i.idComponent) ON g.ID = i.idMedicine
        WHERE NameOfMedicine = med;
	END IF;
END//

CALL med_price('Korvalol');
CALL med_price('Barvoval');