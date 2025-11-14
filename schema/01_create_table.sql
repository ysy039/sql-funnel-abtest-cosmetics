-- 01_create_table.sql
-- 화장품 전자상거래 이벤트 로그 테이블 생성

CREATE DATABASE IF NOT EXISTS cosmetics_db
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE cosmetics_db;

DROP TABLE IF EXISTS events;

CREATE TABLE events (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,  -- 내부용 PK
    event_time     DATETIME       NOT NULL,            -- 이벤트_시간 (UTC)
    event_type     VARCHAR(20)    NOT NULL,            -- view / cart / remove_from_cart / purchase
    product_id     BIGINT         NULL,                -- 제품_ID
    category_id    BIGINT         NULL,                -- 카테고리_아이디 (결측 많음)
    category_code  VARCHAR(255)   NULL,                -- 카테고리_코드 (거의 결측)
    brand          VARCHAR(255)   NULL,                -- 상표 (약 50% 결측)
    price          DECIMAL(10,2)  NULL,                -- 가격
    user_id        BIGINT         NULL,                -- 사용자_아이디
    user_session   VARCHAR(255)   NULL                 -- 사용자_세션
);

-- 쿼리 속도 향상을 위한 인덱스 (선택이지만 추천)
CREATE INDEX idx_events_time       ON events(event_time);
CREATE INDEX idx_events_session    ON events(user_session);
CREATE INDEX idx_events_type       ON events(event_type);
CREATE INDEX idx_events_brand      ON events(brand);
