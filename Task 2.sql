USE Pharmacy;
#Отримати перелік і загальне число покупців, які чекають прибуття на склад потрібних їм медикаментів в цілому і по вказаній категорії медикаментів. 
DELETE FROM mysql.proc WHERE db = 'pharmacy' AND type = 'PROCEDURE';
DELIMITER $$
CREATE PROCEDURE get_info_wait_order()
BEGIN
    SELECT FullName,Phone,Adress FROM orderbook WHERE OrderStatus = 'WaitForComponent'
    UNION 
    SELECT 'Count of patients:', '', COUNT(*) FROM orderbook WHERE OrderStatus = 'WaitForComponent';
END$$

DELIMITER $$
CREATE PROCEDURE get_info_wait_for_order(IN type_med VARCHAR(45))
BEGIN
    SELECT FullName,Phone,Adress FROM (orderbook o JOIN recipes r ON o.idOrder = r.idRecipe) JOIN guideofpreparation g on g.NameOfMedicine = r.Medicine
    WHERE OrderStatus = 'WaitForComponent' AND TypeOfMedicine = type_med
    UNION 
    SELECT 'Count of patients waiting', type_med, COUNT(*) FROM (orderbook o JOIN recipes r ON o.idOrder = r.idRecipe) JOIN guideofpreparation g on g.NameOfMedicine = r.Medicine
    WHERE OrderStatus = 'WaitForComponent' AND TypeOfMedicine = type_med;
END$$

CALL get_info_wait_order();
CALL get_info_wait_for_order('ointment');