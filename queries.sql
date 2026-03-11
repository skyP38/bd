-- 1. Получить отчёт по клиентам, выводя информацию о них в порядке возрастания кол-ва заключенных договоров и в порядке убывания суммарной награды для агентства в виде:
-- Название фирмы-клиента; телефон фирмы-клиента; суммарная награда для агентства; суммарный переданный долг; кол-во заключенных договоров.

-- Клиент + договор, если клиент не заключал договора - 0
-- агрегация по клиентам
WITH client_cnt AS (
    SELECT
        client_id,
        COUNT(*) AS cnts,
        SUM (debt_amount) AS total_debt,
        SUM(debt_amount * agency_fee_pct / 100) AS total_reward
    FROM contract
    GROUP BY  client_id
)
SELECT
    -- Название фирмы-клиента;
    c.client_name AS client,

    -- телефон фирмы-клиента;
    c.phone AS phone,

    -- суммарная награда для агентства;
    COALESCE(cc.total_reward, 0) AS reward,

    -- суммарный переданный долг;
    COALESCE(cc.total_debt, 0) AS debt,

    -- кол-во заключенных договоров.
    cc.cnts AS contracts
FROM client c
LEFT JOIN client_cnt cc ON c.client_id = cc.client_id
GROUP BY c.client_name, c.phone, cc.total_reward, cc.total_debt, cc.cnts
ORDER BY contracts ASC, reward DESC;

     client      |    phone    | reward |  debt  | contracts
-----------------+-------------+--------+--------+-----------
 ЗАО "Пион"      | 79990001122 |   9600 |  80000 |         1
 ООО "Василёк"   | 73334445566 |  22500 | 210000 |         2
 ЗАО "Фиалка"    | 76667778899 |  21800 | 165000 |         2
 ООО "Одуванчик" | 74445556677 |  16450 | 135000 |         2
 ООО "Ромашка-2" | 75556667788 |  11600 | 125000 |         2
 ИП "Кактус"     | 77778889900 |  11250 |  75000 |         2
 ООО "Орхидея"   | 78889990011 |  10900 | 100000 |         2
 ЗАО "Тюльпан"   | 72223334455 |  74280 | 562000 |        11
 ООО "Ромашка"   | 71112223344 |  81225 | 780000 |        12
 ОАО "Роза"      | 73333334455 |      0 |      0 |
(10 rows)



-- 2. Получить отчёт об успешности стимулирующих мероприятий по всем отделениям в виде:
-- Адрес отделения; телефон отделения; название стимулирующего мероприятия; кол-во успешно выполненных; кол-во выполненных; коэффициент успешности (отношение успешных ко всем выполненным).
-- стимулирующее меропрития + услуга как мероприятие + мероприятие сотрудника + сотрудник + отделения

-- агрегация по стимулирующим мероприятиям и услугам
WITH activity_success AS (
    SELECT
        sa.activity_id,
        sa.manager_id,
        COUNT(*) AS total_services,
        SUM(acs.success_flag::int) AS successful,
        ROUND(AVG(acs.success_flag::int), 2) AS success_factor
    FROM stimulating_activity sa
    JOIN activity_service acs ON sa.activity_id = acs.activity_id
    GROUP BY sa.activity_id, sa.manager_id
)
SELECT
    -- Адрес отделения;
    d.address,

    -- телефон отделения;
    d.phone,

    -- название стимулирующего мероприятия; (название нет, поэтому id)
    ac.activity_id AS "stimulating activity",

    -- кол-во успешно выполненных;
    ac.successful AS "successfully completed",

    -- кол-во выполненных;
    ac.total_services AS completed,

    -- коэффициент успешности
    ac.success_factor AS "success factor"
FROM activity_success ac
JOIN employee e ON e.employee_id = ac.manager_id
JOIN department d ON d.department_id = e.department_id
GROUP BY d.address, d.phone, ac.activity_id, ac.successful, ac.total_services, ac.success_factor;

     address     |    phone    | stimulating activity | successfully completed | completed | success factor
-----------------+-------------+----------------------+------------------------+-----------+----------------
 ул. Ленина, 10  | 12345678901 |                    5 |                      6 |        10 |           0.60
 ул. Гагарина, 5 | 10987654321 |                    6 |                      1 |         6 |           0.17
 ул. Ленина, 10  | 12345678901 |                    7 |                      6 |         7 |           0.86
 ул. Ленина, 10  | 12345678901 |                    1 |                      4 |         5 |           0.80
 ул. Ленина, 10  | 12345678901 |                    9 |                      3 |         4 |           0.75
 ул. Ленина, 10  | 12345678901 |                   11 |                      1 |         1 |           1.00
 ул. Ленина, 10  | 12345678901 |                    3 |                      1 |         3 |           0.33
 ул. Гагарина, 5 | 10987654321 |                   10 |                      1 |         2 |           0.50
 ул. Гагарина, 5 | 10987654321 |                    4 |                      5 |         9 |           0.56
 ул. Гагарина, 5 | 10987654321 |                    8 |                      5 |         6 |           0.83
 ул. Ленина, 10  | 12345678901 |                   13 |                      1 |         1 |           1.00
 ул. Гагарина, 5 | 10987654321 |                    2 |                      2 |         2 |           1.00
 ул. Гагарина, 5 | 10987654321 |                   12 |                      1 |         3 |           0.33
(13 rows)


-- 3. Получить отчет по финансам с середины прошлого года по месяцам. Отчет должен содержать строки по числу месяцев:
-- Название месяца и год строкой; сумма неоплаченных договоров на начало месяца; сумма оплаченных договоров на начало месяца; общая сумма договоров на начало месяца; количество и сумма новых договоров за месяц; количество и сумма входящих платежей за месяц; количество и сумма исходящих платежей за месяц; сумма неоплаченных договоров на конец месяца; прибыль за месяц (сумма входящих – сумма исходящих);

-- договор + план выплат + детали плана + оплата долга + впд + ипд

-- месяца с середины прошлого года
WITH months AS (
    SELECT generate_series(
        date_trunc('month', make_date(EXTRACT(YEAR FROM CURRENT_DATE)::INT - 1, 7, 1)),
        date_trunc('month', CURRENT_DATE),
        '1 month'
    )::date AS month_start
),
-- конец месяцев
month_detail AS (
    SELECT month_start,
           (month_start + INTERVAL '1 month' - INTERVAL '1 day')::date AS month_end
    FROM months
)
SELECT
    TO_CHAR(md.month_start, 'YYYY-MM') AS "YYYY-MM",

    -- сумма неоплаченных договоров на начало месяца - оплаченная часть
    (
        SELECT SUM(cnt.debt_amount - COALESCE(ip.sum_in, 0))
        FROM contract cnt
        LEFT JOIN (
            SELECT contract_number, SUM(amount) AS sum_in
            FROM incoming_payment_document
            WHERE payment_date < md.month_start
            GROUP BY contract_number
        ) ip ON cnt.contract_number = ip.contract_number
        LEFT JOIN payment_plan pp ON cnt.contract_number = pp.contract_number
        WHERE cnt.date < md.month_start
            AND pp.paid_flag = FALSE
            AND (cnt.debt_amount - COALESCE(ip.sum_in, 0)) > 0
    ) AS "unpaid cnt",

    -- сумма оплаченных договоров на начало месяца;
    (
        SELECT SUM(cnt.debt_amount)
        FROM contract cnt
        LEFT JOIN payment_plan pp ON cnt.contract_number = pp.contract_number
        WHERE cnt.date < md.month_start
            AND pp.paid_flag = TRUE
    ) AS "paid cnt",

    -- общая сумма договоров на начало месяца;
    (
        SELECT SUM(debt_amount)
        FROM contract cnt
        WHERE date < md.month_start
    ) AS "all cnt",

    -- количество и сумма новых договоров за месяц;
    (
        SELECT COUNT(*)
        FROM contract
        WHERE date BETWEEN md.month_start AND md.month_end
    ) AS "nmb cnt/month",
    COALESCE ((
        SELECT SUM(debt_amount)
        FROM contract
        WHERE date BETWEEN md.month_start AND md.month_end
    ), 0) AS "amt cnt/month",

    -- количество и сумма входящих платежей за месяц;
    (
        SELECT COUNT(*)
        FROM incoming_payment_document
        WHERE payment_date BETWEEN md.month_start AND md.month_end
    ) AS "nmb ipd/month",
    COALESCE ((
        SELECT SUM(amount)
        FROM incoming_payment_document
        WHERE payment_date BETWEEN md.month_start AND md.month_end
    ), 0) AS "amt ipd/month",

    -- количество и сумма исходящих платежей за месяц;
    (
        SELECT COUNT(*)
        FROM outgoing_payment_document
        WHERE payment_date BETWEEN md.month_start AND md.month_end
    ) AS "nmb opd/month",
    COALESCE ((
        SELECT SUM(amount)
        FROM outgoing_payment_document
        WHERE payment_date BETWEEN md.month_start AND md.month_end
    ), 0) AS "amt opd/month",

    -- сумма неоплаченных договоров на конец месяца;
    (
        SELECT SUM(cnt.debt_amount - COALESCE(ip.sum_in, 0))
        FROM contract cnt
        LEFT JOIN (
            SELECT contract_number, SUM(amount) AS sum_in
            FROM incoming_payment_document
            WHERE payment_date <= md.month_end
            GROUP BY contract_number
        ) ip ON cnt.contract_number = ip.contract_number
        LEFT JOIN payment_plan pp ON cnt.contract_number = pp.contract_number
        WHERE cnt.date < md.month_start
            AND pp.paid_flag = FALSE
            AND (cnt.debt_amount - COALESCE(ip.sum_in, 0)) > 0
    ) AS "unpaid cnt m end",

    -- прибыль за месяц (сумма входящих – сумма исходящих);
    COALESCE ((
        SELECT SUM(ipd.amount)
        FROM incoming_payment_document ipd
        WHERE payment_date BETWEEN md.month_start AND md.month_end
    ), 0)
    -
    COALESCE ((
        SELECT SUM(opd.amount)
        FROM outgoing_payment_document opd
        WHERE payment_date BETWEEN md.month_start AND md.month_end
    ), 0) AS "monthly profit"
FROM month_detail md
ORDER BY md.month_start;

 YYYY-MM | unpaid cnt | paid cnt |  all cnt  | nmb cnt/month | amt cnt/month | nmb ipd/month | amt ipd/month | nmb opd/month | amt opd/month | unpaid cnt m end | monthly profit
---------+------------+----------+-----------+---------------+---------------+---------------+---------------+---------------+---------------+------------------+----------------
 2025-07 |     452500 |    60000 |    565000 |             2 |        150000 |             4 |         63300 |             3 |         38250 |           439200 |          25050
 2025-08 |     569200 |    60000 |    715000 |             1 |         45000 |             4 |         98000 |             3 |         52600 |           501200 |          45400
 2025-09 |     546200 |    60000 |    760000 |             2 |         85000 |             3 |         82000 |             3 |         80900 |           514200 |           1100
 2025-10 |     549200 |   110000 |    845000 |             1 |        120000 |             2 |         18600 |             3 |         35140 |           530600 |         -16540
 2025-11 |     650600 |   110000 |    965000 |             2 |        115000 |             2 |         19000 |             1 |          9000 |           641600 |          10000
 2025-12 |     746600 |   110000 |  1.08e+06 |             0 |             0 |             2 |         35000 |             3 |         26600 |           711600 |           8400
 2026-01 |     711600 |   110000 |  1.08e+06 |             2 |        245000 |             1 |          6000 |             1 |          5400 |           705600 |            600
 2026-02 |     950600 |   110000 | 1.325e+06 |             2 |        115000 |             2 |         26000 |             2 |         23400 |           924600 |           2600
 2026-03 | 1.0396e+06 |   110000 |  1.44e+06 |            12 |        792000 |             3 |         18000 |             3 |         16200 |       1.0216e+06 |           1800
(9 rows)


-- 4. Получить информацию о должниках, которые просрочили более 3 пунктов плана выплат. Отчет должен содержать:
-- ФИО должника; общую сумму долга; дата самой старой задолженности по пункту плана; сумму самой старой задолженности по пункту плана; количество и сумма неоплаченных задолженностей по плану; количество и сумма пунктов плана платежей, дата оплаты которых еще не истекла; % суммы долга, который должник оплатил; % суммы долга, который должник должен заплатить; % суммы долга, который должник должен заплатить и просрочил; % суммы долга, который должник должен заплатить и не просрочил.

-- должник + договор + план выплат + детали плана + оплата

-- должники с пунктами плана
WITH temp AS (
    SELECT
        d.debtor_id,
        d.full_name,
        cnt.contract_number,
        cnt.debt_amount,
        pd.date,
        COUNT(*) OVER (PARTITION BY cnt.contract_number) AS tmp_cnt,
        CASE WHEN dp.ipd IS NOT NULL THEN 'paid' ELSE 'unpaid' END AS status
    FROM debtor d
    JOIN contract cnt ON cnt.debtor_id = d.debtor_id
    JOIN plan_detailed pd ON pd.contract_number = cnt.contract_number
    LEFT JOIN debt_payment dp ON pd.contract_number = dp.contract_number AND pd.plan_step = dp.plan_step
),
-- должники с > 3 просрочками
debtor_agg AS (
    SELECT
        debtor_id,
        full_name,
        SUM(debt_amount) AS debt,
        COUNT(CASE WHEN status = 'unpaid' AND  date < CURRENT_DATE THEN 1 END) AS overdue_cnt,
        ROUND(SUM(CASE WHEN status = 'unpaid' AND  date < CURRENT_DATE THEN debt_amount / tmp_cnt ELSE 0 END)::numeric, 2) AS overdue_amt,
        COUNT(CASE WHEN status = 'unpaid' AND  date >= CURRENT_DATE THEN 1 END) AS future_cnt,
        ROUND(SUM(CASE WHEN status = 'unpaid' AND  date >= CURRENT_DATE THEN debt_amount / tmp_cnt ELSE 0 END)::numeric, 2) AS future_amt,
        MIN(CASE WHEN status = 'unpaid' AND  date < CURRENT_DATE THEN date END) AS oldest_date
    FROM temp
    GROUP BY debtor_id, full_name
    HAVING COUNT(CASE WHEN status = 'unpaid' AND date < CURRENT_DATE THEN 1 END) > 3
)
SELECT
    -- ФИО должника;
    da.full_name AS "debtor name",

    -- общую сумму долга;
    da.debt AS "total debt",

    -- дата самой старой задолженности по пункту плана;
    da.oldest_date AS "oldest date",

    -- сумму самой старой задолженности по пункту плана;
    ROUND ((SELECT temp.debt_amount / temp.tmp_cnt
     FROM temp
     WHERE temp.debtor_id = da.debtor_id
        AND temp.status = 'unpaid'
        AND temp.date < CURRENT_DATE
     ORDER BY temp.date
     LIMIT 1
    )::numeric, 2) AS "oldest sum",

    -- количество и сумма неоплаченных задолженностей по плану;
    da.overdue_cnt AS "cnt udebt",
    da.overdue_amt AS "amt udebt",

    -- количество и сумма пунктов плана платежей, дата оплаты которых еще не истекла;
    da.future_cnt AS "cnt udebt",
    da.future_amt AS "amt udebt",

    -- % суммы долга, который должник оплатил;
    ROUND (((
        (SELECT COALESCE(SUM(ipd.amount), 0)
        FROM contract cnt
        LEFT JOIN incoming_payment_document ipd ON ipd.contract_number = cnt.contract_number
        WHERE cnt.debtor_id = da.debtor_id)
    ) / NULLIF(da.debt, 0) * 100)::numeric, 2) AS "% paid",

    -- % суммы долга, который должник должен заплатить;
    ROUND (((
        (da.debt - (SELECT COALESCE(SUM(ipd.amount), 0)
        FROM contract cnt
        LEFT JOIN incoming_payment_document ipd ON ipd.contract_number = cnt.contract_number
        WHERE cnt.debtor_id = da.debtor_id))
    ) / NULLIF(da.debt, 0) * 100)::numeric, 2) AS "% unpaid",

    -- % суммы долга, который должник должен заплатить и просрочил;
    ROUND ((da.overdue_amt / NULLIF(da.debt, 0) * 100)::numeric, 2) AS "% overdue",

    -- % суммы долга, который должник должен заплатить и не просрочил.
    ROUND ((da.future_amt / NULLIF(da.debt, 0) * 100)::numeric, 2) AS "% not overdue"
FROM debtor_agg da;

       debtor name       | total debt | oldest date | oldest sum | cnt udebt | amt udebt | cnt udebt | amt udebt | % paid | % unpaid | % overdue | % not overdue
-------------------------+------------+-------------+------------+-----------+-----------+-----------+-----------+--------+----------+-----------+---------------
 Смирнов Смир            |     315000 | 2025-09-10  |   11250.00 |         5 |  85000.00 |         1 |  95000.00 |   4.76 |    95.24 |     26.98 |         30.16
 Кузнецов Кузьма         |     440000 | 2025-08-01  |   14000.00 |         6 | 100000.00 |         1 |  60000.00 |   2.05 |    97.95 |     22.73 |         13.64
 Сидорова Мария          |     260000 | 2025-03-10  |   15000.00 |         7 |  70000.00 |         0 |      0.00 |   9.62 |    90.38 |     26.92 |          0.00
 Петров Петр Петрович    |     970000 | 2025-03-01  |   20000.00 |        13 | 367500.00 |         0 |      0.00 |   6.44 |    93.56 |     37.89 |          0.00
 Сидоров Сидор Сидорович |     185000 | 2025-08-15  |    8333.33 |         4 | 126666.67 |         0 |      0.00 |   4.49 |    95.51 |     68.47 |          0.00
 Петров Петр Петрович    |      80000 | 2025-06-20  |    5000.00 |         4 |  20000.00 |         0 |      0.00 |  12.50 |    87.50 |     25.00 |          0.00
(6 rows)




-- 5. Получить рейтинг популярности стимулирующих мероприятий. Отчет представить в виде:
-- Название мероприятия; общее число раз проведения мероприятия; сколько раз провели в предыдущем месяце; сколько раз провели в текущем месяце; цена мероприятия (текущая); дата последнего проведения; должник, к которому в последний раз применили мероприятие.
-- Я чуток поменяла и стало
-- -- 5. Получить рейтинг популярности стимулирующих мероприятий. Отчет представить в виде:
-- название услуги коллектора; общее число раз применения услуги коллектора; сколько раз провели в предыдущем месяце; сколько раз провели в текущем месяце; цена услугу (текущая); дата последнего проведения; должник, к которому в последний раз применили услугу.

-- услуги коллекторов + услуга как мероприятие + стимулирующее меропрития + коллекторский прайс + стоимость услуги

-- статистика по услугам коллекторов
WITH service_stats AS (
    SELECT
        cs.service_name,
        COUNT(acs.activity_id) AS cnt,
        COUNT(CASE
            WHEN sa.activity_date >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 month' AND  sa.activity_date < date_trunc('month', CURRENT_DATE) THEN 1 END
        ) AS prev_month_cnt,
        COUNT(CASE
            WHEN sa.activity_date >= date_trunc('month', CURRENT_DATE) AND  sa.activity_date < date_trunc('month', CURRENT_DATE) + INTERVAL '1 month' THEN 1 END
        ) AS cur_month_cnt,
        MAX(sa.activity_date) AS last_date
    FROM collector_service cs
    LEFT JOIN activity_service acs ON acs.service_name = cs.service_name
    JOIN stimulating_activity sa ON sa.activity_id = acs.activity_id
    GROUP BY cs.service_name
)
SELECT
    -- название услуги коллектора;
    ss.service_name,

    -- общее число раз применения услуги коллектора;
    ss.cnt,

    -- сколько раз провели в предыдущем месяце;
    ss.prev_month_cnt,

    -- сколько раз провели в текущем месяце;
    ss.cur_month_cnt,

    -- цена услугу (текущая);
    sp.amount AS price,

    -- дата последнего проведения;
    ss.last_date AS "last date",

    -- должник, к которому в последний раз применили услугу.
    (SELECT d.full_name
        FROM activity_service acs
        JOIN stimulating_activity sa ON sa.activity_id = acs.activity_id
        JOIN debtor d ON d.debtor_id = sa.debtor_id
        WHERE acs.service_name = ss.service_name
            AND sa.activity_date = ss.last_date
        LIMIT 1
    ) AS "debtor"
FROM service_stats ss
LEFT JOIN collector_price cp ON cp.service_name = ss.service_name
JOIN service_price sp ON sp.service_code = cp.service_code
ORDER BY ss.cnt DESC;

     service_name     | cnt | prev_month_cnt | cur_month_cnt | price | last date  |     debtor
----------------------+-----+----------------+---------------+-------+------------+----------------
 Звонок родственникам |  11 |              3 |             1 |  1000 | 2026-03-15 | Сидоров Сидор
 Судебный иск         |  10 |              5 |             1 | 20000 | 2026-03-15 | Сидоров Сидор
 звонок другу         |   9 |              1 |             3 | 10000 | 2026-03-15 | Сидоров Сидор
 выезд                |   8 |              1 |             3 |  5000 | 2026-03-15 | Сидоров Сидор
 Личная встреча       |   7 |              0 |             0 |  8000 | 2026-01-12 | Сидоров Сидор
 СМС-уведомление      |   7 |              1 |             0 |  1500 | 2026-02-20 | Кузнецова Анна
 Email-рассылка       |   7 |              1 |             1 |  2000 | 2026-03-05 | Попов Поп
 Публикация в СМИ     |   6 |              1 |             0 |  3000 | 2026-02-20 | Кузнецова Анна
 Залог имущества      |   5 |              1 |             0 |  5000 | 2026-02-18 | Смирнов Смир
(9 rows)




-- c LAG и ROWS BETWEEN
-- 5. Получить рейтинг популярности стимулирующих мероприятий. Отчет представить в виде:
-- название услуги коллектора; общее число раз применения услуги коллектора; сколько раз провели в предыдущем месяце; сколько раз провели в текущем месяце; цена услугу (текущая); дата последнего проведения; должник, к которому в последний раз применили услугу; кол-во применений в предыдущем месяце последнего использования (LAG); среднее кол-во применений за последние 3 месяца использования(ROWS BETWEEN);

-- услуги коллекторов + услуга как мероприятие + стимулирующее меропрития + коллекторский прайс + стоимость услуги

-- агрегация по услугам коллекторов
WITH
used_services AS (
    SELECT
        cs.service_name,
        acs.activity_id,
        sa.activity_date,
        sa.debtor_id
    FROM collector_service cs
    JOIN activity_service acs ON cs.service_name = acs.service_name
    JOIN stimulating_activity sa ON acs.activity_id = sa.activity_id
),
-- агрегация услуг по месяцам
monthly_stats AS (
    SELECT
        service_name,
        DATE_TRUNC('month', activity_date) AS month,
        COUNT(*) AS monthly_count
    FROM used_services
    GROUP BY service_name, month
),
-- статистика по месяцам
stats AS (
    SELECT
        service_name,
        month,
        monthly_count,
        LAG(monthly_count, 1) OVER (PARTITION BY service_name ORDER BY month) AS prev_month_count_lag,
        AVG(monthly_count) OVER (PARTITION BY service_name ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS avg_last_3_months
    FROM monthly_stats
),
-- агрегация по всем услугам, которые использовались
used_summary AS (
    SELECT
        service_name,
        COUNT(*) AS cnt,
        COUNT(CASE WHEN activity_date >= date_trunc('month', CURRENT_DATE) - INTERVAL '1 month' AND activity_date < date_trunc('month', CURRENT_DATE) THEN 1 END) AS prev_month_cnt,
        COUNT(CASE WHEN activity_date >= date_trunc('month', CURRENT_DATE) AND activity_date < date_trunc('month', CURRENT_DATE) + INTERVAL '1 month' THEN 1 END) AS cur_month_cnt,
        MAX(activity_date) AS last_date
    FROM used_services
    GROUP BY service_name
),
-- неиспользуемые услуги
unused_services AS (
    SELECT
        cs.service_name,
        0 AS cnt,
        0 AS prev_month_cnt,
        0 AS cur_month_cnt,
        NULL::date AS last_date
    FROM collector_service cs
    LEFT JOIN activity_service acs ON cs.service_name = acs.service_name
    WHERE acs.activity_id IS NULL
),
-- все услуги
all_services AS (
    SELECT service_name, cnt, prev_month_cnt, cur_month_cnt, last_date FROM used_summary
    UNION ALL
    SELECT service_name, cnt, prev_month_cnt, cur_month_cnt, last_date FROM unused_services
)
SELECT
    -- название услуги коллектора;
    ss.service_name,

    -- общее число раз применения услуги коллектора;
    ss.cnt,

    -- сколько раз провели в предыдущем месяце;
    ss.prev_month_cnt,

    -- сколько раз провели в текущем месяце;
    ss.cur_month_cnt,

    -- цена услугу (текущая);
    sp.amount AS "price",

    -- дата последнего проведения;
    ss.last_date,

    -- должник, к которому в последний раз применили услугу;
    (SELECT d.full_name
        FROM activity_service acs
        JOIN stimulating_activity sa ON sa.activity_id = acs.activity_id
        JOIN debtor d ON d.debtor_id = sa.debtor_id
        WHERE acs.service_name = ss.service_name
            AND sa.activity_date = ss.last_date
        LIMIT 1
    ) AS "debtor",

    -- кол-во применений в предыдущем месяце последнего использования (LAG);
    (SELECT prev_month_count_lag
     FROM stats sw
     WHERE sw.service_name = ss.service_name
       AND sw.month = DATE_TRUNC('month', ss.last_date)
    ) AS "cnt prev month (LAG)",

    -- среднее кол-во применений за последние 3 месяца использования (ROWS BETWEEN);
    ROUND((SELECT avg_last_3_months
     FROM stats sw
     WHERE sw.service_name = ss.service_name
       AND sw.month = DATE_TRUNC('month', ss.last_date)
    ), 2) AS "avg 3 month"
FROM all_services ss
LEFT JOIN collector_price cp ON cp.service_name = ss.service_name
JOIN service_price sp ON sp.service_code = cp.service_code
ORDER BY ss.cnt DESC;

     service_name     | cnt | prev_month_cnt | cur_month_cnt | price | last_date  |     debtor     | cnt prev month (LAG) | avg 3 month
----------------------+-----+----------------+---------------+-------+------------+----------------+----------------------+-------------
 Звонок родственникам |  11 |              3 |             1 |  1000 | 2026-03-15 | Сидоров Сидор  |                    3 |        2.00
 Судебный иск         |  10 |              5 |             1 | 20000 | 2026-03-15 | Сидоров Сидор  |                    5 |        2.33
 звонок другу         |   9 |              1 |             3 | 10000 | 2026-03-15 | Сидоров Сидор  |                    1 |        2.00
 выезд                |   8 |              1 |             3 |  5000 | 2026-03-15 | Сидоров Сидор  |                    1 |        1.67
 Личная встреча       |   7 |              0 |             0 |  8000 | 2026-01-12 | Сидоров Сидор  |                    1 |        1.33
 СМС-уведомление      |   7 |              1 |             0 |  1500 | 2026-02-20 | Кузнецова Анна |                    1 |        1.00
 Email-рассылка       |   7 |              1 |             1 |  2000 | 2026-03-05 | Попов Поп      |                    1 |        1.00
 Публикация в СМИ     |   6 |              1 |             0 |  3000 | 2026-02-20 | Кузнецова Анна |                    1 |        1.00
 Залог имущества      |   5 |              1 |             0 |  5000 | 2026-02-18 | Смирнов Смир   |                    1 |        1.00
(9 rows)
