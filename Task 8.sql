USE Pharmacy;
#Отримати повний перелік і загальне число замовлень знаходяться у виробництві.
SELECt * FROM orderbook;

DROP PROCEDURE IF EXISTS order_status;
DELIMITER //
CREATE PROCEDURE order_status(IN or_status VARCHAR(45))
BEGIN
	SELECT FullName, Phone, Adress FROM orderbook WHERE OrderStatus = or_status
	UNION
	SELECT 'Total Number:', '', COUNT(*) FROM orderbook WHERE OrderStatus = or_status;
END//

CALL order_status('InProgress');
