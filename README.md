# ysy_portfolio
----퍼널 분석 – 분석 목표 & 방법----
1. 분석 목표

화장품 쇼핑몰의 “한 세션”이 얼마나 아래 단계까지 내려가는지 보는 것:

view : 제품을 본 적이 있는 세션 수

cart : 장바구니에 담은 적이 있는 세션 수

purchase : 구매까지 완료한 세션 수

궁극적으로 알고 싶은 것

-> 전체 세션 중 view → cart 전환율, cart → purchase 전환율, view → purchase 최종 전환율

추가로, 브랜드/카테고리는 결측이 많으니 값이 있는 부분만 활용해서 브랜드별 / 카테고리별로 어느 정도 차이가 있는지 맛보기 정도

2. 퍼널 분석용 핵심 아이디어

단위는 세션(user_session) 으로 잡고 각 세션에서 view가 한 번이라도 있었는지, cart가 한 번이라도 있었는지, purchase가 한 번이라도 있었는지를 체크하고, 단계별로 “해당 단계까지 도달한 세션 수”를 카운트한다.


# SQL Funnel & Pre/Post Analysis – Cosmetics E-commerce

## 1. 프로젝트 개요
- 데이터: 화장품 전자상거래 매장의 이벤트 로그 (view, cart, remove_from_cart, purchase)
- 목표:
  1) 세션 단위 퍼널(view → cart → purchase) 분석
  2) 기준 날짜 전/후 세션을 A/B 그룹처럼 나누어 전환율을 비교하는 quasi A/B 분석

## 2. 데이터 설명
주요 컬럼:
- `event_time` : 이벤트 발생 시각 (UTC)
- `event_type` : view / cart / remove_from_cart / purchase
- `product_id` : 제품 ID
- `category_id`, `category_code` : 카테고리 정보 (결측 다수)
- `brand` : 상표 (약 50% 결측)
- `price` : 상품 가격
- `user_id` : 사용자 ID
- `user_session` : 사용자 세션 ID
<img width="761" height="516" alt="스크린샷 2025-11-14 133817" src="https://github.com/user-attachments/assets/9aa2bf30-e24a-43a6-b360-e5990a4a1e86" />

카테고리 코드와 브랜드는 결측이 많기 때문에,
퍼널의 기본 구조는 `user_session` + `event_type` 기준으로 분석하고,
브랜드/카테고리는 보조적인 세그먼트 분석에만 활용하였다.

## 3. 파일 구조
- `schema/01_create_table.sql` : MySQL DB 및 `events` 테이블 스키마 정의
- `data/02_load_data_example.sql` : CSV 데이터를 `events` 테이블에 적재하는 예시
- `analysis/03_funnel_analysis.sql` : 퍼널 전환율 분석 SQL
- `analysis/04_ab_test_pre_post.sql` : 날짜 기준 전/후 그룹의 퍼널 비교 SQL

## 4. 주요 분석 내용

### 4-1. 퍼널 분석
- 단위: `user_session` (한 세션 동안의 행동 흐름)
- 단계:
  1. `view` : 상품 조회
  2. `cart` : 장바구니 추가
  3. `purchase` : 구매 완료

- SQL로 각 세션이 단계별로 도달했는지(has_view, has_cart, has_purchase)를 계산한 후,
  전체 세션 기준으로 전환율을 계산하였다.
<img width="1500" height="1013" alt="스크린샷 2025-11-14 143234" src="https://github.com/user-attachments/assets/b15bb2cf-deb2-4122-85a6-189691ef4c08" />

예시 지표:
- view → cart 전환율
- cart → purchase 전환율
- view → purchase 전체 전환율
- 브랜드 정보가 있는 세션 subset 을 사용하여 브랜드별 퍼널 비교
<img width="1453" height="919" alt="스크린샷 2025-11-14 142950" src="https://github.com/user-attachments/assets/f00ac7d2-baca-460f-8f77-08928b3b017b" />

## 5. 사용 기술
- MySQL
- SQL (CTE, 조건부 집계, 그룹별 전환율 계산)
- GitHub를 이용한 포트폴리오 관리

## 📂 Project Structure

```text
sql-funnel-abtest-cosmetics/
 ├─ schema/
 │   └─ 01_create_table.sql
 ├─ data/
 │   └─ 02_load_data_example.sql
 ├─ analysis/
 │  └─ 03_funnel_analysis.sql
 └─ README.md


