
-- 1) Drop any existing relation named sales/SALES in any schema
DROP SCHEMA IF EXISTS short_sales CASCADE;
CREATE SCHEMA short_sales;


-- 3) Create your SALES table
CREATE TABLE IF NOT EXISTS short_sales.sales (
    sale_id        INT PRIMARY KEY,
    customer_id    INT NOT NULL,
    product_id     INT NOT NULL,
    quantity       INT NOT NULL,
    unit_price     DECIMAL(10, 2) NOT NULL,
    sale_date      DATE NOT NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4) Fidessa Accounts (stub for view used by procedure)
CREATE TABLE IF NOT EXISTS short_sales.v_jds_fidessa_accounts (
    book_id              text PRIMARY KEY,
    primary_trader       text,
    description          text,
    dealing_capacity     text,
    firm_account         text,
    split_book           text,
    commission_book      text,
    parent_book_code     text,
    aggregation_unit     text,
    book_value_limit     text,
    net_value_limit      text,
    long_value_limit     text,
    short_value_limit    text,
    last_modified_by     text,
    firm_account_2       text,
    status               text,
    fdid_code            text,
    book_view_code       text,
    wash_book            text,
    net_pl_value_limit   text
);

-- 5) Event tables
CREATE TABLE IF NOT EXISTS short_sales.ss_fidessa_cancel (
    sourcesystem      varchar(10),
    type              char(25),
    business_date     date,
    datetime          timestamp(9),
    orderid           varchar(255),
    symbol            varchar(1020),
    side              varchar(255),
    price             varchar(255),
    quantity          varchar(255),
    mquant            varchar(40),
    book              varchar(255),
    aggregation_unit  text,
    capacity          varchar(255),
    uniqueid          varchar(255)
);

CREATE TABLE IF NOT EXISTS short_sales.ss_fidessa_jdoe_executions (
    sourcesystem      varchar(10),
    type              char(25),
    business_date     date,
    datetime          timestamp(9),
    orderid           varchar(255),
    symbol            varchar(1020),
    side              varchar(255),
    price             varchar(255),
    quantity          varchar(255),
    mquant            varchar(40),
    book              varchar(255),
    aggregation_unit  text,
    capacity          varchar(255),
    uniqueid          varchar(255)
);

CREATE TABLE IF NOT EXISTS short_sales.ss_fidessa_routes (
    sourcesystem      varchar(10),
    type              char(25),
    business_date     date,
    datetime          timestamp(9),
    orderid           varchar(255),
    symbol            varchar(1020),
    side              varchar(255),
    price             varchar(255),
    quantity          varchar(255),
    mquant            varchar(40),
    book              varchar(255),
    aggregation_unit  text,
    capacity          varchar(255),
    uniqueid          varchar(255)
);

CREATE TABLE IF NOT EXISTS short_sales.ss_jdoe_routes (
    sourcesystem      varchar(10),
    type              char(25),
    business_date     date,
    datetime          timestamp(9),
    orderid           varchar(255),
    symbol            varchar(1020),
    side              varchar(255),
    price             varchar(255),
    quantity          varchar(255),
    mquant            varchar(40),
    book              varchar(255),
    aggregation_unit  text,
    uniqueid          varchar(255)
);

-- 6) SOD positions
CREATE TABLE IF NOT EXISTS short_sales.ss_sod_positions (
    symbol            varchar(1020),
    aggregation_unit  text,
    sod               numeric,
    processing_date   date
);

-- 7) Staging positions
CREATE TABLE IF NOT EXISTS short_sales.stg_fid_us_position (
    ip_rec_num                 bigint,
    book_primary_trader        varchar(255),
    book_code                  varchar(255),
    firm_account               varchar(255),
    instrument_code            varchar(255),
    csip_code                  varchar(50),
    description                text,
    net_position               numeric,
    average_cost               numeric,
    valuation_price            numeric,
    net_pl                     numeric,
    realised_pl                numeric,
    unrealised_pl              numeric,
    mtd_pl                     numeric,
    daily_sc                   numeric,
    mtd_sc                     numeric,
    comm                       numeric,
    mtd_comm                   numeric,
    closing_bid                numeric,
    closing_offer              numeric,
    last_trade_price_marked    numeric,
    spc_crd                    numeric,
    mtd_spc_crd                numeric,
    ytd_spc_crd                numeric,
    ytd_pl                     numeric,
    ytd_sc                     numeric,
    ytd_comm                   numeric,
    valuation_strategy         varchar(50),
    average_price              numeric,
    true_average_price         numeric,
    value                      numeric,
    long_price                 numeric,
    short_price                numeric,
    pre_rollover_realised_pl   numeric,
    currency                   varchar(10),
    instrument_id              bigint,
    sedl_code                  varchar(50),
    isin_code                  varchar(50),
    filename                   text,
    business_date              date,
    load_type                  varchar(50),
    source_system_key          integer,
    source_instance_key        integer,
    audit_insert_user          varchar(100),
    audit_insert_date          timestamp(9),
    instrument_type            varchar(20),
    daily_markup               numeric,
    mtd_markup                 numeric,
    ytd_markup                 numeric,
    ytd_realised_pl            numeric,
    instrument_id_src          varchar(50)
);

CREATE INDEX IF NOT EXISTS ix_stg_fid_us_position_book_code
    ON short_sales.stg_fid_us_position (book_code);

CREATE INDEX IF NOT EXISTS ix_stg_fid_us_position_instrument_code
    ON short_sales.stg_fid_us_position (instrument_code);

-- 8) Procedure: populate SOD positions
CREATE OR REPLACE PROCEDURE short_sales.sp_ss_sod_positions()
LANGUAGE plpgsql
AS $proc$
BEGIN
    TRUNCATE TABLE short_sales.ss_sod_positions;

    INSERT INTO short_sales.ss_sod_positions (symbol, aggregation_unit, sod, processing_date)
    SELECT
        symbol,
        aggregation_unit,
        SUM(net_position)::numeric AS sod,
        business_date
    FROM (
        SELECT
            a.instrument_code,
            split_part(a.instrument_code, '.', 1) AS symbol,
            a.book_code,
            a.net_position,
            a.business_date,
            b.aggregation_unit
        FROM short_sales.stg_fid_us_position AS a
        LEFT JOIN short_sales.v_jds_fidessa_accounts AS b
          ON a.book_code = b.book_id
        WHERE a.instrument_code LIKE '%.US'
    ) t
    WHERE aggregation_unit IS NOT NULL
    GROUP BY symbol, aggregation_unit, business_date;
END;
$proc$;
