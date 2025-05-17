# DataAnalytics-Assessment
# Data Analyst Assessment - SQL Solutions

## Question 1: High-Value Customers with Multiple Products
Approach
- Joined users, plans, and savings tables using owner_id and plan_id
- Used conditional counting with CASE to separate savings and investment plans
- Filtered for successful transactions only
- Converted amounts from kobo to currency by dividing by 100
- Ordered by total deposits to show highest-value customers first

Key Note: Ensured we only count distinct plans per customer and only successful transactions.

## Question 2: Transaction Frequency Analysis
Approach
- Calculated customer tenure in months since signup
- Counted all successful transactions per customer
- Derived transactions per month
- Categorized customers into frequency buckets
- Aggregated results by frequency category

Key Note: Properly handled customers with very short tenure to avoid skewing averages.

## Question 3: Account Inactivity Alert
Approach 
- Identified active accounts
- Found most recent successful transaction for each account
- Calculated days since last transaction
- Included accounts with no transactions but created >1 year ago
- Ordered by longest inactive first

Key Note: Distinguished between truly inactive accounts versus new accounts without transactions yet.

## Question 4: Customer Lifetime Value (CLV) Estimation
Approach
- Calculated customer tenure in months
- Counted total successful transactions
- Calculated average transaction value
- Applied the CLV formula with 0.1% profit assumption
- Converted amounts from kobo to currency
- Ordered by highest estimated CLV first

Key Note: Ensured the formula correctly accounts for varying customer tenure and transaction patterns.
