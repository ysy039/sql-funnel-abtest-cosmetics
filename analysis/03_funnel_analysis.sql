-- 03_funnel_analysis.sql
USE cosmetics_db;

-------------------------------------------
-- 1. 세션별 퍼널 단계 도달 여부 정리
-------------------------------------------
WITH session_steps AS (
    SELECT
        user_session,
        MAX(CASE WHEN event_type = 'view'     THEN 1 ELSE 0 END) AS has_view,
        MAX(CASE WHEN event_type = 'cart'     THEN 1 ELSE 0 END) AS has_cart,
        MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS has_purchase
    FROM events
    GROUP BY user_session
)

SELECT * FROM session_steps
LIMIT 10;


-------------------------------------------
-- 2. 전체 퍼널 전환율
-------------------------------------------
WITH session_steps AS (
    SELECT
        user_session,
        MAX(CASE WHEN event_type = 'view'     THEN 1 ELSE 0 END) AS has_view,
        MAX(CASE WHEN event_type = 'cart'     THEN 1 ELSE 0 END) AS has_cart,
        MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS has_purchase
    FROM events
    GROUP BY user_session
)

SELECT
    COUNT(*)                                                   AS total_sessions,
    SUM(has_view)                                              AS sessions_with_view,
    SUM(has_cart)                                              AS sessions_with_cart,
    SUM(has_purchase)                                          AS sessions_with_purchase,
    ROUND(SUM(has_cart) * 100.0 / NULLIF(SUM(has_view), 0), 2)      AS conv_view_to_cart_pct,
    ROUND(SUM(has_purchase) * 100.0 / NULLIF(SUM(has_cart), 0), 2)  AS conv_cart_to_purchase_pct,
    ROUND(SUM(has_purchase) * 100.0 / NULLIF(SUM(has_view), 0), 2)  AS conv_view_to_purchase_pct
FROM session_steps;

-------------------------------------------
-- 3. 브랜드 정보를 활용한 세그먼트 퍼널
--    (브랜드가 있는 세션만, UNKNOWN 포함)
-------------------------------------------
WITH session_steps AS (
    SELECT
        user_session,
        MAX(CASE WHEN event_type = 'view'     THEN 1 ELSE 0 END) AS has_view,
        MAX(CASE WHEN event_type = 'cart'     THEN 1 ELSE 0 END) AS has_cart,
        MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS has_purchase
    FROM events
    GROUP BY user_session
),
session_brand AS (
    -- 각 세션에서 등장한 브랜드 중 하나를 대표 브랜드로 사용
    SELECT
        user_session,
        COALESCE(
            MAX(CASE WHEN brand IS NOT NULL AND brand <> '' THEN brand END),
            'UNKNOWN'
        ) AS main_brand
    FROM events
    GROUP BY user_session
)

SELECT
    sb.main_brand,
    COUNT(*)          AS sessions_total,
    SUM(ss.has_view)  AS sessions_with_view,
    SUM(ss.has_cart)  AS sessions_with_cart,
    SUM(ss.has_purchase) AS sessions_with_purchase,
    ROUND(SUM(ss.has_cart) * 100.0 / NULLIF(SUM(ss.has_view), 0), 2)     AS conv_view_to_cart_pct,
    ROUND(SUM(ss.has_purchase) * 100.0 / NULLIF(SUM(ss.has_cart), 0), 2) AS conv_cart_to_purchase_pct
FROM session_steps ss
JOIN session_brand sb ON ss.user_session = sb.user_session
GROUP BY sb.main_brand
HAVING COUNT(*) >= 100      -- 세션 수가 너무 적은 브랜드는 제외 (임계값은 조정 가능)
ORDER BY sessions_total DESC
LIMIT 10;
