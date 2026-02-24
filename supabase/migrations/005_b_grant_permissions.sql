-- ============================================================================
-- GRANT PERMISSIONS FOR REPORTING VIEWS
-- ============================================================================

-- Ensure authenticated users (including Commissary) can read the views
GRANT SELECT ON network_daily_sales TO authenticated;
GRANT SELECT ON branch_sales_summary TO authenticated;

-- Force schema cache reload
NOTIFY pgrst, 'reload schema';
