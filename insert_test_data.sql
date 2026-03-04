-- Должники
INSERT INTO debtor (full_name, passport_series, passport_number, phone, contact_phone, address) VALUES
('Сидоров Сидор', '1234', '567890123', '79123456789', '79234567890', 'ул. Чехова, 3'),
('Кузнецова Анна', '4321', '098765432', '79876543210', '79987654321', 'ул. Толстого, 4');

-- Услуги
INSERT INTO service_price (amount, additional_info) VALUES
(1000.0, 'Консультация'),
(10000.0, 'Судебное взыскание (базовый тариф)'),
(5000.0, 'Выезд к должнику');

-- Отделения (без начальников)
INSERT INTO department (address, phone, additional_info) VALUES
('ул. Ленина, 10', '12345678901', 'Центральный офис'),
('ул. Гагарина, 5', '10987654321', 'Филиал на юге');

-- Роли сотрудников
INSERT INTO role (role_code, title) VALUES
(1001, 'Администратор'),
(1002, 'Коллектор'),
(1003, 'Менеджер'),
(1004, 'Бухгалтер');

-- Сотрудники
INSERT INTO employee (full_name, hire_date, fire_date, role_code, admin_hire_id, admin_fire_id, department_id, is_active) VALUES
('Иванов Иван', '2025-01-10', NULL, 1001, NULL, NULL, 1, TRUE);

UPDATE employee SET admin_hire_id = 1 WHERE employee_id = 1; -- принял себя, а нужно было таблетки

INSERT INTO employee (full_name, hire_date, fire_date, role_code, admin_hire_id, admin_fire_id, department_id, is_active) VALUES
('Петров Петр', '2025-03-15', NULL, 1002, 1, NULL, 2, TRUE),
('Серый Сергей', '2025-01-12', NULL, 1003, 1, NULL, 1, TRUE),
('Белый Алексей', '2025-01-01', NULL, 1004, 1, NULL, 1, TRUE);

-- Начальник отделения
UPDATE department SET head_employee_id = 2 WHERE department_id = 1;

-- Услуги сотрудников
INSERT INTO employee_price (employee_id, service_code) VALUES
(2, 1),
(2, 2);

-- Клиенты
INSERT INTO client (client_name, phone, address, inn, department_id) VALUES
('ООО "Ромашка"', '71112223344', 'ул. Пушкина, 1', '123456789012', 1),
('ЗАО "Тюльпан"', '72223334455', 'ул. Лермонтова, 2', '210987654321', 2);

-- Услуги коллекторов
INSERT INTO collector_service (service_name, description) VALUES
('звонок другу', 'милый телефонный разговор с должником'),
('письмо', 'письменное уведолмение о сумме долга'),
('выезд',  'визит коллектора к должнику');

-- Стимулирующие мероприятий
INSERT INTO stimulating_activity (activity_date, manager_id) VALUES
('2026-01-12', 3);

-- Услуги как мероприятия
INSERT INTO activity_service (activity_id, service_name, success_flag) VALUES
(1, 'звонок другу', TRUE),
(1, 'письмо', FALSE);

-- Мероприятия сотрудника
INSERT INTO employee_service (activity_id, employee_id) VALUES
(1, 2);

-- Договоры
INSERT INTO contract (contract_number, debt_amount, agency_fee_pct, resp_manager_id, debtor_id) VALUES
('Д-001', 40000.00, 10.0, 3, 1),
('Д-002', 20000.00, 12.5, 3, 2);


-- Входящие платёжные документы
INSERT INTO incoming_payment_document (amount, payment_date, accountant_id, contract_number) VALUES
(20000.00, '2025-06-15', 4, 'Д-001'),
(30000.00, '2025-07-20', 4, 'Д-001'),
(30000.00, '2025-08-14', 4, 'Д-002');

-- Исходящие платёжные документы
INSERT INTO outgoing_payment_document (doc_type, rec_client_id, rec_employee_id, date, amount, base_doc, accountant_id, contract_number) VALUES
('to_client', 1, NULL, '2025-06-16', 18000.00, 'Акт1', 2, 'Д-001'),
('to_employee', NULL, 2, '2025-07-21', 26250.00, 'Акт2', 1, 'Д-002');


-- Планы выплат
INSERT INTO payment_plan (contract_number, due_date, amount, penalty_flag, payment_doc_id, paid_flag, employee_id) VALUES
('Д-001', '2025-06-10', 50000.00, FALSE, 1, TRUE, 3),
('Д-002', '2025-08-15', 30000.00, FALSE, 3, TRUE, 3);

INSERT INTO employee_ipd (ipd_doc_id, employee_id) VALUES
(1, 4),
(2, 4),
(3, 4);
