/* ====================================================================
   PORTFOLIO PROJECT: FAANG CHURN ANALYTICS & ETL PIPELINE
   PHASE 4: THE MASTER PRODUCTION VIEW
   
   BUSINESS CASE:
   This script combines a multi-phase audit into a single optimized pipeline. 
   It calculates user performance baselines, maps financial revenue segments, 
   and heals missing 30-day watch-time gaps simultaneously.
   ==================================================================== */

WITH MasterPipeline AS (
    SELECT 
        user_id,
        region,
        subscription_tier,
        playback_device,
        monthly_billing_usd AS user_bill,
        telemetry_buffering_events AS user_freezes,
        
        -- PHASE 1: Calculate the live platform whole-number average baseline (24)
        AVG(telemetry_buffering_events) OVER() AS platform_average_baseline,
        
        -- PHASE 3: Repair the 49 missing watch-time records inline
        ISNULL(frequency_minutes_watched_30d, 0) AS clean_minutes_30d
        
    FROM 
        faang_customer_segmentation_1000
)

SELECT 
    user_id,
    region,
    subscription_tier,
    user_bill,
    
    -- PHASE 2: Apply financial revenue segments
    CASE 
        WHEN subscription_tier = 'Premium_4K' THEN 'Tier 1: High-Value (VIP)'
        WHEN subscription_tier = 'Standard_HD' THEN 'Tier 2: Mid-Value'
        WHEN subscription_tier = 'Basic' THEN 'Tier 3: Core Volume'
        ELSE 'Unclassified'
    END AS financial_revenue_segment,
    
    user_freezes,
    platform_average_baseline AS platform_baseline,
    clean_minutes_30d
FROM 
    MasterPipeline
ORDER BY 
    user_bill DESC, 
    user_freezes DESC;
