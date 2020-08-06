USE Pharmacy;
#Отримати відомості замовлення клієнтів, які найчастіші виготовляються, на медикаменти певного типу, на конкретні медикаменти. 
DROP PROCEDURE IF EXISTS top_orders;
DROP PROCEDURE IF EXISTS order_of_type;
DROP PROCEDURE IF EXISTS order_of_med;

DELIMITER //
CREATE PROCEDURE top_orders()
BEGIN
	DECLARE max, min, count INT;
    SELECT COUNT(FullName) INTO max FROM orderbook GROUP BY FullName ORDER BY COUNT(FullName) DESC limit 1;
    SELECT COUNT(FullName) INTO min FROM orderbook GROUP BY FullName ORDER BY COUNT(FullName) limit 1;
    SET count = (min + max) / 2;
	SELECT *, COUNT(FullName) AS 'Count Of Orders' FROM orderbook 
    GROUP BY FullName HAVING COUNT(FullName) >= count
    ORDER BY COUNT(FullName) DESC;
END//

DELIMITER //
CREATE PROCEDURE order_of_type(IN med_type VARCHAR(45))
BEGIN
	SELECT idOrder, FullName, Phone, Adress, Medicine, OrderStatus FROM orderbook o JOIN (recipes r JOIN guideofpreparation g ON r.Medicine = g.NameOfMedicine) ON o.idOrder=r.idRecipe
    WHERE TypeOfMedicine = med_type;
END//

DELIMITER //
CREATE PROCEDURE order_of_med(IN med VARCHAR(45))
BEGIN
	SELECT idOrder, FullName, Phone, Adress, Medicine, OrderStatus FROM orderbook o JOIN recipes r ON o.idOrder=r.idRecipe
    WHERE Medicine = med;
END//

#INSERT INTO orderbook VALUES (9, 'Frank Sinatra', 452368, 'Karantine st. 3', 'Done');
CALL top_orders();
CALL order_of_type('ointment');
CALL order_of_med('Korvalol');