# Clothing Company Analytics

Trong case-study này, với vai trò là Data Analyst cho một công ty cung cấp quần áo và trang phục dành cho người trẻ tuổi. Người quản lý đã yêu cầu 
hỗ trợ nhóm sản xuất phân tích hiệu suất sản phẩm và tạo một bản báo cáo tài chính cơ bản.

Dùng SQL Server và Power BI để visualize data.

## Data Introduction
Bao gồm 2 bảng dữ liệu sau:

```Product Details``` : chứa toàn bộ thông tin về sản phẩm đang được bán của công ty.

```Product Sales``` : chứa toàn bộ thông tin về giao dịch đã được ghi nhận.


## Questions & Solutions

### Sale Analysis


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

### Transaction Analysis


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

### Product Analysis


<details><summary>1. Top 3 sản phẩm theo doanh thu trước khi discount?</summary>

```sql
SELECT   pd.product_name,
         Sum(s.price * s.qty)            AS nodis_revenue
FROM     clothing_store..sales           AS s
JOIN     clothing_store..product_details AS pd
ON       s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY nodis_revenue DESC offset 0 rowsFETCH first 3 rows only;
```

|product_name                    |nodis_revenue|
|--------------------------------|-------------|
|Blue Polo Shirt - Mens          |217683       |
|Grey Fashion Jacket - Womens    |209304       |
|White Tee Shirt - Mens          |152000       |

</details>


<details><summary>2. Tổng số lượng, doanh thu và discount từng phân khúc sản phẩm (segment)?</summary>

```sql
SELECT pd.segment_id,
       pd.segment_name,
       Sum(s.qty)                              AS total_quantity,
       Sum(s.qty * s.price)                    AS total_revenue,
       Sum(s.qty * s.price * s.discount) / 100 AS total_discount
FROM   clothing_store..product_details AS pd
       JOIN clothing_store..sales AS s
         ON pd.product_id = s.prod_id
GROUP  BY pd.segment_id,
          pd.segment_name
ORDER  BY total_revenue DESC; 
```

|segment_id                      |segment_name|total_quantity|total_revenue|total_discount|
|--------------------------------|------------|--------------|-------------|--------------|
|5                               |Shirt       |11265         |406143       |49594         |
|4                               |Jacket      |11385         |366983       |44277         |
|6                               |Socks       |11217         |307977       |37013         |
|3                               |Jeans       |11349         |208350       |25343         |


</details>


<details><summary>3. Sản phẩm bán chạy nhất cho từng phân khúc?</summary>

```sql
SELECT   pd.segment_id,
         pd.segment_name,
         pd.product_id,
         pd.product_name,
         Sum(s.qty)                      AS product_quantity
FROM     clothing_store..product_details AS pd
JOIN     clothing_store..sales           AS s
ON       pd.product_id = s.prod_id
GROUP BY pd.segment_id,
         pd.segment_name,
         pd.product_id,
         pd.product_name
ORDER BY product_quantity DESC offset 0 rowsFETCH first 5 rows only;
```

|segment_id                      |segment_name|product_id|product_name|product_quantity|
|--------------------------------|------------|----------|------------|----------------|
|4                               |Jacket      |9ec847    |Grey Fashion Jacket - Womens|3876            |
|3                               |Jeans       |c4a632    |Navy Oversized Jeans - Womens|3856            |
|5                               |Shirt       |2a2353    |Blue Polo Shirt - Mens|3819            |
|5                               |Shirt       |5d267b    |White Tee Shirt - Mens|3800            |
|6                               |Socks       |f084eb    |Navy Solid Socks - Mens|3792            |



</details>

<details><summary>4. Tổng số lượng, doanh thu và discount cho từng loại doanh mục (category)?
</summary>

```sql
SELECT pd.category_id,
       pd.category_name,
       Sum(s.qty)                              AS total_quantity,
       Sum(s.qty * s.price)                    AS total_revenue,
       Sum(s.qty * s.price * s.discount) / 100 AS total_discount
FROM   clothing_store..product_details AS pd
       JOIN clothing_store..sales AS s
         ON pd.product_id = s.prod_id
GROUP  BY pd.category_id,
          pd.category_name
ORDER  BY total_revenue DESC; 
```

|category_id                     |category_name|total_quantity|total_revenue|total_discount|
|--------------------------------|-------------|--------------|-------------|--------------|
|2                               |Mens         |22482         |714120       |86607         |
|1                               |Womens       |22734         |575333       |69621         |


</details>

<details><summary>5. Sản phẩm bán chạy nhất cho mỗi danh mục?</summary>

```sql
SELECT   pd.category_id,
         pd.category_name,
         pd.product_id,
         pd.product_name,
         Sum(s.qty)                      AS product_quantity
FROM     clothing_store..product_details AS pd
JOIN     clothing_store..sales           AS s
ON       pd.product_id = s.prod_id
GROUP BY pd.category_id,
         pd.category_name,
         pd.product_id,
         pd.product_name
ORDER BY product_quantity DESC offset 0 rowsFETCH first 5 rows only;
```

|category_id                     |category_name|product_id|product_name|product_quantity|
|--------------------------------|-------------|----------|------------|----------------|
|1                               |Womens       |9ec847    |Grey Fashion Jacket - Womens|3876            |
|1                               |Womens       |c4a632    |Navy Oversized Jeans - Womens|3856            |
|2                               |Mens         |2a2353    |Blue Polo Shirt - Mens|3819            |
|2                               |Mens         |5d267b    |White Tee Shirt - Mens|3800            |
|2                               |Mens         |f084eb    |Navy Solid Socks - Mens|3792            |

</details>


<details><summary>6. Tỷ lệ doanh thu (%) theo sản phẩm cho từng phân khúc?</summary>

```sql
WITH product_revenue
     AS (SELECT pd.segment_id,
                pd.segment_name,
                pd.product_id,
                pd.product_name,
                Sum(s.qty * s.price) AS product_revenue
         FROM   clothing_store..product_details AS pd
                JOIN clothing_store..sales AS s
                  ON pd.product_id = s.prod_id
         GROUP  BY pd.segment_id,
                   pd.segment_name,
                   pd.product_id,
                   pd.product_name)
SELECT segment_name,
       product_name,
       Round(100 * Cast(product_revenue AS FLOAT) / Sum(product_revenue)
                                                      OVER(
                                                        partition BY segment_id)
       , 2) AS
       segment_product_percentage
FROM   product_revenue
ORDER  BY segment_id,
          segment_product_percentage DESC; 
```

|segment_name                    |product_name|segment_product_percentage|
|--------------------------------|------------|--------------------------|
|Jeans                           |Black Straight Jeans - Womens|58.15                     |
|Jeans                           |Navy Oversized Jeans - Womens|24.06                     |
|Jeans                           |Cream Relaxed Jeans - Womens|17.79                     |
|Jacket                          |Grey Fashion Jacket - Womens|57.03                     |
|Jacket                          |Khaki Suit Jacket - Womens|23.51                     |
|Jacket                          |Indigo Rain Jacket - Womens|19.45                     |
|Shirt                           |Blue Polo Shirt - Mens|53.6                      |
|Shirt                           |White Tee Shirt - Mens|37.43                     |
|Shirt                           |Teal Button Up Shirt - Mens|8.98                      |
|Socks                           |Navy Solid Socks - Mens|44.33                     |
|Socks                           |Pink Fluro Polkadot Socks - Mens|35.5                      |
|Socks                           |White Striped Socks - Mens|20.18                     |

</details>


<details><summary>7. Tỷ lệ doanh thu (%) theo phân khúc cho từng danh mục?</summary>

```sql
WITH product_revenue
     AS (SELECT pd.category_id,
                pd.category_name,
                pd.segment_id,
                pd.segment_name,
                Sum(s.qty * s.price) AS product_revenue
         FROM   clothing_store..product_details AS pd
                JOIN clothing_store..sales AS s
                  ON pd.product_id = s.prod_id
         GROUP  BY pd.segment_id,
                   pd.segment_name,
                   pd.category_id,
                   pd.category_name)
SELECT category_name,
       segment_name,
       Round(100 * Cast(product_revenue AS FLOAT) / Sum(product_revenue)
             OVER(
               partition BY category_id), 2)
       AS segment_product_percentage
FROM   product_revenue
ORDER  BY category_id,
          segment_product_percentage DESC; 
```

|category_name                   |segment_name|segment_product_percentage|
|--------------------------------|------------|--------------------------|
|Womens                          |Jacket      |63.79                     |
|Womens                          |Jeans       |36.21                     |
|Mens                            |Shirt       |56.87                     |
|Mens                            |Socks       |43.13                     |


</details>



<details><summary>8. Tỷ lệ (%) của tổng doanh thu theo danh mục?</summary>

```sql
SELECT 100 * Sum(CASE
                   WHEN pd.category_id = 1 THEN ( s.qty * s.price )
                 END) / Sum(s.qty * s.price)       AS category_1,
       100 - 100 * Sum(CASE
                         WHEN pd.category_id = 1 THEN ( s.qty * s.price )
                       END) / Sum(s.qty * s.price) AS category_2
FROM   clothing_store..sales AS s
       JOIN clothing_store..product_details AS pd
         ON s.prod_id = pd.product_id;
```

|category_1                      |category_2|
|--------------------------------|----------|
|44                              |56        |


</details>



<details><summary>9. Tỉ lệ thâm nhập thị trường cho mỗi sản phẩm ?</summary>

```sql
WITH product_transaction
     AS (SELECT DISTINCT prod_id,
                         Count(DISTINCT txn_id) AS product_transaction_count
         FROM   clothing_store..sales
         GROUP  BY prod_id),
     total_transactions
     AS (SELECT Count(DISTINCT txn_id) AS total_transaction_count
         FROM   clothing_store..sales)
SELECT pt.prod_id,
       pd.product_name,
       Round(100 * Cast(pt.product_transaction_count AS FLOAT) /
             tt.total_transaction_count, 2) AS penetration_percentage
FROM   product_transaction AS pt
       CROSS JOIN total_transactions AS tt
       INNER JOIN clothing_store..product_details AS pd
               ON pd.product_id = pt.prod_id
ORDER  BY penetration_percentage DESC; 
```

|prod_id                         |product_name|penetration_percentage|
|--------------------------------|------------|----------------------|
|f084eb                          |Navy Solid Socks - Mens|51.24                 |
|9ec847                          |Grey Fashion Jacket - Womens|51                    |
|c4a632                          |Navy Oversized Jeans - Womens|50.96                 |
|5d267b                          |White Tee Shirt - Mens|50.72                 |
|2a2353                          |Blue Polo Shirt - Mens|50.72                 |
|2feb6b                          |Pink Fluro Polkadot Socks - Mens|50.32                 |
|72f5d4                          |Indigo Rain Jacket - Womens|50                    |
|d5e9a6                          |Khaki Suit Jacket - Womens|49.88                 |
|e83aa3                          |Black Straight Jeans - Womens|49.84                 |
|e31d39                          |Cream Relaxed Jeans - Womens|49.72                 |
|b9a74d                          |White Striped Socks - Mens|49.72                 |
|c8d436                          |Teal Button Up Shirt - Mens|49.68                 |



</details>

## Data Visualization
![](/db.png)
