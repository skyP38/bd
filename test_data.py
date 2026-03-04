import random
from datetime import date, timedelta
from faker import Faker
import psycopg2
from psycopg2.extras import execute_values

fake = Faker('ru_RU')

# Параметры подключения к БД
conn = psycopg2.connect(
    host='127.0.0.1',
    database='mydb',
    user='myuser'
    # password='1'
)
cur = conn.cursor()

# Очистка таблиц (если нужно пересоздать)
tables = [
    'employee_ipd',
    'payment_plan',
    'outgoing_payment_document',
    'incoming_payment_document',
    'activity_service',
    'stimulating_activity',
    'contract',
    'employee_service',
    'employee_price',
    'client',
    'employee',
    'department',
    'collector_service',
    'service_price',
    'role',
    'debtor'
]

for table in tables:
    cur.execute(f'TRUNCATE TABLE {table} RESTART IDENTITY CASCADE;')
conn.commit()

# Роли сотрудников
roles = [
    (1001, 'Администратор'),
    (1002, 'Коллектор'),
    (1003, 'Менеджер'),
    (1004, 'Бухгалтер')
]
execute_values(cur, "INSERT INTO role (role_code, title) VALUES %s", roles)

# Услуги
service_prices = [
    (1000.0, 'Консультация'),
    (10000.0, 'Судебное взыскание'),
    (5000.0, 'Выезд к должнику'),
    (2000.0, 'Звонок должнику')
]
execute_values(cur, "INSERT INTO service_price (amount, additional_info) VALUES %s", service_prices)

# Услуги коллекторов
collector_services = [
    ('звонок другу', 'Милый телефонный разговор с должником'),
    ('письмо', 'Письменное уведомление о долге'),
    ('выезд', 'Визит коллектора к должнику'),
    ('переговоры', 'Встреча с должником для обсуждения')
]
execute_values(cur, "INSERT INTO collector_service (service_name, description) VALUES %s", collector_services)

# Отделения – пока без начальников
departments = []
for _ in range(3):
    departments.append((
        fake.address().replace('\n', ', '),
        fake.phone_number()[:11],
        fake.text(max_nb_chars=50)
    ))
execute_values(cur, "INSERT INTO department (address, phone, additional_info) VALUES %s RETURNING department_id", departments)
dept_ids = [row[0] for row in cur.fetchall()]

# Сотрудники
employees_data = []
for i in range(20):
    hire_date = fake.date_between(start_date='-5y', end_date='today')
    fire_date = fake.date_between(start_date=hire_date, end_date='today') if random.random() < 0.2 else None
    role_code = random.choice([1001, 1002, 1003, 1004])
    employees_data.append((
        fake.name(),
        hire_date,
        fire_date,
        role_code,
        None,  # admin_hire_id
        None,  # admin_fire_id
        random.choice(dept_ids),
        True   # is_active
    ))

insert_emp_sql = """
    INSERT INTO employee
    (full_name, hire_date, fire_date, role_code, admin_hire_id, admin_fire_id, department_id, is_active)
    VALUES %s RETURNING employee_id
"""
execute_values(cur, insert_emp_sql, employees_data, page_size=100)
emp_ids = [row[0] for row in cur.fetchall()]

# Обновляем admin_hire_id и admin_fire_id
for eid in emp_ids:
    admin_hire = random.choice(emp_ids)
    admin_fire = None
    cur.execute("SELECT fire_date FROM employee WHERE employee_id = %s", (eid,))
    if cur.fetchone()[0] is not None:
        admin_fire = random.choice([i for i in emp_ids if i != eid])
    cur.execute("UPDATE employee SET admin_hire_id = %s, admin_fire_id = %s WHERE employee_id = %s",
                (admin_hire, admin_fire, eid))

# Назначаем начальников отделений
for dept_id in dept_ids:
    cur.execute("SELECT employee_id FROM employee WHERE department_id = %s ORDER BY random() LIMIT 1", (dept_id,))
    head = cur.fetchone()
    if head:
        cur.execute("UPDATE department SET head_employee_id = %s WHERE department_id = %s", (head[0], dept_id))

# Клиенты
clients = []
for _ in range(10):
    clients.append((
        fake.company(),
        fake.phone_number()[:11],
        fake.address().replace('\n', ', '),
        fake.phone_number()[:12],
        random.choice(dept_ids)
    ))
execute_values(cur, "INSERT INTO client (client_name, phone, address, inn, department_id) VALUES %s", clients)

# Должники 
debtors = []
for _ in range(15):
    passport_series = fake.bothify(text='####')
    passport_number = fake.bothify(text='#########')
    debtors.append((
        fake.name(),
        passport_series,
        passport_number,
        fake.phone_number()[:11],
        fake.phone_number()[:11],
        fake.address().replace('\n', ', ')
    ))
execute_values(cur, "INSERT INTO debtor (full_name, passport_series, passport_number, phone, contact_phone, address) VALUES %s", debtors)

# Договоры 
contracts = []
cur.execute("SELECT debtor_id FROM debtor")
debtor_ids = [row[0] for row in cur.fetchall()]
for i in range(20):
    contract_num = fake.bothify(text='Д-####??')
    start_date = fake.date_between(start_date='-3y', end_date='-1d')
    contracts.append((
        contract_num,
        round(random.uniform(10000, 200000), 2),
        round(random.uniform(5, 20), 1),
        random.choice(emp_ids),          # responsible_manager_id
        random.choice(debtor_ids)
    ))
execute_values(cur, """
    INSERT INTO contract
    (contract_number, debt_amount, agency_fee_pct, resp_manager_id, debtor_id)
    VALUES %s
""", contracts)

# Стимулирующие мероприятия
activities = []
for _ in range(8):
    activities.append((
        fake.date_between(start_date='-1y', end_date='+3m'),
        random.choice(emp_ids)             # manager_id
    ))
execute_values(cur, "INSERT INTO stimulating_activity (activity_date, manager_id) VALUES %s RETURNING activity_id", activities)
activity_ids = [row[0] for row in cur.fetchall()]

# Связь мероприятий с услугами коллекторов
activity_service_rows = []
cur.execute("SELECT service_name FROM collector_service")
service_names = [row[0] for row in cur.fetchall()]
for act_id in activity_ids:
    for _ in range(random.randint(1, 3)):
        activity_service_rows.append((
            act_id,
            random.choice(service_names),
            random.choice([True, False])   # success_flag
        ))

for act_id, svc, flag in activity_service_rows:
    cur.execute("""
            INSERT INTO activity_service (activity_id, service_name, success_flag)
            VALUES (%s, %s, %s)
            ON CONFLICT (activity_id, service_name) DO NOTHING
        """, (act_id, svc, flag))
                   
        
# Связь сотрудников с мероприятиями
emp_activity_rows = []
for act_id in activity_ids:
    participants = random.sample(emp_ids, random.randint(1, min(5, len(emp_ids))))
    for eid in participants:
        emp_activity_rows.append((act_id, eid))
execute_values(cur, "INSERT INTO employee_service (activity_id, employee_id) VALUES %s", emp_activity_rows)

# Входящие платёжные документы 
incoming_docs = []
cur.execute("SELECT contract_number FROM contract")
contract_nums = [row[0] for row in cur.fetchall()]
for _ in range(40):
    incoming_docs.append((
        round(random.uniform(1000, 50000), 2),
        fake.date_between(start_date='-1y', end_date='today'),
        random.choice(emp_ids),            # accountant_id
        random.choice(contract_nums)
    ))
execute_values(cur, """
    INSERT INTO incoming_payment_document (amount, payment_date, accountant_id, contract_number)
    VALUES %s RETURNING doc_id
""", incoming_docs)
incoming_ids = [row[0] for row in cur.fetchall()]

#  Исходящие платёжные документы
outgoing_docs = []
cur.execute("SELECT client_id FROM client")
client_ids = [row[0] for row in cur.fetchall()]
for _ in range(30):
    doc_type = random.choice(['to_client', 'to_employee'])
    if doc_type == 'to_client':
        rec_client = random.choice(client_ids)
        rec_employee = None
    else:
        rec_client = None
        rec_employee = random.choice(emp_ids)
    outgoing_docs.append((
        doc_type,
        rec_client,
        rec_employee,
        fake.date_between(start_date='-1y', end_date='today'),
        round(random.uniform(500, 100000), 2),
        fake.bothify(text='#####'),     # base_doc
        random.choice(emp_ids),            # accountant_id
        random.choice(contract_nums)
    ))
execute_values(cur, """
    INSERT INTO outgoing_payment_document
    (doc_type, rec_client_id, rec_employee_id, date, amount, base_doc, accountant_id, contract_number)
    VALUES %s
""", outgoing_docs)

# Планы выплат 
payment_plans = []
for contract_num in contract_nums:
    due_date = fake.date_between(start_date='-6m', end_date='+6m')
    amount = round(random.uniform(5000, 50000), 2)
    penalty_flag = random.choice([True, False])
    payment_doc = random.choice(incoming_ids) if random.random() < 0.7 else None
    paid_flag = payment_doc is not None
    employee_id = random.choice(emp_ids)
    payment_plans.append((
        contract_num,
        due_date,
        amount,
        penalty_flag,
        payment_doc,
        paid_flag,
        employee_id
    ))

execute_values(cur, """
    INSERT INTO payment_plan
    (contract_number, due_date, amount, penalty_flag,  payment_doc_id, paid_flag, employee_id)
    VALUES %s
""", payment_plans)

# Связь сотрудников с услугами
emp_price_rows = []
for eid in emp_ids:
    for sc in random.sample([1,2,3,4], random.randint(1, 3)):
        emp_price_rows.append((eid, sc))
execute_values(cur, "INSERT INTO employee_price (employee_id, service_code) VALUES %s", emp_price_rows)

# employee_ipd
emp_ipd_rows = []
for doc_id in random.sample(incoming_ids, min(20, len(incoming_ids))):
    for eid in random.sample(emp_ids, random.randint(1, 3)):
        emp_ipd_rows.append((doc_id, eid))
execute_values(cur, "INSERT INTO employee_ipd (ipd_doc_id, employee_id) VALUES %s", emp_ipd_rows)

conn.commit()
cur.close()
conn.close()
