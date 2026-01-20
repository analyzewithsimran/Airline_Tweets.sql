CREATE DATABASE twitter_airline_sentiment_clean;
USE twitter_airline_sentiment_clean;

-- 🟢 LEVEL 1: Basic Understanding
-- 1. Show all records from the dataset.
SELECT 
    *
FROM
    twitter_airline_sentiment_clean;

-- 2. Show only airline, airline_sentiment, tweet_created.
SELECT 
    airline, airline_sentiment, tweet_created
FROM
    twitter_airline_sentiment_clean;
    
-- 3. Count total number of tweets.
SELECT 
    COUNT(airline_sentiment) AS Total_Number_Of_Tweets
FROM
    twitter_airline_sentiment_clean;
    
-- 4. Find distinct airlines.
SELECT DISTINCT
    (airline) AS Distinct_airine
FROM
    twitter_airline_sentiment_clean;

-- 5. Show tweets where sentiment is negative.
SELECT 
    clean_text, airline_sentiment
FROM
    twitter_airline_sentiment_clean
WHERE
    airline_sentiment = 'negative';
 
 
-- 🟢 LEVEL 2: COUNT, GROUP BY, ORDER BY
-- 6. Count tweets per airline.
SELECT 
    airline, COUNT(airline_sentiment) AS Total_Tweets_Per_Airlines
FROM
    twitter_airline_sentiment_clean
GROUP BY airline
ORDER BY Total_Tweets_Per_Airlines DESC;

-- 7. Count tweets per sentiment.
SELECT 
    airline_sentiment, COUNT(airline_sentiment) AS Total_Tweets_Per_Airlines
FROM
    twitter_airline_sentiment_clean
GROUP BY airline_sentiment
ORDER BY Total_Tweets_Per_Airlines DESC;

-- 8. Show airline-wise count of negative tweets.
SELECT 
    airline, COUNT(airline_sentiment) AS Negative_Tweets
FROM
    twitter_airline_sentiment_clean
WHERE
    airline_sentiment = 'negative'
GROUP BY airline
ORDER BY Negative_Tweets DESC; 

-- 9. Find which airline has maximum tweets.
SELECT 
    airline, COUNT(*) AS total_tweets
FROM
    twitter_airline_sentiment_clean
GROUP BY airline
ORDER BY total_tweets DESC
LIMIT 1;

-- 10. Show sentiment count ordered from highest to lowest.
SELECT 
    airline, COUNT(airline_sentiment) AS Sentiment_Counts
FROM
    twitter_airline_sentiment_clean
GROUP BY airline
ORDER BY Sentiment_Counts DESC;

-- 🟡 LEVEL 3: Business Insight Queries 
-- 11. Find airline with highest number of negative tweets.
SELECT 
    airline, COUNT(*) AS negative_count
FROM
    twitter_airline_sentiment_clean
WHERE
    airline_sentiment = 'negative'
GROUP BY airline
ORDER BY negative_count DESC
LIMIT 1;

-- 12. Show percentage of negative tweets per airline.
SELECT 
    airline,
    COUNT(CASE
        WHEN airline_sentiment = 'negative' THEN 1
    END) * 100.0 / COUNT(*) AS negative_percentage
FROM
    twitter_airline_sentiment_clean
GROUP BY airline;

-- 13. Find top 5 most common negativereason.
SELECT 
    negativereason, COUNT(*) AS reason_count
FROM
    twitter_airline_sentiment_clean
WHERE
    airline_sentiment = 'negative'
GROUP BY negativereason
ORDER BY reason_count DESC
LIMIT 5;

-- 14. For each airline, show most frequent negative reason.
SELECT 
    airline, airline_sentiment, COUNT(negativereason) AS most_frequent_negative_reason
FROM
    twitter_airline_sentiment_clean
WHERE
    airline_sentiment = 'negative'
GROUP BY airline
ORDER BY most_frequent_negative_reason DESC
LIMIT 5;

-- 15. Find airlines where negative tweets > positive tweets.
SELECT 
    airline
FROM
    twitter_airline_sentiment_clean
GROUP BY airline
HAVING SUM(CASE
    WHEN airline_sentiment = 'negative' THEN 1
    ELSE 0
END) > SUM(CASE
    WHEN airline_sentiment = 'positive' THEN 1
    ELSE 0
END);


-- 🟡 LEVEL 4: DATE / TIME Analysis
-- 16. Count tweets month-wise.
SELECT 
    tweet_month, COUNT(*) AS tweet_count
FROM
    twitter_airline_sentiment_clean
GROUP BY tweet_month
ORDER BY tweet_month;

-- 17. Find month with maximum negative tweets.
SELECT 
    tweet_month, COUNT(*) AS negative_tweets
FROM
    twitter_airline_sentiment_clean
WHERE
    airline_sentiment = 'negative'
GROUP BY tweet_month
ORDER BY negative_tweets DESC
LIMIT 1;

-- 18. Show airline-wise negative tweets year-wise.
SELECT 
    tweet_year, airline, COUNT(*) AS negative_tweets
FROM
    twitter_airline_sentiment_clean
WHERE
    airline_sentiment = 'negative'
GROUP BY tweet_year, airline 
ORDER BY negative_tweets DESC
LIMIT 1;

-- 19. Find day of month when complaints are highest.
SELECT 
    tweet_day, COUNT(*) AS negative_tweets
FROM
    twitter_airline_sentiment_clean
WHERE
    airline_sentiment = 'negative'
GROUP BY tweet_day
ORDER BY negative_tweets DESC
LIMIT 1;

-- 20. Compare sentiment distribution before vs after a specific month.
SELECT
    CASE
        WHEN tweet_month < 6 THEN 'Before'
        ELSE 'After'
    END AS period,
    airline_sentiment,
    COUNT(*) AS sentiment_count
FROM twitter_airline_sentiment_clean
GROUP BY
    CASE
        WHEN tweet_month < 6 THEN 'Before'
        ELSE 'After'
    END,
    airline_sentiment
ORDER BY period, sentiment_count DESC;

-- 🟠 LEVEL 5: CASE + CONDITIONAL LOGIC

-- 21. Create a column:
-- Bad if negative
-- Okay if neutral
-- Good if positive
SELECT
    *,
    CASE
        WHEN airline_sentiment = 'negative' THEN 'Bad'
        WHEN airline_sentiment = 'neutral'  THEN 'Okay'
        WHEN airline_sentiment = 'positive' THEN 'Good'
    END AS sentiment_label
FROM twitter_airline_sentiment_clean;

-- 22. Label tweets as:
-- High Confidence if confidence ≥ 0.8
-- Low Confidence otherwise
SELECT 
    *,
    CASE
        WHEN sentiment_label > 0.8 THEN 'High_Confidence'
        ELSE 'Low_Confidence'
    END AS sentiment_Confidence_level
FROM
    twitter_airline_sentiment_clean;

-- 23. Show only high-confidence negative tweets.
SELECT 
    *
FROM
    twitter_airline_sentiment_clean
WHERE
    airline_sentiment = 'negative'
        AND airline_sentiment_confidence >= 0.8;

-- 24. For each airline, count high vs low confidence tweets.
SELECT
    airline,
    CASE
        WHEN airline_sentiment_confidence >= 0.8 THEN 'High_Confidence'
        ELSE 'Low_Confidence'
    END AS confidence_level,
    COUNT(*) AS tweet_count
FROM twitter_airline_sentiment_clean
GROUP BY
    airline,
    CASE
        WHEN airline_sentiment_confidence >= 0.8 THEN 'High_Confidence'
        ELSE 'Low_Confidence'
    END
ORDER BY airline, confidence_level;

-- 🔴 LEVEL 6: WINDOW FUNCTIONS 
-- 25. Rank airlines based on number of negative tweets.
SELECT
    airline,
    COUNT(*) AS negative_tweets,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
FROM twitter_airline_sentiment_clean
WHERE airline_sentiment = 'negative'
GROUP BY airline;

-- 26. Rank negative reasons by frequency.
SELECT
    negativereason,
    COUNT(*) AS frequency,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
FROM twitter_airline_sentiment_clean
WHERE airline_sentiment = 'negative'
GROUP BY negativereason;

-- 27. Show running total of tweets per airline.
SELECT
    airline,
    tweet_created,
    COUNT(*) AS tweets_per_day,
    SUM(COUNT(*)) OVER (
        PARTITION BY airline
        ORDER BY tweet_created
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_tweets
FROM twitter_airline_sentiment_clean
GROUP BY airline, tweet_created
ORDER BY airline, tweet_created;

-- 28. For each airline, show % contribution of its tweets to total tweets.
SELECT airline, 
       COUNT(*) AS airline_tweets,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_contribution
FROM twitter_airline_sentiment_clean
GROUP BY airline
ORDER BY percentage_contribution DESC;

-- 29. Find top 2 airlines with highest negative tweets using window function.
SELECT airline, negative_tweets
FROM (
    SELECT
        airline,
        COUNT(*) AS negative_tweets,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
    FROM twitter_airline_sentiment_clean
    WHERE airline_sentiment = 'negative'
    GROUP BY airline
) t
WHERE rnk <= 2;

-- 🔥 LEVEL 7: Storytelling 
-- 30. Find one clear reason why Airline X is performing poorly.
-- Ans. Poor performer: Airline with highest negative % and top reasons = delays & customer service.

-- 31. Identify airlines that need customer service improvement.
-- Ans. Improve CS: Airlines where CS-related negativereason dominates.

-- 32.  Suggest which month airlines should improve staffing.
-- Ans. Staffing month: Month with peak negative tweets.

-- 33. Which airline has best sentiment ratio?
-- Ans. Best sentiment: Airline with highest positive/lowest negative ratio.

-- 34. If you were a manager, which airline would you flag as high risk and why (based on data)?
-- Ans. High risk: Airline ranked top in negative tweets across years.