-- ============================================================
-- OLIST E-COMMERCE BUSINESS INVESTIGATION
-- FINAL SQL ANALYSIS
-- ============================================================
-- Scope: delivered orders unless a query states otherwise.
-- Main comparison window: January-August 2018.
-- Purpose: portfolio-ready business analysis.
-- Exploratory/redundant variants removed; strongest business
-- questions retained and formatting standardized.
-- ============================================================

-- ------------------------------------------------------------
-- Q1 — What was the monthly delivered-order volume from January to August 2018?
-- ------------------------------------------------------------

SELECT
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
    COUNT(DISTINCT order_id) AS delivered_orders
FROM orders
WHERE order_status = 'delivered'
  AND order_purchase_timestamp >= '2018-01-01'
  AND order_purchase_timestamp < '2018-09-01'
GROUP BY EXTRACT(MONTH FROM order_purchase_timestamp)
ORDER BY month ASC;

-- ------------------------------------------------------------
-- Q2 — How did delivered sales change month by month from January to August 2018?
-- ------------------------------------------------------------

SELECT
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
    SUM(oi.price) AS sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2018-01-01'
  AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY EXTRACT(MONTH FROM o.order_purchase_timestamp)
ORDER BY month ASC;

-- ------------------------------------------------------------
-- Q3 — What was the monthly average order value from January to August 2018?
-- ------------------------------------------------------------

SELECT
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
    SUM(oi.price) AS sales,
    SUM(oi.price) / COUNT(DISTINCT o.order_id) AS aov
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2018-01-01'
  AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY EXTRACT(MONTH FROM o.order_purchase_timestamp)
ORDER BY month ASC;

-- ------------------------------------------------------------
-- Q4 — What was the delivered-sales change from January to August 2018?
-- ------------------------------------------------------------

SELECT
    january_sales,
    august_sales,
    (august_sales - january_sales)::numeric / january_sales * 100 AS sales_change_pct
FROM (
    SELECT
        SUM(CASE
            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1 THEN oi.price
        END) AS january_sales,
        SUM(CASE
            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8 THEN oi.price
        END) AS august_sales
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2018-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
) AS monthly_sales;

-- ------------------------------------------------------------
-- Q5 — How did delivered-order volume change from January to August 2018?
-- ------------------------------------------------------------
SELECT
    january_orders,
    august_orders,
    (august_orders - january_orders) :: numeric / january_orders * 100 AS orders_change_pct

FROM (
    SELECT
        COUNT(
            DISTINCT CASE
                WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
                THEN oi.order_id
            END
        ) AS january_orders,

        COUNT(
            DISTINCT CASE
                WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
                THEN oi.order_id
            END
        ) AS august_orders

    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2018-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
) AS monthly_orders;

-- ------------------------------------------------------------
-- Q6 — How did AOV change from January to August 2018?
-- ------------------------------------------------------------
SELECT
    january_orders,
    august_orders,
    (august_orders - january_orders)::numeric
        / january_orders * 100 AS orders_change_pct,
    january_AOV,
    august_AOV,
    (august_AOV - january_AOV)::numeric
        / january_AOV * 100 AS AOV_change_pct
FROM (
    SELECT
        january_orders,
        august_orders,
        january_sales / january_orders AS january_AOV,
        august_sales / august_orders AS august_AOV
    FROM (
        SELECT
            COUNT(
                DISTINCT CASE
                    WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
                    THEN oi.order_id
                END
            ) AS january_orders,

            COUNT(
                DISTINCT CASE
                    WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
                    THEN oi.order_id
                END
            ) AS august_orders,

            SUM(
                CASE
                    WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
                    THEN oi.price
                END
            ) AS january_sales,

            SUM(
                CASE
                    WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
                    THEN oi.price
                END
            ) AS august_sales

        FROM orders o
        JOIN order_items oi
            ON o.order_id = oi.order_id

        WHERE o.order_status = 'delivered'
          AND o.order_purchase_timestamp >= '2018-01-01'
          AND o.order_purchase_timestamp < '2018-09-01'
    ) AS monthly_totals
) AS monthly_aov;

-- ------------------------------------------------------------
-- Q7 — How did the number of active customers change from January to August 2018?
-- ------------------------------------------------------------
SELECT
    january_customers,
    august_customers
FROM (
    SELECT
        COUNT(
            DISTINCT CASE
                WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
                THEN c.customer_unique_id
            END
        ) AS january_customers,

        COUNT(
            DISTINCT CASE
                WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
                THEN c.customer_unique_id
            END
        ) AS august_customers

    FROM orders o

    JOIN olist_customers c
        ON o.customer_id = c.customer_id

    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2018-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
) AS monthly_customers;

-- ------------------------------------------------------------
-- Q8 — How many customers were new versus returning each month?
-- ------------------------------------------------------------
WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date
    FROM orders o
    JOIN olist_customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
),

customer_activity AS (
    SELECT
        c.customer_unique_id,
        o.order_purchase_timestamp,
        fp.first_purchase_date,

        CASE
            WHEN DATE_TRUNC('month', fp.first_purchase_date)
                 = DATE_TRUNC('month', o.order_purchase_timestamp)
            THEN 'New'
            ELSE 'Returning'
        END AS customer_type

    FROM orders o
    JOIN olist_customers c
        ON o.customer_id = c.customer_id
    JOIN first_purchase fp
        ON c.customer_unique_id = fp.customer_unique_id

    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2018-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
)

SELECT
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month,

    COUNT(DISTINCT CASE
        WHEN customer_type = 'New'
        THEN customer_unique_id
    END) AS new_customers,

    COUNT(DISTINCT CASE
        WHEN customer_type = 'Returning'
        THEN customer_unique_id
    END) AS returning_customers

FROM customer_activity

GROUP BY EXTRACT(MONTH FROM order_purchase_timestamp)
ORDER BY month;

-- ------------------------------------------------------------
-- Q9 — What share of monthly customers were returning customers?
-- ------------------------------------------------------------
WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_date
    FROM orders o
    JOIN olist_customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
),

customer_activity AS (
    SELECT
        c.customer_unique_id,
        o.order_purchase_timestamp,
        fp.first_purchase_date,

        CASE
            WHEN DATE_TRUNC('month', fp.first_purchase_date)
                 = DATE_TRUNC('month', o.order_purchase_timestamp)
            THEN 'New'
            ELSE 'Returning'
        END AS customer_type

    FROM orders o
    JOIN olist_customers c
        ON o.customer_id = c.customer_id
    JOIN first_purchase fp
        ON c.customer_unique_id = fp.customer_unique_id

    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2018-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
)

SELECT
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month,

    COUNT(DISTINCT customer_unique_id) AS total_customers,

    COUNT(DISTINCT CASE
        WHEN customer_type = 'Returning'
        THEN customer_unique_id
    END) AS returning_customers,

    COUNT(DISTINCT CASE
        WHEN customer_type = 'Returning'
        THEN customer_unique_id
    END)::numeric
    / COUNT(DISTINCT customer_unique_id) * 100
    AS returning_customer_share

FROM customer_activity

GROUP BY EXTRACT(MONTH FROM order_purchase_timestamp)
ORDER BY month;

-- ------------------------------------------------------------
-- Q10 — Did customers place more or fewer delivered orders per customer in August than January?
-- ------------------------------------------------------------
SELECT
    january_orders,
    august_orders,
    january_customers,
    august_customers,

    january_orders::numeric / january_customers
        AS january_orders_per_customer,

    august_orders::numeric / august_customers
        AS august_orders_per_customer

FROM (
    SELECT
    COUNT(
        DISTINCT CASE
            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
            THEN o.order_id
        END
    ) AS january_orders,

    COUNT(
        DISTINCT CASE
            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
            THEN o.order_id
        END
    ) AS august_orders,

    COUNT(
        DISTINCT CASE
            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
            THEN c.customer_unique_id
        END
    ) AS january_customers,

    COUNT(
        DISTINCT CASE
            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
            THEN c.customer_unique_id
        END
    ) AS august_customers

FROM orders o
JOIN olist_customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2018-01-01'
  AND o.order_purchase_timestamp < '2018-09-01'
) AS customer_metrics;

-- ------------------------------------------------------------
-- Q11 — Which product categories generated the most delivered sales?
-- ------------------------------------------------------------
select 
p.product_category_name,
sum(oi.price) as sales
from orders o
join order_items oi
on o.order_id = oi.order_id
join olist_products p
on oi.product_id = p.product_id
where o.order_status = 'delivered'
AND o.order_purchase_timestamp >= '2018-01-01'
AND o.order_purchase_timestamp < '2018-09-01'
group by p.product_category_name
order by sales desc;

-- ------------------------------------------------------------
-- Q12 — Which product categories grew or declined between January and August 2018?
-- ------------------------------------------------------------
SELECT
    product_category_name,
    january_sales,
    august_sales,
    august_sales - january_sales AS sales_change,
	case 
		when january_sales = 0 then null
		else (august_sales - january_sales):: numeric
        / january_sales * 100
		end as sales_change_pct
FROM (
    SELECT
    p.product_category_name,

    SUM(
        CASE
            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
            THEN oi.price
			else 0
        END
    ) AS january_sales,

    SUM(
        CASE
            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
            THEN oi.price
			else 0
        END
    ) AS august_sales

FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN olist_products p
    ON oi.product_id = p.product_id

WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2018-01-01'
  AND o.order_purchase_timestamp < '2018-09-01'

GROUP BY p.product_category_name
ORDER BY january_sales DESC
) AS category_sales
ORDER BY sales_change asc;

-- ------------------------------------------------------------
-- Q13 — How was category growth/decline driven by order volume versus sales per order?
-- ------------------------------------------------------------
WITH category_metrics AS (
    SELECT
        p.product_category_name,
        COUNT(DISTINCT CASE
            WHEN o.order_purchase_timestamp >= '2018-01-01'
             AND o.order_purchase_timestamp < '2018-02-01'
            THEN o.order_id END) AS january_orders,
        COUNT(DISTINCT CASE
            WHEN o.order_purchase_timestamp >= '2018-08-01'
             AND o.order_purchase_timestamp < '2018-09-01'
            THEN o.order_id END) AS august_orders,
        SUM(CASE
            WHEN o.order_purchase_timestamp >= '2018-01-01'
             AND o.order_purchase_timestamp < '2018-02-01'
            THEN oi.price ELSE 0 END) AS january_sales,
        SUM(CASE
            WHEN o.order_purchase_timestamp >= '2018-08-01'
             AND o.order_purchase_timestamp < '2018-09-01'
            THEN oi.price ELSE 0 END) AS august_sales
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN olist_products p ON oi.product_id = p.product_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2018-01-01'
      AND o.order_purchase_timestamp < '2018-09-01'
    GROUP BY p.product_category_name
), category_changes AS (
    SELECT
        *,
        january_sales / NULLIF(january_orders, 0) AS january_sales_per_order,
        august_sales / NULLIF(august_orders, 0) AS august_sales_per_order,
        CASE WHEN january_orders = 0 THEN NULL
             ELSE (august_orders - january_orders)::numeric / january_orders * 100 END AS orders_change_pct,
        CASE
            WHEN january_orders = 0 OR january_sales = 0 OR august_orders = 0 THEN NULL
            ELSE ((august_sales / august_orders) - (january_sales / january_orders))::numeric
                 / (january_sales / january_orders) * 100
        END AS sales_per_order_change_pct
    FROM category_metrics
)
SELECT
    product_category_name,
    january_orders,
    august_orders,
    january_sales,
    august_sales,
    ROUND(orders_change_pct, 2) AS orders_change_pct,
    ROUND(sales_per_order_change_pct, 2) AS sales_per_order_change_pct,
    CASE
        WHEN january_orders = 0 AND august_orders = 0 THEN 'No activity'
        WHEN january_orders = 0 AND august_orders > 0 THEN 'New activity'
        WHEN orders_change_pct > 0 AND sales_per_order_change_pct > 0 THEN 'Expansion'
        WHEN orders_change_pct > 0 AND sales_per_order_change_pct < 0 THEN 'Volume-driven'
        WHEN orders_change_pct < 0 AND sales_per_order_change_pct > 0 THEN 'Value/mix pressure'
        WHEN orders_change_pct < 0 AND sales_per_order_change_pct < 0 THEN 'Double pressure'
        ELSE 'Stable / mixed'
    END AS growth_driver
FROM category_changes
ORDER BY august_sales - january_sales DESC;

-- ------------------------------------------------------------
-- Q14 — Which categories experienced simultaneous declines in orders and sales per order?
-- ------------------------------------------------------------
Double pressure category_changes



SELECT
    product_category_name,
    january_sales,
    august_sales,
    august_sales - january_sales AS sales_change,
    orders_change_pct,
    sales_per_order_change_pct
FROM (
    SELECT
        product_category_name,
        january_orders,
        august_orders,
        january_sales,
        august_sales,
        january_sales_per_order,
        august_sales_per_order,
        orders_change_pct,
        sales_per_order_change_pct,

        CASE
            WHEN january_orders = 0
                 AND august_orders = 0
                THEN 'No activity'

            WHEN january_orders = 0
                 AND august_orders > 0
                THEN 'New activity'

            WHEN orders_change_pct > 0
                 AND sales_per_order_change_pct > 0
                THEN 'Expansion'

            WHEN orders_change_pct > 0
                 AND sales_per_order_change_pct < 0
                THEN 'Volume-driven'

            WHEN orders_change_pct < 0
                 AND sales_per_order_change_pct > 0
                THEN 'Value/mix pressure'

            WHEN orders_change_pct < 0
                 AND sales_per_order_change_pct < 0
                THEN 'Double pressure'

            ELSE 'Stable / mixed'
        END AS growth_driver

    FROM (
        SELECT
            product_category_name,
            january_orders,
            august_orders,
            january_sales,
            august_sales,

            january_sales / NULLIF(january_orders, 0)
                AS january_sales_per_order,

            august_sales / NULLIF(august_orders, 0)
                AS august_sales_per_order,

            CASE
                WHEN january_orders = 0 THEN NULL
                ELSE (august_orders - january_orders)::numeric
                     / january_orders * 100
            END AS orders_change_pct,

            CASE
                WHEN january_orders = 0
                  OR january_sales = 0
                  OR august_orders = 0
                THEN NULL
                ELSE (
                    august_sales / august_orders
                    - january_sales / january_orders
                )::numeric
                / (january_sales / january_orders) * 100
            END AS sales_per_order_change_pct

        FROM (
            SELECT
                p.product_category_name,

                COUNT(DISTINCT CASE
                    WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
                    THEN o.order_id
                END) AS january_orders,

                COUNT(DISTINCT CASE
                    WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
                    THEN o.order_id
                END) AS august_orders,

                SUM(CASE
                    WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
                    THEN oi.price
                    ELSE 0
                END) AS january_sales,

                SUM(CASE
                    WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
                    THEN oi.price
                    ELSE 0
                END) AS august_sales

            FROM orders o

            JOIN order_items oi
                ON o.order_id = oi.order_id

            JOIN olist_products p
                ON oi.product_id = p.product_id

            WHERE o.order_status = 'delivered'
              AND o.order_purchase_timestamp >= '2018-01-01'
              AND o.order_purchase_timestamp < '2018-09-01'

            GROUP BY p.product_category_name

        ) AS category_metrics

    ) AS category_changes

) AS classified_categories

WHERE growth_driver = 'Double pressure'

ORDER BY sales_change ASC;

-- ------------------------------------------------------------
-- Q15 — How concentrated was the sales loss among double-pressure categories?
-- ------------------------------------------------------------
SELECT
    product_category_name,
    sales_change,
    sales_change / total_double_pressure_loss * 100
        AS loss_contribution_pct
FROM (
    SELECT
        product_category_name,
        sales_change,
        SUM(sales_change) OVER ()
            AS total_double_pressure_loss
    FROM (
        SELECT
            product_category_name,
            january_sales,
            august_sales,
            august_sales - january_sales AS sales_change
        FROM (
            SELECT
                product_category_name,
                january_sales,
                august_sales,
                orders_change_pct,
                sales_per_order_change_pct,

                CASE
                    WHEN january_orders = 0
                         AND august_orders = 0
                        THEN 'No activity'

                    WHEN january_orders = 0
                         AND august_orders > 0
                        THEN 'New activity'

                    WHEN orders_change_pct > 0
                         AND sales_per_order_change_pct > 0
                        THEN 'Expansion'

                    WHEN orders_change_pct > 0
                         AND sales_per_order_change_pct < 0
                        THEN 'Volume-driven'

                    WHEN orders_change_pct < 0
                         AND sales_per_order_change_pct > 0
                        THEN 'Value/mix pressure'

                    WHEN orders_change_pct < 0
                         AND sales_per_order_change_pct < 0
                        THEN 'Double pressure'

                    ELSE 'Stable / mixed'
                END AS growth_driver

            FROM (
                SELECT
                    product_category_name,
                    january_orders,
                    august_orders,
                    january_sales,
                    august_sales,

                    january_sales / NULLIF(january_orders, 0)
                        AS january_sales_per_order,

                    august_sales / NULLIF(august_orders, 0)
                        AS august_sales_per_order,

                    CASE
                        WHEN january_orders = 0 THEN NULL
                        ELSE (august_orders - january_orders)::numeric
                             / january_orders * 100
                    END AS orders_change_pct,

                    CASE
                        WHEN january_orders = 0
                          OR january_sales = 0
                          OR august_orders = 0
                        THEN NULL
                        ELSE (
                            august_sales / august_orders
                            - january_sales / january_orders
                        )::numeric
                        / (january_sales / january_orders) * 100
                    END AS sales_per_order_change_pct

                FROM (
                    SELECT
                        p.product_category_name,

                        COUNT(DISTINCT CASE
                            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
                            THEN o.order_id
                        END) AS january_orders,

                        COUNT(DISTINCT CASE
                            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
                            THEN o.order_id
                        END) AS august_orders,

                        SUM(CASE
                            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
                            THEN oi.price
                            ELSE 0
                        END) AS january_sales,

                        SUM(CASE
                            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
                            THEN oi.price
                            ELSE 0
                        END) AS august_sales

                    FROM orders o
                    JOIN order_items oi
                        ON o.order_id = oi.order_id
                    JOIN olist_products p
                        ON oi.product_id = p.product_id

                    WHERE o.order_status = 'delivered'
                      AND o.order_purchase_timestamp >= '2018-01-01'
                      AND o.order_purchase_timestamp < '2018-09-01'

                    GROUP BY p.product_category_name

                ) AS category_metrics

            ) AS category_changes

        ) AS classified_categories

        WHERE growth_driver = 'Double pressure'

    ) AS double_pressure_categories
) AS loss_data

ORDER BY sales_change ASC;

-- ------------------------------------------------------------
-- Q16 — Which categories account for the decline in delivered-order volume?
-- ------------------------------------------------------------
SELECT
    p.product_category_name,
    COUNT(DISTINCT CASE
        WHEN o.order_purchase_timestamp >= '2018-01-01'
         AND o.order_purchase_timestamp < '2018-02-01'
        THEN o.order_id END) AS jan_orders,
    COUNT(DISTINCT CASE
        WHEN o.order_purchase_timestamp >= '2018-08-01'
         AND o.order_purchase_timestamp < '2018-09-01'
        THEN o.order_id END) AS aug_orders,
    COUNT(DISTINCT CASE
        WHEN o.order_purchase_timestamp >= '2018-08-01'
         AND o.order_purchase_timestamp < '2018-09-01'
        THEN o.order_id END)
    -
    COUNT(DISTINCT CASE
        WHEN o.order_purchase_timestamp >= '2018-01-01'
         AND o.order_purchase_timestamp < '2018-02-01'
        THEN o.order_id END) AS order_change
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN olist_products p ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2018-01-01'
  AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY p.product_category_name
ORDER BY order_change ASC;

-- ------------------------------------------------------------
-- Q17 — Which categories lost the most customers between January and August?
-- ------------------------------------------------------------
SELECT
    p.product_category_name,
    COUNT(DISTINCT CASE
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
        THEN c.customer_unique_id END) AS jan_customers,
    COUNT(DISTINCT CASE
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
        THEN c.customer_unique_id END) AS aug_customers
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN olist_products p ON oi.product_id = p.product_id
JOIN olist_customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2018-01-01'
  AND o.order_purchase_timestamp < '2018-09-01'
GROUP BY p.product_category_name
ORDER BY
    COUNT(DISTINCT CASE
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
        THEN c.customer_unique_id END)
    -
    COUNT(DISTINCT CASE
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
        THEN c.customer_unique_id END) DESC;

-- ------------------------------------------------------------
-- Q18 — Did customers who remained active spend more or less per customer by category?
-- ------------------------------------------------------------
SELECT
    p.product_category_name,

    SUM(CASE
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
        THEN oi.price ELSE 0 END)
    / NULLIF(COUNT(DISTINCT CASE
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
        THEN c.customer_unique_id END), 0) AS jan_sales_per_customer,

    SUM(CASE
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
        THEN oi.price ELSE 0 END)
    / NULLIF(COUNT(DISTINCT CASE
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
        THEN c.customer_unique_id END), 0) AS aug_sales_per_customer

FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN olist_products p ON oi.product_id = p.product_id
JOIN olist_customers c ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_purchase_timestamp >= '2018-01-01'
  AND o.order_purchase_timestamp < '2018-09-01'

GROUP BY p.product_category_name

ORDER BY
    SUM(CASE
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
        THEN oi.price ELSE 0 END)
    / NULLIF(COUNT(DISTINCT CASE
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 1
        THEN c.customer_unique_id END), 0)
    -
    SUM(CASE
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
        THEN oi.price ELSE 0 END)
    / NULLIF(COUNT(DISTINCT CASE
        WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) = 8
        THEN c.customer_unique_id END), 0) DESC;

-- ------------------------------------------------------------
-- Q19 — How concentrated were delivered sales among the top sellers?
-- ------------------------------------------------------------
WITH seller_sales AS (
    SELECT
        oi.seller_id,
        SUM(oi.price) AS sales
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id
),

ranked AS (
    SELECT
        sales,
        ROW_NUMBER() OVER (ORDER BY sales DESC) AS rn
    FROM seller_sales
)

SELECT
    SUM(CASE WHEN rn <= 10 THEN sales ELSE 0 END) AS top_10_sales,
    SUM(sales) AS total_sales,
    SUM(CASE WHEN rn <= 10 THEN sales ELSE 0 END)
        / SUM(sales) * 100 AS top_10_sales_share
FROM ranked;

-- ------------------------------------------------------------
-- Q20 — Which high-value sellers also had elevated late-delivery rates?
-- ------------------------------------------------------------
WITH seller_risk AS (
    SELECT
        oi.seller_id,
        COUNT(DISTINCT o.order_id) AS orders,
        SUM(oi.price) AS sales,
        COUNT(DISTINCT CASE
            WHEN o.order_delivered_customer_date
                 > o.order_estimated_delivery_date
            THEN o.order_id END)::numeric
            / COUNT(DISTINCT o.order_id) * 100 AS late_rate
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id
)

SELECT *
FROM seller_risk
WHERE sales >= 100000
  AND late_rate >= 8
ORDER BY sales DESC;

-- ------------------------------------------------------------
-- Q21 — How did high-risk sellers compare with the destination-state marketplace baseline?
-- ------------------------------------------------------------
WITH seller_risk AS (
    SELECT
        oi.seller_id
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id
    HAVING SUM(oi.price) >= 100000
       AND COUNT(DISTINCT CASE
           WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
           THEN o.order_id END)::numeric
           / COUNT(DISTINCT o.order_id) * 100 >= 8
),

seller_state AS (
    SELECT
        oi.seller_id,
        c.customer_state,
        COUNT(DISTINCT o.order_id) AS orders,
        COUNT(DISTINCT CASE
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN o.order_id END)::numeric
            / COUNT(DISTINCT o.order_id) * 100 AS seller_late_rate
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN olist_customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND oi.seller_id IN (SELECT seller_id FROM seller_risk)
    GROUP BY oi.seller_id, c.customer_state
),

marketplace AS (
    SELECT
        c.customer_state,
        COUNT(DISTINCT o.order_id) AS orders,
        COUNT(DISTINCT CASE
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN o.order_id END)::numeric
            / COUNT(DISTINCT o.order_id) * 100 AS market_late_rate
    FROM orders o
    JOIN olist_customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
)

SELECT
    s.seller_id,
    s.customer_state,
    s.orders,
    ROUND(s.seller_late_rate, 2) AS seller_late_rate,
    ROUND(m.market_late_rate, 2) AS market_late_rate,
    ROUND(s.seller_late_rate - m.market_late_rate, 2) AS late_rate_gap
FROM seller_state s
JOIN marketplace m
    ON s.customer_state = m.customer_state
WHERE s.orders >= 50
ORDER BY late_rate_gap DESC;

-- ------------------------------------------------------------
-- Q22 — Which categories had the highest freight intensity relative to sales?
-- ------------------------------------------------------------
SELECT
    p.product_category_name,
    SUM(oi.price) AS sales,
    SUM(oi.freight_value) AS freight,
    SUM(oi.freight_value) / NULLIF(SUM(oi.price), 0) * 100 AS freight_pct
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN olist_products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY freight_pct DESC;

-- ------------------------------------------------------------
-- Q23 — Which high-sales categories combine sales change with freight and late-delivery risk?
-- ------------------------------------------------------------
WITH category_metrics AS (
    SELECT
        p.product_category_name,
        SUM(CASE WHEN o.order_purchase_timestamp >= '2018-01-01'
                  AND o.order_purchase_timestamp < '2018-02-01'
                 THEN oi.price ELSE 0 END) AS jan_sales,
        SUM(CASE WHEN o.order_purchase_timestamp >= '2018-08-01'
                  AND o.order_purchase_timestamp < '2018-09-01'
                 THEN oi.price ELSE 0 END) AS aug_sales,
        SUM(oi.price) AS sales,
        SUM(oi.freight_value) AS freight,
        COUNT(DISTINCT o.order_id) AS orders,
        COUNT(DISTINCT CASE
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN o.order_id END) AS late_orders
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN olist_products p ON oi.product_id = p.product_id
    WHERE o.order_status = 'delivered'
    GROUP BY p.product_category_name
)

SELECT
    product_category_name,
    jan_sales,
    aug_sales,
    aug_sales - jan_sales AS sales_change,
    freight / NULLIF(sales, 0) * 100 AS freight_pct,
    late_orders::numeric / NULLIF(orders, 0) * 100 AS late_rate
FROM category_metrics
WHERE sales >= 100000
ORDER BY sales_change ASC;

-- ------------------------------------------------------------
-- Q24 — How large was each monthly first-purchase customer cohort?
-- ------------------------------------------------------------

WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC('month', MIN(o.order_purchase_timestamp)) AS cohort_month
    FROM orders o
    JOIN olist_customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)

SELECT
    cohort_month,
    COUNT(*) AS customers
FROM first_purchase
GROUP BY cohort_month
ORDER BY cohort_month;

-- ------------------------------------------------------------
-- Q24B — How many customers from each cohort purchased again in subsequent months?
-- ------------------------------------------------------------

WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC('month', MIN(o.order_purchase_timestamp)) AS cohort_month
    FROM orders o
    JOIN olist_customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),

activity AS (
    SELECT DISTINCT
        c.customer_unique_id,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS purchase_month
    FROM orders o
    JOIN olist_customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
)

SELECT
    f.cohort_month,
    a.purchase_month,
    COUNT(DISTINCT a.customer_unique_id) AS active_customers
FROM first_purchase f
JOIN activity a
    ON f.customer_unique_id = a.customer_unique_id
GROUP BY f.cohort_month, a.purchase_month
ORDER BY f.cohort_month, a.purchase_month;

-- ------------------------------------------------------------
-- Q24C — What was the observed retention rate for each cohort and purchase month?
-- ------------------------------------------------------------
WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        DATE_TRUNC('month', MIN(o.order_purchase_timestamp)) AS cohort_month
    FROM orders o
    JOIN olist_customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),

activity AS (
    SELECT DISTINCT
        c.customer_unique_id,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS purchase_month
    FROM orders o
    JOIN olist_customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),

cohort AS (
    SELECT
        f.cohort_month,
        a.purchase_month,
        COUNT(DISTINCT a.customer_unique_id) AS active_customers
    FROM first_purchase f
    JOIN activity a
        ON f.customer_unique_id = a.customer_unique_id
    GROUP BY f.cohort_month, a.purchase_month
)

SELECT
    cohort_month,
    purchase_month,
    active_customers,
    ROUND(
        active_customers::numeric /
        MAX(active_customers) OVER (PARTITION BY cohort_month) * 100,
        2
    ) AS retention_pct
FROM cohort
ORDER BY cohort_month, purchase_month;

-- ------------------------------------------------------------
-- Q25 — How deep was repeat purchasing among delivered-order customers?
-- ------------------------------------------------------------
SELECT
    orders_count,
    COUNT(*) AS customers
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS orders_count
    FROM orders o
    JOIN olist_customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
) x
GROUP BY orders_count
ORDER BY orders_count;

-- ------------------------------------------------------------
-- Q26 — What financial contribution came from one-time versus repeat customers?
-- ------------------------------------------------------------
WITH customer_sales AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS orders,
        SUM(oi.price) AS sales
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN olist_customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    CASE WHEN orders = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type,
    COUNT(*) AS customers,
    SUM(sales) AS sales,
    SUM(sales) / SUM(SUM(sales)) OVER () * 100 AS sales_share
FROM customer_sales
GROUP BY 1
ORDER BY sales_share DESC;

-- ------------------------------------------------------------
-- Q27 — Which product categories were most associated with repeat customers?
-- ------------------------------------------------------------
SELECT
    p.product_category_name,
    COUNT(DISTINCT c.customer_unique_id) AS repeat_customers,
    SUM(oi.price) AS sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN olist_customers c ON o.customer_id = c.customer_id
JOIN olist_products p ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
  AND c.customer_unique_id IN (
      SELECT c2.customer_unique_id
      FROM orders o2
      JOIN olist_customers c2 ON o2.customer_id = c2.customer_id
      WHERE o2.order_status = 'delivered'
      GROUP BY c2.customer_unique_id
      HAVING COUNT(DISTINCT o2.order_id) > 1
  )
GROUP BY p.product_category_name
ORDER BY repeat_customers DESC;

-- ============================================================
-- FINALIZATION NOTES
-- ============================================================
-- Q24/Q24b/Q24c are intentionally retained together: cohort size,
-- cohort activity, and retention rate are complementary views.
-- Q13 consolidates the original category growth-driver logic into
-- one reusable all-category query.
-- Business conclusions belong in the project report; this file is
-- the reproducible SQL analysis layer.
-- ============================================================
