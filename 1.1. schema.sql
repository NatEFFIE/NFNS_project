CREATE SCHEMA IF NOT EXISTS DS;



CREATE TABLE IF NOT EXISTS DS.FT_BALANCE_F(
    "on_date" DATE NOT NULL,
    "account_rk" BIGINT NOT NULL,
    "currency_rk" INTEGER,
    "balance_out" DECIMAL(12, 2)
);
ALTER TABLE
    DS.FT_BALANCE_F ADD PRIMARY KEY("on_date", "account_rk");


CREATE TABLE IF NOT EXISTS DS.MD_ACCOUNT_D(
    "data_actual_date" DATE NOT NULL,
    "data_actual_end_date" DATE NOT NULL,
    "account_rk" BIGINT NOT NULL,
    "account_number" VARCHAR(20) NOT NULL,
    "char_type" VARCHAR(1) NOT NULL,
    "currency_rk" INTEGER NOT NULL,
    "currency_code" VARCHAR(3) NOT NULL
);
ALTER TABLE
    DS.MD_ACCOUNT_D ADD PRIMARY KEY("data_actual_date", "account_rk");


CREATE TABLE IF NOT EXISTS DS.MD_EXCHANGE_RATE_D(
    "data_actual_date" DATE NOT NULL,
    "data_actual_end_date" DATE,
    "currency_rk" INTEGER NOT NULL,
    "reduced_cource" DECIMAL(12, 2),
    "code_iso_num" VARCHAR(3)
);
ALTER TABLE
    DS.MD_EXCHANGE_RATE_D ADD PRIMARY KEY("data_actual_date", "currency_rk");


CREATE TABLE IF NOT EXISTS DS.MD_CURRENCY_D(
    "currency_rk" INTEGER NOT NULL,
    "data_actual_date" DATE NOT NULL,
    "data_actual_end_date" DATE,
    "currency_code" VARCHAR(3),
    "code_iso_char" VARCHAR(3)
);
ALTER TABLE
    DS.MD_CURRENCY_D ADD PRIMARY KEY("currency_rk", "data_actual_date");


CREATE TABLE IF NOT EXISTS DS.FT_POSTING_F(
    "oper_date" DATE NOT NULL,
    "credit_account_rk" BIGINT NOT NULL,
    "debet_account_rk" BIGINT NOT NULL,
    "credit_amount" DECIMAL(12, 2),
    "debet_amount" DECIMAL(12, 2)
);


CREATE TABLE IF NOT EXISTS DS.MD_LEDGER_ACCOUNT_S(
    "chapter" CHAR(1),
    "chapter_name" VARCHAR(16),
    "section_number" BIGINT,
    "section_name" VARCHAR(22),
    "subsection_name" VARCHAR(21),
    "ledger1_account" BIGINT,
    "ledger1_account_name" VARCHAR(47),
    "ledger_account" BIGINT NOT NULL,
    "ledger_account_name" VARCHAR(153),
    "characteristic" CHAR(1),
    "start_date" DATE NOT NULL,
    "end_date" DATE
);
ALTER TABLE
    DS.MD_LEDGER_ACCOUNT_S ADD PRIMARY KEY("ledger_account", "start_date");

