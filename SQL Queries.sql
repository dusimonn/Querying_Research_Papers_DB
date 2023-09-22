-- __/\\\\\\\\\\\__/\\\\\_____/\\\__/\\\\\\\\\\\\\\\____/\\\\\_________/\\\\\\\\\_________/\\\\\\\________/\\\\\\\________/\\\\\\\________/\\\\\\\\\\________________/\\\\\\\\\_______/\\\\\\\\\_____        
--  _\/////\\\///__\/\\\\\\___\/\\\_\/\\\///////////___/\\\///\\\_____/\\\///////\\\_____/\\\/////\\\____/\\\/////\\\____/\\\/////\\\____/\\\///////\\\_____________/\\\\\\\\\\\\\___/\\\///////\\\___       
--   _____\/\\\_____\/\\\/\\\__\/\\\_\/\\\____________/\\\/__\///\\\__\///______\//\\\___/\\\____\//\\\__/\\\____\//\\\__/\\\____\//\\\__\///______/\\\_____________/\\\/////////\\\_\///______\//\\\__      
--    _____\/\\\_____\/\\\//\\\_\/\\\_\/\\\\\\\\\\\___/\\\______\//\\\___________/\\\/___\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\_________/\\\//_____________\/\\\_______\/\\\___________/\\\/___     
--     _____\/\\\_____\/\\\\//\\\\/\\\_\/\\\///////___\/\\\_______\/\\\________/\\\//_____\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\________\////\\\____________\/\\\\\\\\\\\\\\\________/\\\//_____    
--      _____\/\\\_____\/\\\_\//\\\/\\\_\/\\\__________\//\\\______/\\\______/\\\//________\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\___________\//\\\___________\/\\\/////////\\\_____/\\\//________   
--       _____\/\\\_____\/\\\__\//\\\\\\_\/\\\___________\///\\\__/\\\______/\\\/___________\//\\\____/\\\__\//\\\____/\\\__\//\\\____/\\\___/\\\______/\\\____________\/\\\_______\/\\\___/\\\/___________  
--        __/\\\\\\\\\\\_\/\\\___\//\\\\\_\/\\\_____________\///\\\\\/______/\\\\\\\\\\\\\\\__\///\\\\\\\/____\///\\\\\\\/____\///\\\\\\\/___\///\\\\\\\\\/_____________\/\\\_______\/\\\__/\\\\\\\\\\\\\\\_ 
--         _\///////////__\///_____\/////__\///________________\/////_______\///////////////_____\///////________\///////________\///////_______\/////////_______________\///________\///__\///////////////__

-- Your Name: Du-Simon Nguyen
-- Your Student Number: 1352062
-- By submitting, you declare that this work was completed entirely by yourself.

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q1

SELECT id AS publicationID, title FROM publication
WHERE id NOT IN (SELECT referencingpublicationid FROM referencing);

-- END Q1
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q2

SELECT id AS publicationID, title, dateofpublication FROM publication
ORDER BY dateofpublication DESC
LIMIT 1;

-- END Q2
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q3

SELECT publicationid, title 
FROM coauthors INNER JOIN publication ON (coauthors.PublicationID = publication.id) INNER JOIN researcher ON (researcher.id = coauthors.AuthorID)
WHERE (EndPage - StartPage >= 10) AND FirstName = 'Renata' AND LastName = 'Borovica-Gajic';

-- END Q3
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q4

SELECT id as publicationid, title, COUNT(id) AS CitationCount 
FROM publication INNER JOIN referencing ON publication.id = referencing.referencedpublicationid
GROUP BY id
HAVING CitationCount = (SELECT MAX(count) FROM 
						(SELECT COUNT(id) AS count 
							FROM publication INNER JOIN referencing ON publication.id = referencing.referencedpublicationid
							GROUP BY id) 
						AS counts);

-- END Q4
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q5

SELECT publicationID, documentURL 
FROM keyword INNER JOIN publication_has_keyword ON id = keywordid INNER JOIN publication ON publication.id = publicationid
WHERE Word = 'Databases' 
		AND publicationID IN (SELECT ID FROM 
								(SELECT referencedpublicationid AS ID, COUNT(*) AS citationcount 
									FROM referencing
									GROUP BY ID
									HAVING citationcount >= 1) 
								AS idcount);

-- END Q5
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q6

SELECT DISTINCT firstName, lastName 
FROM researcher INNER JOIN coauthors ON researcher.id = coauthors.authorID
WHERE PublicationID IN (SELECT ID FROM 
							(SELECT referencedpublicationid AS ID, COUNT(*) AS citationcount 
								FROM referencing
								GROUP BY ID
								HAVING citationcount >= 2) 
							AS idcount) 
		AND PublicationID IN (SELECT PublicationID FROM topten);

-- END Q6
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q7

SELECT keywordID, word 
FROM (SELECT keywordid, word, COUNT(*) AS top10numpublications 
		FROM (SELECT DISTINCT publicationID, keywordid, word 
				FROM keyword INNER JOIN publication_has_keyword ON keywordid = id NATURAL JOIN topten)
		AS disttopten
		GROUP BY keywordid
		HAVING top10numpublications = (SELECT MAX(top10numpublications) 
										FROM (SELECT keywordid, word, COUNT(*) AS top10numpublications 
												FROM (SELECT DISTINCT publicationID, keywordid, word 
														FROM keyword INNER JOIN publication_has_keyword ON keywordid = id NATURAL JOIN topten) 
												AS disttopten
												GROUP BY keywordid) 
										AS maxcount)
	) AS maxcount;

-- END Q7
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q8

SELECT firstName, lastName, SUM(citationcount) AS totalCitationCount 
FROM researcher INNER JOIN coauthors ON researcher.id = coauthors.authorid INNER JOIN (SELECT referencedpublicationid, COUNT(*) AS citationcount 
																							FROM referencing GROUP BY referencedpublicationid) AS idcitations 
																			ON publicationid = referencedpublicationid
GROUP BY AuthorID
HAVING totalCitationCount = (SELECT MAX(totalCitationCount) 
								FROM (SELECT AuthorID, firstName, lastName, SUM(citationcount) AS totalCitationCount 
											FROM researcher INNER JOIN coauthors ON researcher.id = coauthors.authorid INNER JOIN (SELECT referencedpublicationid, COUNT(*) AS citationcount 
																																		FROM referencing GROUP BY referencedpublicationid) AS idcitations 
																														ON publicationid = referencedpublicationid
										GROUP BY AuthorID) 
								AS authorcitationcounts);

-- END Q8
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q9

SELECT DISTINCT firstName, lastName FROM (SELECT dbauthorid, dbauthors.PublicationID, mlauthorid FROM (SELECT AuthorID AS dbauthorid, PublicationID 
													FROM coauthors
													WHERE AuthorID IN (SELECT researcherid 
																			FROM researcher_has_keyword INNER JOIN keyword ON keywordID = id
																			WHERE word = 'Databases')) AS dbauthors
								INNER JOIN (SELECT AuthorID AS mlauthorid, PublicationID 
													FROM coauthors
													WHERE AuthorID IN (SELECT researcherid 
																			FROM researcher_has_keyword INNER JOIN keyword ON keywordID = id
																			WHERE word = 'Machine Learning')) AS mlauthors
								ON dbauthors.publicationID = mlauthors.publicationID
								WHERE dbauthorid != mlauthorid) dbmlcoauthors INNER JOIN researcher ON dbauthorid = researcher.id;

-- END Q9
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q10

SELECT DISTINCT firstName, lastName 
FROM (SELECT c1.authorID AS a1, c1.publicationid PublicationID, c2.authorID AS a2 
		FROM coauthors AS c1 INNER JOIN coauthors AS c2 
		ON c1.publicationID = c2.publicationid
		WHERE c1.authorID != c2.authorID AND c2.authorID IN (SELECT AuthorID 
																FROM coauthors INNER JOIN researcher ON researcher.id = coauthors.AuthorID INNER JOIN publication ON publication.id = coauthors.publicationid
																WHERE FirstName = 'Renata' AND Lastname = 'Borovica-Gajic' AND DateOfPublication < '2023-01-01')
										AND c2.authorID NOT IN (SELECT AuthorID
																	FROM coauthors INNER JOIN researcher ON researcher.id = coauthors.AuthorID INNER JOIN publication ON publication.id = coauthors.publicationid
																	WHERE FirstName = 'Renata' AND Lastname = 'Borovica-Gajic' AND DateOfPublication >= '2023-01-01')) 
rbgcoauthors INNER JOIN researcher ON a1 = researcher.id;

-- END Q10
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- END OF ASSIGNMENT Do not write below this line