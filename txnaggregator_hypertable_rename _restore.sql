

#psql -Upostgres -h 127.0.0.1 -p 5665 -Um2pdba aggregator_DCMSSURYODAYBNK -c "COPY (select * from public.transaction ) TO '/backup/m2p331/transaction.csv';"

#nohup sudo -u postgres psql --port 4554 -d db2dba -c "\copy public.t1 from /backup/m2p331/transaction.csv ;"

\c aggregator_DCMSSURYODAYBNK;

Drop MATERIALIZED VIEW txn_aggregation_entityid_overall_daily;
Drop MATERIALIZED VIEW corporate_balance_aggregation_overall;

-----------------------------------------------------------------------------------------

drop index index_account_number;
drop index index_created;
drop index index_entity_id;
drop index index_kit_no;
drop index index_mcc;
drop index index_merchant;
drop index index_txn_origin;
drop index index_txn_type;
drop index ix_ext_txn_id;
drop index ix_exttxn_created;
drop index ix_txn_entity_crdr;

-----------------------------------------------------------------------------------------

alter table transaction rename to temptb;


-----------------------------------------------------------------------------------------

create table transaction
(
    pkey                 varchar(100) not null,
    created_by           varchar(50)  not null,
    created_date         timestamp    not null,
    last_modified_by     varchar(50),
    last_modified_date   timestamp,
    entity_id            varchar(255),
    account_number       varchar(255),
    actual_txn_amount    varchar(255),
    amount               double precision,
    kit_no               varchar(255),
    product_id           varchar(255),
    transaction_type     varchar(255),
    cr_dr                varchar(255),
    description          varchar(255),
    ext_txn_id           varchar(255),
    int_txn_id           varchar(255),
    terminal_id          varchar(255),
    mcc                  varchar(255),
    merchant             varchar(255) default ''::character varying,
    merchant_id          varchar(255),
    merchant_name        varchar(255),
    merchant_location    varchar(255),
    acquirer_id          varchar(255),
    txn_crncy_cde        varchar(255),
    txn_origin           varchar(255),
    auth_code            varchar(255),
    rrn                  varchar(255),
    stan                 varchar(255),
    currency_cde         varchar(255),
    account_currency_cde varchar(255),
    country_cde          varchar(255),
    univ_crncy_amt       varchar(255),
    network              varchar(255),
    txn_fees             double precision,
    service_tax          double precision,
    transaction_status   varchar(255),
    international        boolean      default false,
    effective_count      integer      default 1,
    on_us                integer      default 0,
    metro                integer      default 0,
    txn_created_time     varchar(100),
    request_processed    boolean      default false
);


-----------------------------------------------------------------------------------------

create index index_created
    on transaction (created_date);

create index index_entity_id
    on transaction (entity_id);

create index index_account_number
    on transaction (account_number);

create index index_kit_no
    on transaction (kit_no);

create index index_txn_origin
    on transaction (txn_origin);

create index index_mcc
    on transaction (mcc);

create index index_txn_type
    on transaction (transaction_type);

create index index_merchant
    on transaction (merchant);

create index ix_txn_entity_crdr
    on transaction (entity_id, cr_dr);

create index ix_exttxn_created
    on transaction (ext_txn_id, txn_created_time);

-----------------------------------------------------------------------------------------

SELECT create_hypertable('transaction','created_date', chunk_time_interval => INTERVAL '90 days');

-----------------------------------------------------------------------------------------

NOTE : Create MQTs with Application as owner (m2pappusr)

CREATE MATERIALIZED VIEW txn_aggregation_entityid_overall_daily
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('1 day', "created_date") AS bucket,
  t.entity_id,
  t.txn_origin,
  t.transaction_type AS txn_type,
  t.cr_dr,
  t.mcc,
  t.kit_no,
  t.account_number,
  t.international,
  t.merchant,
  t.on_us,
  t.metro,
  SUM(t.amount) AS daily_sum,
  SUM(t.effective_count) AS daily_count
FROM transaction t
GROUP BY t.entity_id, t.txn_origin, t.transaction_type, t.mcc, t.merchant, t.kit_no, t.account_number,
t.international, t.cr_dr, t.on_us, t.metro, bucket WITH NO DATA;

-----------------------------------------------------------------------------------------

CREATE MATERIALIZED VIEW corporate_balance_aggregation_overall
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('365 days', "created_date") AS bucket,
  t.entity_id as corporate,
  t.account_number,
  SUM(t.amount) AS overall_sum,
  COUNT(t.pkey) AS overall_count
FROM transaction t
GROUP BY bucket, corporate, t.account_number WITH NO DATA;


-----------------------------------------------------------------------------------------

insert into transaction select * from temptb; #10min

-----------------------------------------------------------------------------------------
ALTER MATERIALIZED VIEW public.txn_aggregation_entityid_overall_daily set (timescaledb.materialized_only = false);

ALTER MATERIALIZED VIEW public.corporate_balance_aggregation_overall set (timescaledb.materialized_only = false);

-----------------------------------------------------------------------------------------
alter table transaction owner to m2pappusr;
alter table txn_aggregation_entityid_overall_daily owner to m2pappusr;
alter table corporate_balance_aggregation_overall owner to m2pappusr;


//Verify Privileges//
SELECT schemaname AS table_schema,
       tablename AS table_name,
       tableowner AS table_owner,
       CASE
           WHEN schemaname = 'public' THEN 'table'
           ELSE 'view'
       END AS table_type
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
  AND tableowner = 'db2dba';
-----------------------------------------------------------------------------------------


\c aggregator_MASTER;


INSERT INTO public.tenant (id, "name", db_name, db_url, db_user, db_password, encryption_key, hcsm_index, min_pool_size, max_pool_size, created_by, created_date, last_modified_by, last_modified_date, zone_id) VALUES('5921bf1b-f7cf-4cf0-af32-19d34b999a38', 'DCMSSURYODAYBNK', NULL, 'jdbc:postgresql://postgres-db-02:5665/aggregator_DCMSSURYODAYBNK', NULL, NULL, NULL, NULL, 3, 20, 'vignesh', NOW(), 'vignesh', NOW(), NULL);



select count(1) from txn_aggregation_entityid_overall_daily;
select count(1) from corporate_balance_aggregation_overall;



aggregator_DCMSSURYODAYBNK=# explain select * from txn_aggregation_entityid_overall_daily where entity_id = '180528105' and cr_dr = 'D';
                                                                                                          QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 HashAggregate  (cost=2151.95..2156.95 rows=400 width=89)
   Group Key: t.entity_id, t.txn_origin, t.transaction_type, t.mcc, t.merchant, t.kit_no, t.account_number, t.international, t.cr_dr, t.on_us, t.metro, time_bucket('1 day'::interval, t.created_date)
   ->  Custom Scan (ChunkAppend) on transaction t  (cost=4.31..2133.22 rows=535 width=85)
         Chunks excluded during startup: 0
         ->  Bitmap Heap Scan on _hyper_13_363_chunk t_1  (cost=4.31..15.87 rows=3 width=77)
               Recheck Cond: ((entity_id)::text = '180528105'::text)
               Filter: (((cr_dr)::text = 'D'::text) AND (created_date >= COALESCE(_timescaledb_functions.to_timestamp_without_timezone(_timescaledb_functions.cagg_watermark(14)), '-infinity'::timestamp without time zone)))
               ->  Bitmap Index Scan on _hyper_13_363_chunk_index_entity_id  (cost=0.00..4.31 rows=3 width=0)
                     Index Cond: ((entity_id)::text = '180528105'::text)
         ->  Index Scan using _hyper_13_364_chunk_index_entity_id on _hyper_13_364_chunk t_2  (cost=0.42..67.87 rows=17 width=80)
               Index Cond: ((entity_id)::text = '180528105'::text)
               Filter: (((cr_dr)::text = 'D'::text) AND (created_date >= COALESCE(_timescaledb_functions.to_timestamp_without_timezone(_timescaledb_functions.cagg_watermark(14)), '-infinity'::timestamp without time zone)))
         ->  Index Scan using _hyper_13_365_chunk_index_entity_id on _hyper_13_365_chunk t_3  (cost=0.42..176.77 rows=44 width=80)
               Index Cond: ((entity_id)::text = '180528105'::text)
               Filter: (((cr_dr)::text = 'D'::text) AND (created_date >= COALESCE(_timescaledb_functions.to_timestamp_without_timezone(_timescaledb_functions.cagg_watermark(14)), '-infinity'::timestamp without time zone)))
         ->  Bitmap Heap Scan on _hyper_13_366_chunk t_4  (cost=4.96..275.85 rows=69 width=83)
               Recheck Cond: ((entity_id)::text = '180528105'::text)
               Filter: (((cr_dr)::text = 'D'::text) AND (created_date >= COALESCE(_timescaledb_functions.to_timestamp_without_timezone(_timescaledb_functions.cagg_watermark(14)), '-infinity'::timestamp without time zone)))
               ->  Bitmap Index Scan on _hyper_13_366_chunk_index_entity_id  (cost=0.00..4.95 rows=69 width=0)
                     Index Cond: ((entity_id)::text = '180528105'::text)
         ->  Index Scan using _hyper_13_367_chunk_index_entity_id on _hyper_13_367_chunk t_5  (cost=0.43..326.59 rows=82 width=83)
               Index Cond: ((entity_id)::text = '180528105'::text)
               Filter: (((cr_dr)::text = 'D'::text) AND (created_date >= COALESCE(_timescaledb_functions.to_timestamp_without_timezone(_timescaledb_functions.cagg_watermark(14)), '-infinity'::timestamp without time zone)))
         ->  Bitmap Heap Scan on _hyper_13_368_chunk t_6  (cost=4.88..236.97 rows=59 width=81)
               Recheck Cond: ((entity_id)::text = '180528105'::text)
               Filter: (((cr_dr)::text = 'D'::text) AND (created_date >= COALESCE(_timescaledb_functions.to_timestamp_without_timezone(_timescaledb_functions.cagg_watermark(14)), '-infinity'::timestamp without time zone)))
               ->  Bitmap Index Scan on _hyper_13_368_chunk_index_entity_id  (cost=0.00..4.87 rows=59 width=0)
                     Index Cond: ((entity_id)::text = '180528105'::text)
         ->  Index Scan using _hyper_13_369_chunk_index_entity_id on _hyper_13_369_chunk t_7  (cost=0.43..269.42 rows=67 width=85)
               Index Cond: ((entity_id)::text = '180528105'::text)
               Filter: (((cr_dr)::text = 'D'::text) AND (created_date >= COALESCE(_timescaledb_functions.to_timestamp_without_timezone(_timescaledb_functions.cagg_watermark(14)), '-infinity'::timestamp without time zone)))
         ->  Bitmap Heap Scan on _hyper_13_370_chunk t_8  (cost=5.93..762.56 rows=194 width=88)
               Recheck Cond: ((entity_id)::text = '180528105'::text)
               Filter: (((cr_dr)::text = 'D'::text) AND (created_date >= COALESCE(_timescaledb_functions.to_timestamp_without_timezone(_timescaledb_functions.cagg_watermark(14)), '-infinity'::timestamp without time zone)))
               ->  Bitmap Index Scan on _hyper_13_370_chunk_index_entity_id  (cost=0.00..5.88 rows=194 width=0)
                     Index Cond: ((entity_id)::text = '180528105'::text)
(36 rows)

