SELECT  t1.event_date as event_date
       ,t1.user_id as user_id
       ,t1.event_id as event_id
       ,t1.to_group as to_group
       ,t1.to_object as to_object
       ,t1.sub_item_sales_fee as sub_item_sales_fee -- 单位分
       ,t1.is_latter_buy_h
       ,t1.latter_buy_order_id
       ,t2.sub_item_sales_fee_latter
       ,t3.identity as identity
       ,t3.device_kind as device_kind
       ,t3.register_day as register_day
       ,t3.user_grade as user_grade
       ,t4.book_name as learning_book
       ,if(event_id = 'ad-show', t1.ad_id, t5.ad_position) as ad_position
       ,case when if(event_id = 'ad-show', t1.ad_plan_name_init, t5.ad_plan_name) like '%兜底%' then '兜底广告'
             ELSE '非兜底广告' 
             END AS is_doudi
       ,${yyyy-MM-dd|日期} as chosen_date
       ,case WHEN datediff(TO_DATE(t1.event_date,'yyyy-mm-dd')
                  ,TO_DATE(t3.register_day,'yyyy-mm-dd'),'dd')<=7 then '新用户'
              ELSE '老用户'
              END AS user_type_7
       ,case WHEN datediff(TO_DATE(t1.event_date,'yyyy-mm-dd')
                  ,TO_DATE(t3.register_day,'yyyy-mm-dd'),'dd')<=30 then '新用户'
              ELSE '老用户'
              END AS user_type_30
       ,case WHEN datediff(TO_DATE(t1.event_date,'yyyy-mm-dd')
                  ,TO_DATE(t3.register_day,'yyyy-mm-dd'),'dd')<=60 then '新用户'
              ELSE '老用户'
              END AS user_type_60      
        ,case WHEN  t4.book_name like '%四级%' then '四级'
              WHEN  t4.book_name like '%六级%' then '六级'
              ELSE  t4.book_category
              END AS book_category
        ,case WHEN t1.to_object REGEXP '四级|六级' then 48
              WHEN t1.to_object REGEXP '芝士派小课' then 18
              WHEN t1.to_object REGEXP '小考' then 18
              WHEN t1.to_object REGEXP '外刊低价课|芝士派低价课|咸蛋|番茄' then 6
              END AS price
FROM 
(
SELECT  sub_item_pay_dt AS event_date
       ,bcz_uid AS user_id
       ,'ad-buy-1' AS event_id
       ,project_group_name AS to_group
       ,referral_to_object AS to_object
       ,CAST(sub_item_payment* 100 AS BIGINT) AS sub_item_sales_fee
       ,ad_id
       ,null as ad_plan_name_init
       ,0 AS is_latter_buy_h
       ,-100 AS latter_buy_order_id
FROM    dwd_mall_trade_sub_order_as_di
WHERE   sub_item_pay_dt = ${yyyy-MM-dd|日期}
AND     is_sub_order_paid = '是'
AND     is_all_refund <> '是'
AND     is_referral_order = '是'
AND     project_group_name = '薄荷芝士派'
AND     referral_from = '百词斩'
AND     referral_to_object REGEXP '四级|六级|芝士派小课|小考|外刊低价课|芝士派低价课|咸蛋|番茄'
UNION ALL
SELECT  event_date
        ,user_id
        ,event_id
        ,to_group
        ,to_object
        ,sub_item_sales_fee
        ,ad_position as ad_id
        ,ad_plan_name as ad_plan_name_init
        ,0 AS is_latter_buy_h
        ,-100 AS latter_buy_order_id
FROM    dw_application_f_event_records_referral_data
WHERE   event_date = ${yyyy-MM-dd|日期} 
AND     to_object REGEXP '四级|六级|芝士派小课|小考|外刊低价课|芝士派低价课|咸蛋|番茄'
AND     to_object not like '%公众号'            
AND     from_group = '百词斩'
AND     to_group = '薄荷芝士派'
AND     event_id in ('ad-show')
UNION ALL
SELECT  sub_item_pay_dt AS event_date
       ,bcz_uid AS user_id
       ,'ad-buy-0' AS event_id
       ,project_group_name AS to_group
       ,referral_to_object AS to_object
       ,CAST(sub_item_payment* 100 AS BIGINT) AS sub_item_sales_fee
       ,ad_id
       ,null as ad_plan_name_init
       ,is_latter_buy_h
       ,if(latter_buy_h_dt_gap <= 20,latter_buy_h_order_id,-100) AS latter_buy_order_id
FROM    dwd_mall_trade_sub_order_as_di
WHERE   sub_item_pay_dt >= '2021-01-01'
AND     is_sub_order_paid = '是'
AND     is_all_refund <> '是'
AND     is_referral_order = '是'
AND     project_group_name = '薄荷芝士派'
AND     referral_from = '百词斩'
AND     referral_to_object REGEXP '四级'
AND     datediff(${yyyy-MM-dd|日期} ,sub_item_pay_dt) >= 20
AND     datediff(${yyyy-MM-dd|日期} ,sub_item_pay_dt) <= 34
UNION ALL
SELECT  sub_item_pay_dt AS event_date
       ,bcz_uid AS user_id
       ,'ad-buy-0' AS event_id
       ,project_group_name AS to_group
       ,referral_to_object AS to_object
       ,CAST(sub_item_payment* 100 AS BIGINT) AS sub_item_sales_fee
       ,ad_id
       ,null as ad_plan_name_init
       ,is_latter_buy_h
       ,if(latter_buy_h_dt_gap <= 20,latter_buy_h_order_id,-100) AS latter_buy_order_id
FROM    dwd_mall_trade_sub_order_as_di
WHERE   sub_item_pay_dt >= '2021-01-01'
AND     is_sub_order_paid = '是'
AND     is_all_refund <> '是'
AND     is_referral_order = '是'
AND     project_group_name = '薄荷芝士派'
AND     referral_from = '百词斩'
AND     referral_to_object REGEXP '六级'
AND     datediff(${yyyy-MM-dd|日期} ,sub_item_pay_dt) >= 15
AND     datediff(${yyyy-MM-dd|日期} ,sub_item_pay_dt) <= 28
UNION ALL
SELECT  sub_item_pay_dt AS event_date
       ,bcz_uid AS user_id
       ,'ad-buy-0' AS event_id
       ,project_group_name AS to_group
       ,referral_to_object AS to_object
       ,CAST(sub_item_payment* 100 AS BIGINT) AS sub_item_sales_fee
       ,ad_id
       ,null as ad_plan_name_init
       ,is_latter_buy_h
       ,if(latter_buy_h_dt_gap <= 50,latter_buy_h_order_id,-100) AS latter_buy_order_id
FROM    dwd_mall_trade_sub_order_as_di
WHERE   sub_item_pay_dt >= '2021-01-01'
AND     is_sub_order_paid = '是'
AND     is_all_refund <> '是'
AND     is_referral_order = '是'
AND     project_group_name = '薄荷芝士派'
AND     referral_from = '百词斩'
AND     referral_to_object REGEXP '芝士派小课'
AND     datediff(${yyyy-MM-dd|日期} ,sub_item_pay_dt) >= 26
AND     datediff(${yyyy-MM-dd|日期} ,sub_item_pay_dt) <= 36
UNION ALL
SELECT  sub_item_pay_dt AS event_date
       ,bcz_uid AS user_id
       ,'ad-buy-0' AS event_id
       ,project_group_name AS to_group
       ,referral_to_object AS to_object
       ,CAST(sub_item_payment* 100 AS BIGINT) AS sub_item_sales_fee
       ,ad_id
       ,null as ad_plan_name_init
       ,is_latter_buy_h
       ,if(latter_buy_h_dt_gap <= 10,latter_buy_h_order_id,-100) AS latter_buy_order_id
FROM    dwd_mall_trade_sub_order_as_di
WHERE   sub_item_pay_dt >= '2021-01-01'
AND     is_sub_order_paid = '是'
AND     is_all_refund <> '是'
AND     is_referral_order = '是'
AND     project_group_name = '薄荷芝士派'
AND     referral_from = '百词斩'
AND     referral_to_object REGEXP '小考'
AND     datediff(${yyyy-MM-dd|日期} ,sub_item_pay_dt) >= 8
AND     datediff(${yyyy-MM-dd|日期} ,sub_item_pay_dt) <= 15
UNION ALL
SELECT  sub_item_pay_dt AS event_date
       ,bcz_uid AS user_id
       ,'ad-buy-0' AS event_id
       ,project_group_name AS to_group
       ,referral_to_object AS to_object
       ,CAST(sub_item_payment* 100 AS BIGINT) AS sub_item_sales_fee
       ,ad_id
       ,null as ad_plan_name_init
       ,is_latter_buy_h
       ,if(latter_buy_h_dt_gap <= 10,latter_buy_h_order_id,-100) AS latter_buy_order_id
FROM    dwd_mall_trade_sub_order_as_di
WHERE   sub_item_pay_dt >= '2021-01-01'
AND     is_sub_order_paid = '是'
AND     is_all_refund <> '是'
AND     is_referral_order = '是'
AND     project_group_name = '薄荷芝士派'
AND     referral_from = '百词斩'
AND     referral_to_object REGEXP '外刊低价课|芝士派低价课|咸蛋|番茄'
AND     datediff(${yyyy-MM-dd|日期} ,sub_item_pay_dt) >= 9
AND     datediff(${yyyy-MM-dd|日期} ,sub_item_pay_dt) <= 16
) t1
LEFT JOIN 
(
SELECT  order_id
        ,sub_item_pay_dt AS event_date_latter
        ,CAST(sub_item_payment* 100 AS BIGINT) AS sub_item_sales_fee_latter
FROM    dwd_mall_trade_sub_order_as_di
WHERE   sub_item_pay_dt >= '2021-01-01'
AND     is_sub_order_paid = '是'
AND     is_all_refund <> '是'
AND     project_group_name = '薄荷芝士派'
) t2
ON t1.latter_buy_order_id = t2.order_id
LEFT JOIN 
(
SELECT  *
FROM    dw_user_d_user_profile
) t3
ON      t1.user_id = t3.bcz_uid
LEFT JOIN 
(
SELECT bcz_uid
       ,book_category
       ,book_name
FROM dim_user_education_info 
) t4
ON      t1.user_id = t4.bcz_uid
LEFT JOIN 
(
SELECT *
FROM dw_application_d_ad_material    
) t5
ON    t1.ad_id = t5.ad_id
WHERE 1=1 
#{identity@IDENTITY|身份}
#{device_kind@OPTS:iphone,android,ipad|设备类型}
#{ad_position@AD_POSITION|广告位名称}
#{case when t1.to_object like '%芝士派小课%' then '芝士派小课48'
      when t1.to_object like '%外刊低价课%' then '外刊低价课6'
      when t1.to_object like '%芝士派低价课%' then '芝士派低价课6'
      when t1.to_object like '%咸蛋%' then '咸蛋低价课6'
      when t1.to_object like '%四级%'then '四级68'
      when t1.to_object like '%六级考试%' then '六级68'
      when t1.to_object like '%小考%'then '芝士小考18'
      when t1.to_object like '%番茄%' then '番茄低价课6'
      end@OPTS:四级68,六级68,芝士派小课48,芝士小考18,外刊低价课6,芝士派低价课6,咸蛋低价课6,番茄低价课6|承接sku}
#{case when datediff(TO_DATE(event_date,'yyyy-mm-dd')
    ,TO_DATE(register_day,'yyyy-mm-dd'),'dd')<=7 then '新用户'
    else '老用户'
    end@OPTS:新用户,老用户|新老用户};