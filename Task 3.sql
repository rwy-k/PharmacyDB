USE Pharmacy;
#Отримати перелік десяти найбільш часто використовуваних медикаментів в цілому і зазначеної категорії медикаментів. 

DROP PROCEDURE IF EXISTS top_medicine;
DELIMITER //
CREATE PROCEDURE top_medicine(IN category VARCHAR(45))
BEGIN
	SELECT Medicine, Sales from ledger, GuideOfPreparation
    WHERE GuideOfPreparation.TypeOfMedicine = category AND GuideOfPreparation.NameOfMedicine = ledger.Medicine
    order by Sales DESC limit 10;
    
    SELECT * from ledger order by Sales DESC limit 10;
END//

CALL top_medicine('ointment');
