USE Pharmacy;
DROP TRIGGER IF EXISTS sale_medicine;
DROP TRIGGER IF EXISTS sale_component;
DROP TRIGGER IF EXISTS supply_medicine;
DROP TRIGGER IF EXISTS add_to_ledger ;
DROP TRIGGER IF EXISTS write_off ;
DROP PROCEDURE IF EXISTS clean_up;
DROP PROCEDURE IF EXISTS upd_orderbook;
DROP PROCEDURE IF EXISTS check_storage;

DELIMITER //
CREATE TRIGGER sale_medicine AFTER UPDATE ON storagemedicine
FOR EACH ROW
BEGIN
	IF new.Count <= new.CriticalCount THEN 
		INSERT INTO requestformedicine(NameOfMedicine, Count) VALUES(new.NameOfMedicine, new.CriticalCount*5);
	END IF;
END//

DELIMITER //
CREATE TRIGGER sale_component AFTER UPDATE ON storagecomponent
FOR EACH ROW
BEGIN
	IF new.Count <= new.CriticalCount THEN
		INSERT INTO requestformedicine(NameOfMedicine, Count) VALUES(new.Component, new.CriticalCount*3);
	END IF;
END//

DELIMITER //
CREATE TRIGGER supply_medicine AFTER DELETE ON requestformedicine
FOR EACH ROW
BEGIN
	UPDATE storagemedicine SET Count = Count + old.Count WHERE NameOfMedicine = old.NameOfMedicine;
    UPDATE storagecomponent SET Count = Count + old.Count WHERE Component = old.NameOfMedicine;
    UPDATE storagemedicine SET ShelfLife = DATE_ADD(ShelfLife, INTERVAL 5 YEAR) WHERE NameOfMedicine = old.NameOfMedicine;
    UPDATE storagecomponent SET ShelfLife = DATE_ADD(ShelfLife, INTERVAL 5 YEAR) WHERE Component = old.NameOfMedicine;
    
END//

DELIMITER //
CREATE TRIGGER add_to_ledger AFTER insert ON recipes
FOR EACH ROW
	BEGIN       
    IF new.Medicine = (SELECT Medicine FROM ledger WHERE ledger.Medicine = new.Medicine) THEN 
		UPDATE ledger 
        SET Sales = Sales + new.CountOfMedicine 
        WHERE Medicine = new.Medicine;
        
	ELSE 
		INSERT INTO ledger VALUES (new.Medicine, new.CountOfMedicine);
    END IF;
END//

DELIMITER //
CREATE TRIGGER write_off BEFORE insert ON recipes
FOR EACH ROW
	BEGIN   
    IF new.Seal='true' THEN
    IF new.Medicine = (SELECT NameOfMedicine FROM storagemedicine WHERE NameOfMedicine = new.Medicine) THEN
		IF new.CountOfMedicine <= (SELECT Count FROM storagemedicine WHERE NameOfMedicine = new.Medicine) THEN
			SET new.DateToBack = DATE_ADD(new.RecipeDate,INTERVAL (SELECT TimeOfPreparation FROM guideofpreparation WHERE NameOfMedicine=new.Medicine) DAY);
			UPDATE storagemedicine SET Count = Count - new.CountOfMedicine WHERE NameOfMedicine = new.Medicine;
            INSERT INTO orderbook(idOrder, FullName) VALUES(new.idRecipe, new.PatientFullName);
		ELSE 
			SET new.DateToBack = DATE_ADD(new.RecipeDate,INTERVAL (SELECT TimeOfPreparation FROM guideofpreparation WHERE NameOfMedicine=new.Medicine) + 20 DAY);
			INSERT INTO orderbook(idOrder, FullName, OrderStatus) VALUES(new.idRecipe, new.PatientFullName,'WaitForComponent');
			INSERT INTO requestformedicine(NameOfMedicine, Count) VALUES(new.Medicine, new.CountOfMedicine);
		END IF;
	ELSE
		IF 	0 > ANY(SELECT Count - CountOfComponent*new.CountOfMedicine FROM 
			storagecomponent s JOIN componentinmedicine c ON s.idComponent=c.idComponent
            JOIN guideofpreparation g ON g.ID=c.idMedicine WHERE g.NameOfMedicine=new.Medicine AND Count - CountOfComponent*new.CountOfMedicine<0) THEN
			
			SET new.DateToBack = DATE_ADD(new.RecipeDate, INTERVAL (SELECT TimeOfPreparation FROM guideofpreparation WHERE NameOfMedicine=new.Medicine) + 25 DAY);
			INSERT INTO orderbook(idOrder, FullName, OrderStatus) VALUES(new.idRecipe, new.PatientFullName,'WaitForComponent');
			INSERT INTO requestformedicine(NameOfMedicine, Count) SELECT Component, CountOfComponent*new.CountOfMedicine 
            FROM (storagecomponent s JOIN componentinmedicine c ON s.idComponent = c.idComponent) JOIN guideofpreparation g ON g.ID=c.idMedicine 
            WHERE Count - CountOfComponent*new.CountOfMedicine <0 AND NameOfMedicine = new.Medicine;
        ELSE 
            SET new.DateToBack = DATE_ADD(new.RecipeDate,INTERVAL (SELECT TimeOfPreparation FROM guideofpreparation WHERE NameOfMedicine=new.Medicine) DAY);
            UPDATE storagecomponent, componentinmedicine, guideofpreparation
            SET storagecomponent.Count  = storagecomponent.Count - componentinmedicine.CountOfComponent*new.CountOfMedicine
            WHERE guideofpreparation.NameOfMedicine=new.Medicine AND componentinmedicine.idMedicine=guideofpreparation.ID AND storagecomponent.idComponent=componentinmedicine.idComponent;
			INSERT INTO orderbook(idOrder, FullName) VALUES(new.idRecipe, new.PatientFullName);
        END IF;
	END IF;
    END IF;
END//

DELIMITER $$
CREATE PROCEDURE clean_up()
BEGIN	
	DELETE FROM recipes WHERE Seal <> 'true';
    DELETE FROM recipes WHERE Medicine IN(SELECT NameOfMedicine FROM guideofpreparation WHERE TypeOfMedicine = 'ointment') AND (WayOfUsing<>'external');
	DELETE FROM recipes WHERE Medicine IN(SELECT NameOfMedicine FROM guideofpreparation WHERE TypeOfMedicine = 'mixture' OR TypeOfMedicine = 'powders') AND (WayOfUsing<>'internal');
    DELETE FROM recipes WHERE Medicine IN(SELECT NameOfMedicine FROM guideofpreparation WHERE TypeOfMedicine = 'solutions') AND (WayOfUsing<>'external')AND(WayOfUsing<>'internal')AND(WayOfUsing<>'mix');
END$$

CREATE PROCEDURE upd_orderbook()
BEGIN
	UPDATE orderbook, recipes SET orderbook.OrderStatus = 'Done' WHERE (recipes.DateToBack < current_date()) AND (orderbook.OrderStatus<>'Completed') AND (orderbook.idOrder = recipes.idRecipe);
    UPDATE orderbook, recipes SET orderbook.OrderStatus = 'InProgress' WHERE (recipes.DateToBack > current_date()) AND (orderbook.OrderStatus<>'Done')AND (orderbook.OrderStatus<>'WaitForComponent') AND (orderbook.idOrder = recipes.idRecipe);
END$$

CREATE PROCEDURE check_storage()
BEGIN
	UPDATE storagemedicine SET Count = 0 WHERE ShelfLife < current_date();
    UPDATE storagecomponent SET Count = 0 WHERE ShelfLife < current_date();
END$$
