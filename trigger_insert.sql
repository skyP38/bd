-- Триггер 1

-- 1. + вставка услуги (не звонок) в допустимое время, лимиты не превышены
BEGIN;

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-20 10:00:00', 2, 1);

INSERT INTO activity_service (activity_id, service_name, success_flag)
VALUES (lastval(), 'письмо', TRUE);

COMMIT;

-- select * from stimulating_activity where activity_date = '2026-03-20 10:00:00';
 activity_id |    activity_date    | manager_id | debtor_id
-------------+---------------------+------------+-----------
          35 | 2026-03-20 10:00:00 |          2 |         1
(1 row)
-- select * from activity_service where activity_id = 35;
 activity_id | service_name | success_flag
-------------+--------------+--------------
          35 | письмо       | t
(1 row)



-- 2. + звонок в разрешённое время
BEGIN;

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-20 14:00:00', 2, 1);

INSERT INTO activity_service (activity_id, service_name, success_flag)
VALUES (lastval(), 'звонок другу', TRUE);

COMMIT;

-- select * from stimulating_activity where activity_date = '2026-03-20 14:00:00';
 activity_id |    activity_date    | manager_id | debtor_id
-------------+---------------------+------------+-----------
          36 | 2026-03-20 14:00:00 |          2 |         1
(1 row)
-- select * from activity_service where activity_id = 36;
 activity_id | service_name | success_flag
-------------+--------------+--------------
          36 | звонок другу | t
(1 row)



-- 3. - звонок ночью
BEGIN;

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-20 23:30:00', 2, 6);

INSERT INTO activity_service (activity_id, service_name, success_flag)
VALUES (lastval(), 'звонок другу', TRUE);

COMMIT;

ERROR:  Service "звонок другу" could not be added from 21:00 to 7:00. Current time of service: 2026-03-20 23:30:00



-- 4. - превышение общего количества мероприятий
BEGIN;

-- 3 мероприятия с услугами
INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-17 10:00:00', 2, 7);
INSERT INTO activity_service (activity_id, service_name, success_flag)
VALUES (lastval(), 'письмо', TRUE);

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-18 11:00:00', 2, 7);
INSERT INTO activity_service (activity_id, service_name, success_flag)
VALUES (lastval(), 'выезд', TRUE);

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-22 09:00:00', 2, 7);
INSERT INTO activity_service (activity_id, service_name, success_flag)
VALUES (lastval(), 'СМС-уведомление', TRUE);

-- 4 мероприятие
INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-20 12:00:00', 2, 7);
INSERT INTO activity_service (activity_id, service_name, success_flag)
VALUES (lastval(), 'Звонок родственникам', TRUE);

COMMIT;

ERROR:  For debtor 7 there are already such activity СМС-уведомление in 2026-03-18 09:00:00 2026-03-26 09:00:00



-- 5. - дублирование услуги
BEGIN;

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-18 10:00:00', 2, 8);
INSERT INTO activity_service (activity_id, service_name, success_flag)
VALUES (lastval(), 'выезд', TRUE);

INSERT INTO stimulating_activity (activity_date, manager_id, debtor_id)
VALUES ('2026-03-20 12:00:00', 2, 8);

INSERT INTO activity_service (activity_id, service_name, success_flag)
VALUES (lastval(), 'выезд', TRUE);

COMMIT;

ERROR:  For debtor 8 there are already such activity выезд in 2026-03-16 12:00:00 2026-03-24 12:00:00







-- Триггер 2
INSERT INTO incoming_payment_document (amount, payment_date, accountant_id, contract_number)
VALUES (50000.00, '2026-03-20', 4, 'Д-001');
-- INSERT INTO payment_plan (contract_number, due_date, penalty_flag, paid_flag, employee_id)
-- VALUES ('Д-001', '2025-06-10', FALSE, FALSE, 3);


-- 1. + установка payment_doc_id при допустимой сумме
INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-001', 'TEST1', 30000.00, '2026-03-25',
        (SELECT doc_id FROM incoming_payment_document WHERE amount = 50000 AND payment_date = '2026-03-20'));

-- select * from plan_detailed where plan_step = 'TEST1';
 contract_number | plan_step | amount | est_date |    date    | payment_doc_id
-----------------+-----------+--------+----------+------------+----------------
 Д-001           | TEST1     |  30000 |          | 2026-03-25 |             29
(1 row)



INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-001', 'TEST2', 20000.00, '2026-03-26', NULL);
-- 2. + обновление payment_doc_id с NULL на допустимое значение
UPDATE plan_detailed
SET payment_doc_id = (SELECT doc_id FROM incoming_payment_document WHERE amount = 50000 AND payment_date = '2026-03-20')
WHERE contract_number = 'Д-001' AND plan_step = 'TEST2';

-- select * from plan_detailed where plan_step = 'TEST2';
 contract_number | plan_step | amount | est_date |    date    | payment_doc_id
-----------------+-----------+--------+----------+------------+----------------
 Д-001           | TEST2     |  20000 |          | 2026-03-26 |             29
(1 row)



-- 3. - установка payment_doc_id на несуществующий документ
INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-001', 'TEST3', 10000.00, '2026-03-27', 99999);

ERROR:  Payment doc 99999 not found



INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-001', 'TEST4', 1.00, '2026-03-28',
        (SELECT doc_id FROM incoming_payment_document WHERE amount = 50000 AND payment_date = '2026-03-20'));
-- 4. - превышение суммы документа при добавлении новой строки
INSERT INTO plan_detailed (contract_number, plan_step, amount, date, payment_doc_id)
VALUES ('Д-001', 'TEST4', 1.00, '2026-03-28',
        (SELECT doc_id FROM incoming_payment_document WHERE amount = 50000 AND payment_date = '2026-03-20'));

ERROR:  Sum of all points of plan is greater than payment amount



-- 5. - превышение суммы при обновлении существующей строки
UPDATE plan_detailed
SET amount = 25000.00
WHERE contract_number = 'Д-001' AND plan_step = 'TEST2';

ERROR:  Sum of all points of plan is greater than payment amount



-- 6. - попытка изменить уже установленный payment_doc_id
UPDATE plan_detailed
SET payment_doc_id = 1
WHERE contract_number = 'Д-001' AND plan_step = 'TEST1';

ERROR:  Changes to the doc_id 29 are prohibited
