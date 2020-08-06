USE Pharmacy;
#Отримати який обсяг зазначених речовин використаний за вказаний період. 
SELECT RecipeDate, Component FROM (recipes r JOIN guideofpreparation g ON r.Medicine = g.NameOfMedicine) JOIN 
								(componentinmedicine i JOIN storagecomponent s ON s.idComponent = i.idComponent) ON i.idMedicine=g.ID;
DROP PROCEDURE IF EXISTS count_of_medicine;
DELIMITER //
CREATE PROCEDURE count_of_medicine (IN comp VARCHAR(45), IN date1 DATE, IN date2 DATE)
BEGIN
	DECLARE id_comp INT;
    SELECT idComponent INTO id_comp FROM StorageComponent WHERE Component = comp;
    
	SELECT sum(c.CountOfComponent * r.CountOfMedicine) as 'COUNT'
    FROM (componentinmedicine c JOIN guideofpreparation g on c.idMedicine = g.ID) JOIN recipes r ON r.Medicine = g.NameOfMedicine
    WHERE (r.RecipeDate BETWEEN date1 AND date2) AND (c.idComponent = id_comp);
    
END//

CALL count_of_medicine('Nimesulid','2005-04-20', '2029-04-20');
