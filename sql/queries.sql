-- ============================================================
-- Customer Churn Analysis — SQL (Telecom)
-- Data: 7,000 subscribers, 1,820 churned (26.0%)
-- ============================================================

-- 1. Churn rate by contract type (biggest churn driver)
SELECT contract_type,
       COUNT(*) AS customers,
       SUM(is_churned) AS churned,
       ROUND(100.0 * SUM(is_churned) / COUNT(*), 1) AS churn_rate_pct
FROM customers
GROUP BY contract_type
ORDER BY churn_rate_pct DESC;

-- 2. Churn rate by tenure bucket (early-life churn risk)
SELECT CASE WHEN tenure_months < 6  THEN 'a 0-6'
            WHEN tenure_months < 12 THEN 'b 6-12'
            WHEN tenure_months < 24 THEN 'c 12-24'
            WHEN tenure_months < 48 THEN 'd 24-48'
            ELSE 'e 48+' END AS tenure_bucket,
       COUNT(*) AS customers,
       SUM(is_churned) AS churned,
       ROUND(100.0 * SUM(is_churned) / COUNT(*), 1) AS churn_rate_pct
FROM customers
GROUP BY tenure_bucket
ORDER BY tenure_bucket;

-- 3. Churn rate by support-ticket count (service-quality signal)
SELECT support_tickets,
       COUNT(*) AS customers,
       SUM(is_churned) AS churned,
       ROUND(100.0 * SUM(is_churned) / COUNT(*), 1) AS churn_rate_pct
FROM customers
GROUP BY support_tickets
ORDER BY support_tickets;

-- 4. Churn rate by monthly-charge bucket (price sensitivity)
SELECT CASE WHEN monthly_charges < 30 THEN 'a <30'
            WHEN monthly_charges < 50 THEN 'b 30-50'
            WHEN monthly_charges < 70 THEN 'c 50-70'
            ELSE 'd 70+' END AS charge_bucket,
       COUNT(*) AS customers,
       SUM(is_churned) AS churned,
       ROUND(100.0 * SUM(is_churned) / COUNT(*), 1) AS churn_rate_pct
FROM customers
GROUP BY charge_bucket
ORDER BY charge_bucket;

-- 5. Churn by service type and payment behaviour
SELECT internet_service,
       COUNT(*) AS customers,
       SUM(is_churned) AS churned,
       ROUND(100.0 * SUM(is_churned) / COUNT(*), 1) AS churn_rate_pct,
       ROUND(AVG(monthly_charges), 1) AS avg_monthly
FROM customers
GROUP BY internet_service
ORDER BY churn_rate_pct DESC;

SELECT autopay,
       COUNT(*) AS customers,
       SUM(is_churned) AS churned,
       ROUND(100.0 * SUM(is_churned) / COUNT(*), 1) AS churn_rate_pct
FROM customers
GROUP BY autopay;

-- 6. High-risk segment definition for retention team:
--    month-to-month + tenure < 12 months + 2+ support tickets
SELECT COUNT(*) AS segment_size,
       SUM(is_churned) AS churned,
       ROUND(100.0 * SUM(is_churned) / COUNT(*), 1) AS churn_rate_pct
FROM customers
WHERE contract_type = 'Month-to-month'
  AND tenure_months < 12
  AND support_tickets >= 2;

-- 7. Revenue at risk: MRR lost to churn
SELECT ROUND(SUM(monthly_charges), 0) AS mrr_lost_to_churn
FROM customers
WHERE is_churned = 1;
