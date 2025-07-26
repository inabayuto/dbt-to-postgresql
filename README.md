# dbt-to-postgresql

PostgreSQL環境でdbt（data build tool）を使用したデータ変換プロジェクトです。Docker環境で簡単にセットアップできます。

## 概要
このリポジトリは、PostgreSQL環境でdbtを使用したデータ変換処理のためのDocker環境のサンプルです。顧客注文データを分析するdbtモデルの実装例を含みます。

## ディレクトリ構成
```
dbt-to-postgresql/
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── profiles.yml
├── dbt/ (空のフォルダ)
└── README.md
```

## 必要条件
- Docker, Docker Compose
- Git

## セットアップ手順

### 1. リポジトリのクローン
```bash
git clone <repository-url>
cd dbt-to-postgresql
```

### 2. Docker環境の起動
```bash
docker compose up --build -d
```

### 3. dbtコンテナへの接続
```bash
docker exec -it my_dbt bash
```

### 4. dbtプロジェクトの初期化
```bash
dbt init dbt_dev
cd dbt_dev
```

### 5. 接続テスト
```bash
dbt debug
```
`Connection test: [OK connection ok]`と表示されれば接続成功です。

## サンプルデータの準備

### 1. シードデータの配置
[dbt公式チュートリアル](https://docs.getdbt.com/tutorial/setting-up)から以下のCSVファイルを`seeds/`ディレクトリに配置してください：

- `raw_customers.csv`
- `raw_orders.csv`
- `raw_payments.csv`

### 2. データのロード
```bash
dbt seed
```

## dbtモデルの作成

### 1. モデルファイルの作成
`models/`ディレクトリに`customer_orders_analysis.sql`を作成：

```sql
WITH customers AS (
    SELECT id AS customer_id, first_name, last_name
    FROM {{ ref('raw_customers') }}
),
orders AS (
    SELECT id AS order_id, user_id AS customer_id, order_date, status
    FROM {{ ref('raw_orders') }}
),
customer_orders AS (
    SELECT customer_id,
           MIN(order_date) AS first_order_date,
           MAX(order_date) AS most_recent_order_date,
           COUNT(order_id) AS number_of_orders
    FROM orders GROUP BY 1
),
final AS (
    SELECT customers.customer_id, customers.first_name, customers.last_name,
           customer_orders.first_order_date, customer_orders.most_recent_order_date,
           COALESCE(customer_orders.number_of_orders, 0) AS number_of_orders
    FROM customers LEFT JOIN customer_orders USING (customer_id)
)
SELECT * FROM final
```

### 2. スキーマファイルの作成
`models/schema.yml`を作成：

```yaml
version: 2
models:
  - name: customer_orders_analysis
    description: "顧客の注文履歴を分析するモデル"
    columns:
      - name: customer_id
        description: "顧客ID（主キー）"
        tests: [unique, not_null]
      - name: first_name
        description: "顧客の名"
        tests: [not_null]
      - name: last_name
        description: "顧客の姓"
        tests: [not_null]
      - name: number_of_orders
        description: "注文回数"
        tests: [not_null]
```

## dbtコマンドの実行

### モデルの実行
```bash
dbt run --models customer_orders_analysis
```

### テストの実行
```bash
dbt test --models customer_orders_analysis
```

### 全モデルの実行
```bash
dbt run
dbt test
dbt build
```

## データの確認

### PostgreSQLへの接続
DBeaverなどのデータベースクライアントを使用してPostgreSQLに接続：

- **Host**: localhost
- **Port**: 5432
- **Database**: dbt_dev
- **Username**: test_user
- **Password**: test_pass

### データの確認
```sql
SELECT * FROM customer_orders_analysis LIMIT 10;
SELECT COUNT(*) FROM raw_customers;
SELECT COUNT(*) FROM raw_orders;
SELECT COUNT(*) FROM raw_payments;
```

## 主な利用技術
- dbt-postgres
- PostgreSQL
- Docker
- Python

## 参考
- [dbt公式ドキュメント](https://docs.getdbt.com/)
- [PostgreSQL公式ドキュメント](https://www.postgresql.org/docs/)
- [Docker公式ドキュメント](https://docs.docker.com/)

---

何か問題があればIssueまたはPull Requestでご連絡ください。 