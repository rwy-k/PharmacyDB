USE Pharmacy;
#Отримати перелік ліків з мінімальним запасом на складі в цілому і по вказаній категорії медикаментів.
DROP PROCEDURE IF EXISTS min_count_med;
DROP PROCEDURE IF EXISTS min_count_component;
DROP PROCEDURE IF EXISTS min_count_med_category;

DELIMITER //
CREATE PROCEDURE min_count_component()
BEGIN 
	SELECT Component, Count FROM storagecomponent WHERE (Count = (SELECT MIN(Count) FROM storagecomponent));
END//

DELIMITER //
CREATE PROCEDURE min_count_med()
BEGIN 
	SELECT NameOfMedicine, Count FROM storagemedicine WHERE (Count = (SELECT MIN(Count) FROM storagemedicine));
END//

DELIMITER //
CREATE PROCEDURE min_count_med_category(IN med_type VARCHAR(45))
BEGIN
	DECLARE min INT;
    SET min = (SELECT MIN(Count) FROM storagemedicine s JOIN guideofpreparation g ON s.NameOfMedicine = g.NameOfMedicine WHERE  (TypeOfMedicine = med_type));
	SELECT s.NameOfMedicine, TypeOfMedicine, Count FROM storagemedicine s JOIN guideofpreparation g ON s.NameOfMedicine = g.NameOfMedicine
    WHERE (Count = min) AND (TypeOfMedicine = med_type);
END//

CALL min_count_component();
CALL min_count_med();
CALL min_count_med_category('tablets');
