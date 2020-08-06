USE Pharmacy;
#Отримати повний перелік і загальне число препаратів потрібних для замовлень, що знаходяться у виробництві.
DROP PROCEDURE IF EXISTS request_med_inprogress;
DELIMITER //
CREATE PROCEDURE request_med_inprogress()
BEGIN
	SELECT NameOfMedicine, OrderStatus FROM requestformedicine r JOIN orderbook o ON r.idRequest = o.idOrder 
    WHERE OrderStatus = 'InProgress'
    UNION
    SELECT 'Total Number:', COUNT(*) FROM requestformedicine r JOIN orderbook o ON r.idRequest = o.idOrder 
    WHERE OrderStatus = 'InProgress';
END//

CALL request_med_inprogress();