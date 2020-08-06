USE Pharmacy;
#Отримати перелік і загальне число покупців, які замовляли певні ліки або певні типи ліків за даний період. 
DROP PROCEDURE IF EXISTS patients_list_medicine;
DROP PROCEDURE IF EXISTS patients_list_type;

DELIMITER //
CREATE PROCEDURE patients_list_medicine (IN med VARCHAR(45), IN date1 DATE, IN date2 DATE)
BEGIN
	SELECT PatientFullName, RecipeDate, Medicine FROM recipes WHERE (RecipeDate BETWEEN date1 AND date2) AND (Medicine = med)
    UNION 
    SELECT 'Total number:', '', COUNT(*) FROM recipes WHERE (RecipeDate BETWEEN date1 AND date2) AND (Medicine = med);
END//

CREATE PROCEDURE patients_list_type (IN med_type VARCHAR(45), IN date1 DATE, IN date2 DATE)
BEGIN
	SELECT PatientFullName, RecipeDate, TypeOfMedicine FROM (recipes r JOIN guideofpreparation g ON r.Medicine = g.NameOfMedicine) WHERE (r.RecipeDate BETWEEN date1 AND date2) AND (TypeOfMedicine = med_type)
    UNION 
    SELECT 'Total number:', '', COUNT(*) FROM recipes r JOIN guideofpreparation g ON r.Medicine = g.NameOfMedicine WHERE (r.RecipeDate BETWEEN date1 AND date2) AND (TypeOfMedicine = med_type);
END//

CALL patients_list_medicine('Fastum', '2020-03-20' , '2020-04-20');
CALL patients_list_type('tablets', '2020-03-20' , '2020-04-20');
