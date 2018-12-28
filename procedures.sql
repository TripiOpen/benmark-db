-- @author: do.nguyen@tripi.vn

CREATE TABLE IF NOT EXISTS `test` (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    value VARCHAR(255),
    time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) engine = InnoDB;

DELIMITER $$

DROP PROCEDURE IF EXISTS `benmark_insert` $$
CREATE DEFINER=`root`@`%` PROCEDURE `benmark_insert`()
BEGIN

  DECLARE x INTEGER;
  DECLARE value VARCHAR(255);
  DECLARE begin_time BIGINT;
  DECLARE end_time BIGINT;

  SET x = 1;
  SET value = 'test';
  SET begin_time = UNIX_TIMESTAMP(NOW(3)) * 1000;

  START TRANSACTION ;
  WHILE x < 1000000 DO
    INSERT INTO `test` (`value`) VALUE(value);
    SET  x = x + 1;
  END WHILE;
  COMMIT ;

  SET end_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
  SELECT (end_time - begin_time);

END $$

DELIMITER ;




DELIMITER $$

DROP PROCEDURE IF EXISTS `benmark_insert_batch` $$
CREATE DEFINER=`root`@`%` PROCEDURE `benmark_insert_batch`()
BEGIN

  DECLARE x INTEGER;
  DECLARE update_sql LONGTEXT;
  DECLARE begin_time BIGINT;
  DECLARE end_time BIGINT;
  DECLARE value VARCHAR(255);

  SET value = 'test';
  SET x = 1;
  SET update_sql = CONCAT('INSERT INTO test (value) VALUES (', '\'', value, '\'', ')');

  WHILE x < 1000000 DO
    SET update_sql = CONCAT(update_sql, ',(', '\'', value, '\'', ')');
    SET x = x + 1;
  END WHILE;
  SET update_sql = CONCAT(update_sql, ';');

  SET begin_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
  PREPARE stmt FROM update_sql;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
  SET end_time = UNIX_TIMESTAMP(NOW(3)) * 1000;
  SELECT (end_time - begin_time);

END $$

DELIMITER ;

CALL benmark_insert();
CALL benmark_insert_batch();
