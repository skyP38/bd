q3: contract + incoming_payment_document + outgoing_payment_document + payment_plan

-- составной покрывающий
CREATE INDEX idx_ipd ON incoming_payment_document(payment_date, contract_number) INCLUDE (amount);


-- покрывающий
CREATE INDEX idx_contract ON contract(date) INCLUDE (debt_amount);


-- частичный
CREATE INDEX idx_payment_plan_unpaid ON payment_plan(contract_number)
WHERE paid_flag = FALSE;


| Метрика | До | После |
| --- | --- | --- |
| Время выполнения (мс) | 6048.9 | 4363.9 |
| Shared hit buffers | 164549 | 77223 |
| Shared read buffers | 910 | 138 |
| Temp read | 2016 | 2564 |
| Temp written | 4216 | 5594 |

Seq Scan -> Index Only Scan
Seq Scan -> Bitmap Heap Scan



-- составной
CREATE INDEX idx_contract_debtor_number ON contract(debtor_id, contract_number);

    
-- покрывающий
CREATE INDEX idx_incoming_payment_covering ON incoming_payment_document(contract_number) INCLUDE (amount);

Seq Scan -> Index Only Scan


| Метрика | До | После |
| --- | --- | --- |
| Время выполнения (мс) | 3891.7 | 1474.4 |
| Shared hit buffers | 135013 | 4122 |
| Temp read | 138574 | 141874 |
| Temp written | 1075 | 1075 |
