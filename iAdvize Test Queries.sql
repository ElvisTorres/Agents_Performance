/*Load the database first*/
DROP TABLE IF EXISTS HP_data;

CREATE TABLE HP_data (
	Hour_of_Timeslot VARCHAR(255),
    Agent_Uid VARCHAR(255),
    Agent_Role TEXT,
    Agent_CSAT_Percent DECIMAL (4,2),
    Average_Handling_Time_s DECIMAL(7,2),
    Closing_Time_s DECIMAL(6,2),
    First_Message_Response_Time_s DECIMAL(6,2),
    Number_of_Contacts INT,
    Production_Time_by_Channel_by_Agent DECIMAL(6,2),
    Turnover_By_Conversation DECIMAL(6,2)
    );
    
LOAD DATA INFILE 'Nov Dec 2021 human production data.csv' INTO TABLE HP_data
FIELDS TERMINATED BY ','
ENCLOSED BY '\"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

/*Quick look at the number of contacts, turnover by conversation, CSAT percentage
by the different Agent Roles*/
SELECT DISTINCT Agent_Role, AVG(Number_of_Contacts), AVG(Turnover_by_Conversation),
	AVG(Agent_CSAT_Percent)
FROM HP_data
GROUP BY Agent_Role;

SELECT DISTINCT Agent_Role, 
	SUM(Turnover_by_Conversation)/SUM(Number_of_Contacts)*100 as Turnover_By_Contact,
	AVG(Agent_CSAT_Percent)
FROM HP_data
GROUP BY Agent_Role;

/*Number of agents with zero contacts*/
SELECT DISTINCT Agent_Uid, Agent_Role, AVG(Number_of_Contacts) FROM HP_Data
Group BY Agent_Uid
ORDER BY Agent_Role, AVG(Number_of_Contacts) DESC; 

/*Zero contacts is not great, but focus should be on contacts and zero revenue*/
SELECT Agent_Role, Agent_Uid, AVG(Number_of_Contacts), AVG(Turnover_by_Conversation)
	FROM HP_data
WHERE Number_of_Contacts >1 AND Turnover_by_Conversation = 0
GROUP BY Agent_Uid
ORDER BY Agent_Role, AVG(Number_of_Contacts) DESC;

/*What is the Turnover by COnversation if I take out the zero contacts?*/
SELECT Agent_Role, Agent_Uid, AVG(Number_of_Contacts), AVG(Turnover_by_Conversation)
	FROM HP_Data
WHERE Number_of_Contacts>0 and Turnover_by_Conversation>0
GROUP BY Agent_Role;

/*Current Productivity*/
SELECT Agent_Role, AVG(Production_Time_by_Channel_by_Agent)
FROM HP_Data
GROUP BY Agent_Role;

/*Looking at First Message Response Time and Average Handling Time*/
SELECT Agent_Role, AVG(First_Message_Response_Time_s), AVG(Average_Handling_Time_s)
FROM HP_Data
GROUP BY Agent_Role;

/*Agents with at least 10 contacts*/
SELECT Agent_Role, COUNT(Agent_Role), AVG(Turnover_by_Conversation)
	FROM HP_Data
WHERE Number_of_Contacts>=10
GROUP BY Agent_Role;

/*Is Handling Time related to Turnover?*/
Select Distinct Agent_Uid, Agent_Role, AVG(Average_Handling_Time_s), 
	AVG(Turnover_by_Conversation), Agent_CSAT_Percent
FROM HP_Data
WHERE Average_Handling_Time_s>0 and Agent_CSAT_Percent>0
GROUP BY Agent_Uid;