-- Create the database for this question
CREATE SCHEMA IF NOT EXISTS aoc2024;

-- Table to hold the input data
CREATE TABLE IF NOT EXISTS aoc2024.input (
    list1   INT NOT NULL,
    list2   INT NOT NULL
);
-- Clear the table to replace entries from previous runs
DELETE FROM aoc2024.input WHERE TRUE;

-- Load the input file into the database.
-- Must be copied to the /var/lib/mysql/aoc2024 directory
-- See included copy_input.sh file
LOAD DATA INFILE './aoc2024/input'
INTO TABLE aoc2024.input
FIELDS TERMINATED BY '   ';

-- Create a table to hold the values in the first list
CREATE TABLE IF NOT EXISTS aoc2024.list1 (
    -- We need to hold onto the row so we can join
    -- this table with the second list
    row     INT AUTO_INCREMENT NOT NULL,
    list    INT NOT NULL,
    PRIMARY KEY(row)
);
-- Clear the table to replace entries from previous runs
DELETE FROM aoc2024.list1 WHERE TRUE;

-- Create a table to hold the values in the second list
CREATE TABLE IF NOT EXISTS aoc2024.list2 (
    -- We need to hold onto the row so we can join
    -- this table with the first list
    row     INT AUTO_INCREMENT NOT NULL,
    list   INT NOT NULL,
    PRIMARY KEY(row)
);
-- Clear the table to replace entries from previous runs
DELETE FROM aoc2024.list2 WHERE TRUE;

-- Insert from the input the first list, sorted from
-- smallest to largest
INSERT INTO aoc2024.list1 (
    SELECT NULL,list1 
    FROM aoc2024.input
    ORDER BY list1 ASC
);

-- Insert from the input the second list, sorted from
-- smallest to largest
INSERT INTO aoc2024.list2 (
    SELECT NULL,list2
    FROM aoc2024.input
    ORDER BY list2 ASC
);

-- The differences table. Holds the distances between each 
-- of the entries for each row
CREATE TABLE IF NOT EXISTS aoc2024.differences (
    difference  INT NOT NULL
);
-- Clear the table to replace entries from previous runs
DELETE FROM aoc2024.differences WHERE TRUE;

-- The difference is the absolute difference of the corresponding
-- entries in the first and second lists
INSERT INTO aoc2024.differences (
    SELECT ABS(l2.list - l1.list)
    FROM (aoc2024.list1 as l1) JOIN (aoc2024.list2 as l2) ON l1.row = l2.row
);

-- The total difference (the answer to part 1)
-- is the sum of the differences
SELECT SUM(difference) as Part1Answer
FROM aoc2024.differences;

-- For part 2, we need to find the similarity score
-- This requires multiplying each value in the first list
-- by the number of occurences of that value in the second list
-- This intermediate table stores the number of times each entry
-- in the first list appears in the second list
CREATE TABLE IF NOT EXISTS aoc2024.appearancesInList2(
    list        INT NOT NULL,
    counter     INT NOT NULL
);
-- Clear the table to replace entries from previous runs
DELETE FROM aoc2024.appearancesInList2 WHERE TRUE;

-- Inserts the number of times each entry in the first list
-- appears in the second list. 
INSERT INTO aoc2024.appearancesInList2 (
    SELECT l1.list, COUNT(*)
    FROM (aoc2024.list1 as l1) JOIN (aoc2024.list2 as l2) ON l1.list = l2.list
    GROUP BY l1.list
);

-- The similarity score for each entry in the first list is stored in 
-- this table.
CREATE TABLE IF NOT EXISTS aoc2024.similarities(
    similarity  INT NOT NULL
);
-- Clear the table to replace entries from previous runs
DELETE FROM aoc2024.similarities WHERE TRUE;

-- Calculate the similarity score for each value in the first list
-- which is the value * count, where count is the number of times
-- the value appears in the second list
INSERT INTO aoc2024.similarities (
    SELECT list*counter
    FROM aoc2024.appearancesInList2
);

-- The similarity score, and the answer to part 2,
-- is the sum of the similarity scores for each
-- entry in the similarities table
SELECT SUM(similarity) as Part2Answer
FROM aoc2024.similarities;
