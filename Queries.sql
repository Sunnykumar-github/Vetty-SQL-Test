-- Q1
SELECT 
    DATE_FORMAT(purchase_time, '%Y-%m') AS purchase_month,
    SUM(CASE WHEN refund_time IS NULL THEN 1 ELSE 0 END) AS purchase_count
FROM transactions
GROUP BY 1
ORDER BY 1;

-- Q2
SELECT COUNT(*) AS store_count
FROM (
    SELECT store_id
    FROM transactions
    WHERE purchase_time BETWEEN '2020-10-01' AND '2020-10-31 23:59:59'
    GROUP BY store_id
    HAVING COUNT(*) >= 5
) AS qualifying_stores;

-- Q3
SELECT 
    store_id,
    MIN(TIMESTAMPDIFF(MINUTE, purchase_time, refund_time)) AS shortest_interval_min
FROM transactions
WHERE refund_time IS NOT NULL
GROUP BY store_id;

-- Q4
WITH StoreFirstOrders AS (
    SELECT 
        store_id, 
        gross_transaction_value,
        ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY purchase_time ASC) as rn
    FROM transactions
)
SELECT 
    store_id, 
    gross_transaction_value
FROM StoreFirstOrders
WHERE rn = 1;

-- Q5
WITH BuyerFirstPurchases AS (
    SELECT 
        item_id, 
        store_id
    FROM (
        SELECT 
            item_id, 
            store_id,
            ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC) as rn
        FROM transactions
    ) t
    WHERE rn = 1
)
SELECT 
    i.item_name, 
    COUNT(*) as order_count
FROM BuyerFirstPurchases bfp
JOIN items i ON bfp.item_id = i.item_id AND bfp.store_id = i.store_id
GROUP BY i.item_name
ORDER BY order_count DESC
LIMIT 1;

-- Q6
SELECT 
    buyer_id,
    purchase_time,
    refund_time,
    CASE 
        WHEN refund_time IS NOT NULL 
             AND TIMESTAMPDIFF(HOUR, purchase_time, refund_time) <= 72 
        THEN 'Processed'
        ELSE 'Not Processed'
    END AS refund_process_flag
FROM transactions;

-- Q7
SELECT *
FROM (
    SELECT 
        *,
        RANK() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC) as purchase_rank
    FROM transactions
) ranked
WHERE purchase_rank = 2;

-- Q8
SELECT 
    buyer_id,
    purchase_time
FROM (
    SELECT 
        buyer_id,
        purchase_time,
        ROW_NUMBER() OVER (PARTITION BY buyer_id ORDER BY purchase_time ASC) as rn
    FROM transactions
) t
WHERE rn = 2;