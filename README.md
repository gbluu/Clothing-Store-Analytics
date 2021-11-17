# Clothing Company Analytics

Trong case-study này, với vai trò là Data Analyst cho một công ty cung cấp quần áo và trang phục dành cho người trẻ tuổi. Người quản lý đã yêu cầu 
hỗ trợ nhóm sản xuất phân tích hiệu suất sản phẩm và tạo một bản báo cáo tài chính cơ bản.

## Data Introduction
Bao gồm 2 bảng dữ liệu sau:

```Product Details``` : chứa toàn bộ thông tin về sản phẩm đang được bán của công ty.

```Product Sales``` : chứa toàn bộ thông tin về giao dịch đã được ghi nhận.


## Questions & Solutions

#### Sale Analysis


<details><summary>1. Tổng số lượng mỗi sản phẩm đã bán?</summary>

```sql
SELECT pd.product_name,
       Sum(s.qty) AS sale_count
FROM   clothing_store..sales AS s
       JOIN clothing_store..product_details AS pd
         ON pd.product_id = s.prod_id
GROUP  BY product_name
ORDER  BY sale_count DESC; 
```

|product_name                    |sale_count|
|--------------------------------|----------|
|Grey Fashion Jacket - Womens    |3876      |
|Navy Oversized Jeans - Womens   |3856      |
|Blue Polo Shirt - Mens          |3819      |
|White Tee Shirt - Mens          |3800      |
|Navy Solid Socks - Mens         |3792      |
|Black Straight Jeans - Womens   |3786      |
|Pink Fluro Polkadot Socks - Mens|3770      |
|Indigo Rain Jacket - Womens     |3757      |
|Khaki Suit Jacket - Womens      |3752      |
|Cream Relaxed Jeans - Womens    |3707      |
|White Striped Socks - Mens      |3655      |
|Teal Button Up Shirt - Mens     |3646      |

    
</details>


<details><summary>2. Doanh thu từng loại sản phẩm trước khi chiết khấu (discount)?</summary>

```sql
SELECT pd.product_name,
       Sum(s.qty * s.price) AS nodis_revenue
FROM   clothing_store..sales AS s
       JOIN clothing_store..product_details AS pd
         ON pd.product_id = s.prod_id
GROUP  BY pd.product_name
ORDER  BY nodis_revenue DESC; 
```

|product_name                    |nodis_revenue|
|--------------------------------|-------------|
|Blue Polo Shirt - Mens          |217683       |
|Grey Fashion Jacket - Womens    |209304       |
|White Tee Shirt - Mens          |152000       |
|Navy Solid Socks - Mens         |136512       |
|Black Straight Jeans - Womens   |121152       |
|Pink Fluro Polkadot Socks - Mens|109330       |
|Khaki Suit Jacket - Womens      |86296        |
|Indigo Rain Jacket - Womens     |71383        |
|White Striped Socks - Mens      |62135        |
|Navy Oversized Jeans - Womens   |50128        |
|Cream Relaxed Jeans - Womens    |37070        |
|Teal Button Up Shirt - Mens     |36460        |


    
</details>


<details><summary>3. Tổng giá discount là bao nhiêu?</summary>

```sql
SELECT Sum(price * qty * discount) / 100 AS total_discount
FROM   clothing_store..sales 
```

|total_discount                  |
|--------------------------------|
|156229                          |


</details>

#### Transaction Analysis


<details><summary>1. Có bao nhiêu hợp đồng đã được thực hiện?</summary>

```sql
SELECT Count(DISTINCT txn_id) AS unique_txn
FROM   clothing_store..sales; 
```

|unique_txn                      |
|--------------------------------|
|2500                            |


</details>

<details><summary>2. Trung bình sản phẩm trong mỗi hợp đồng?</summary>

```sql
WITH transaction_product
     AS (SELECT txn_id,
                Count(DISTINCT prod_id) AS product_count
         FROM   clothing_store..sales
         GROUP  BY txn_id)
SELECT Round(Avg(product_count), 0) AS avg_transaction_product
FROM   transaction_product; 
```

|avg_transaction_product         |
|--------------------------------|
|6                               |

</details>

<details><summary>3. Trung bình discount trong mỗi hợp đồng?</summary>

```sql
WITH transaction_product
     AS (SELECT txn_id,
                Count(DISTINCT prod_id) AS product_count
         FROM   clothing_store..sales
         GROUP  BY txn_id)
SELECT Round(Avg(product_count), 0) AS avg_transaction_product
FROM   transaction_product; 
```

|avg_txn_discount                |
|--------------------------------|
|62                              |


</details>

<details><summary>4. Doanh thu trung bình của 2 nhóm ("member" và "non-member")?</summary>

```sql
WITH member_revenue
     AS (SELECT member,
                txn_id,
                Sum(Cast(price AS FLOAT) * qty) AS revenue
         FROM   clothing_store..sales
         GROUP  BY member,
                   txn_id)
SELECT member,
       Round(Avg(revenue), 2) AS avg_revenue
FROM   member_revenue
GROUP  BY member; 
```

|member                          |avg_revenue|
|--------------------------------|-----------|
|f                               |515.04     |
|t                               |516.27     |

</details>

#### Product Analysis

1. Top 3 sản phẩm theo doanh thu trước khi discount?
2. Tổng số lượng, doanh thu và discount từng phân khúc sản phẩm (segment)?
3. Sản phẩm bán chạy nhất cho từng phân khúc?
4. Tổng số lượng, doanh thu và discount cho từng loại doanh mục (category)?
5. Sản phẩm bán chạy nhất cho mỗi danh mục?
6. Tỷ lệ doanh thu (%) theo sản phẩm cho từng phân khúc?
7. Tỷ lệ doanh thu (%) theo phân khúc cho từng danh mục?
8. Tỷ lệ (%) của tổng doanh thu theo danh mục?
9. Tỉ lệ thâm nhập thị trường cho mỗi sản phẩm ?
