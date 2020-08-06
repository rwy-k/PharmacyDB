USE Pharmacy;
#Отримати відомості про покупців, які не прийшли забрати своє замовлення в призначений їм час і загальне їх число. 
DROP PROCEDURE IF EXISTS get_info_done_order;
DELIMITER $$
CREATE PROCEDURE get_info_done_order()
BEGIN
    SELECT FullName,Phone,Adress FROM orderbook WHERE OrderStatus = 'Done'
	UNION
    SELECT 'Count Of Patients:', '', COUNT(*) as 'Count of DONE' FROM orderbook WHERE OrderStatus = 'Done';
END$$

CALL get_info_done_order();
