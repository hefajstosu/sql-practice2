-- Schemat: mały e-commerce + tabela pracowników (do zadań rankingowych z remisami)

CREATE TABLE customers (
    customer_id  serial PRIMARY KEY,
    country      text   NOT NULL,
    signup_date  date   NOT NULL
);

CREATE TABLE products (
    product_id   serial        PRIMARY KEY,
    category     text          NOT NULL,
    price        numeric(10,2) NOT NULL
);

CREATE TABLE orders (
    order_id     serial PRIMARY KEY,
    customer_id  int    NOT NULL REFERENCES customers,
    order_date   date   NOT NULL,
    status       text   NOT NULL
);

CREATE TABLE order_items (
    order_id     int NOT NULL REFERENCES orders,
    product_id   int NOT NULL REFERENCES products,
    quantity     int NOT NULL,
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE employees (
    employee_id  serial PRIMARY KEY,
    department   text   NOT NULL,
    salary       int    NOT NULL,
    hire_date    date   NOT NULL,
    manager_id   int
);

-- Deterministyczny seed: ten sam zbiór na każdej maszynie
SELECT setseed(0.42);

INSERT INTO customers (country, signup_date)
SELECT (ARRAY['PL','DE','US','UK','FR'])[1 + (random() * 4)::int],
       date '2024-01-01' + (random() * 600)::int
FROM generate_series(1, 5000);

INSERT INTO products (category, price)
SELECT (ARRAY['books','electronics','home','toys','sport'])[1 + (random() * 4)::int],
       round((5 + random() * 495)::numeric, 2)
FROM generate_series(1, 200);

INSERT INTO orders (customer_id, order_date, status)
SELECT 1 + (random() * 4999)::int,
       date '2024-01-01' + (random() * 630)::int,
       (ARRAY['completed','completed','completed','cancelled','returned'])[1 + (random() * 4)::int]
FROM generate_series(1, 100000);

-- 1–3 pozycje na zamówienie; DISTINCT chroni klucz główny (order_id, product_id)
INSERT INTO order_items (order_id, product_id, quantity)
SELECT o.order_id, p.product_id, 1 + (random() * 4)::int
FROM orders o
CROSS JOIN LATERAL (
    SELECT DISTINCT 1 + (random() * 199)::int AS product_id
    FROM generate_series(1, 1 + (o.order_id % 3))
) p;

-- Pensje w krokach po 100 => dużo remisów (celowo: RANK vs DENSE_RANK vs ROW_NUMBER)
INSERT INTO employees (department, salary, hire_date)
SELECT (ARRAY['data','backend','frontend','sales','hr'])[1 + (random() * 4)::int],
       4000 + (random() * 120)::int * 100,
       date '2018-01-01' + (random() * 2900)::int
FROM generate_series(1, 300);

ANALYZE;