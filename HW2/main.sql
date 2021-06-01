CREATE TABLE Actor
(
  actor_id   INT,
  first_name VARCHAR(255),
  last_name  VARCHAR(255),
  country    VARCHAR(255),
  age        INT,
  gender     ENUM('female', 'male', 'other')     NOT NULL,
  PRIMARY KEY (actor_id)
);

CREATE TABLE Movie
(
  movie_id     INT,
  title        VARCHAR(255),
  genre        VARCHAR(255),
  PRIMARY KEY (movie_id)
);

CREATE TABLE Cinema
(
  cinema_id    INT,
  name         VARCHAR(255),
  PRIMARY KEY (cinema_id)
);

CREATE TABLE Actedin
(
  id         INT,
  actor_id   INT,
  movie_id   INT,
  PRIMARY KEY (id),
  FOREIGN KEY (actor_id) REFERENCES Actor (actor_id),
  FOREIGN KEY (movie_id) REFERENCES Movie (movie_id)
);

CREATE TABLE Playedin
(
  id           INT,
  cinema_id    INT,
  movie_id     INT,
  ticket_price INT,
  date         DATETIME NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (cinema_id) REFERENCES Cinema (cinema_id),
  FOREIGN KEY (movie_id) REFERENCES Movie (movie_id)
);

CREATE TABLE Viewer
(
  viewer_id  INT,
  first_name VARCHAR(255),
  last_name  VARCHAR(255),
  age        INT,
  gender     ENUM('female', 'male', 'other')     NOT NULL,
  PRIMARY KEY (viewer_id)
);

CREATE TABLE Attended
(
  id           INT,
  Playedin_id  INT,
  viewer_id    INT,
  PRIMARY KEY (id),
  FOREIGN KEY (Playedin_id) REFERENCES Playedin (id),
  FOREIGN KEY (viewer_id) REFERENCES Viewer (viewer_id)
);

-- 01 ---------- OK
SELECT MAX(ticket_price)
FROM Playedin
WHERE cinema_id IN (
    SELECT cinema_id
    From Cinema
    WHERE name="Esteghlal")

-- 02 ---------- OK
SELECT name
FROM Cinema
WHERE cinema_id IN (
    SELECT cinema_id
    FROM Playedin
    GROUP BY cinema_id
    HAVING min(ticket_price) >= 30)
ORDER BY name

-- 03 ----------  !!!!!
WITH Leila(actor_id) AS (
    SELECT actor_id
    FROM Actor
    WHERE first_name="Leila" AND last_name="Hatami")
SELECT title
FROM Movie
WHERE movie_id IN (
    SELECT movie_id
    FROM Actedin
    WHERE actor_id = Leila)
AND
    movie_id IN (
    SELECT movie_id
    FROM Playedin
    WHERE cinema_id = (
    SELECT cinema_id
    FROM Cinema
    WHERE name = "Ghods"))

-- 04 ---------- OK
SELECT first_name, last_name
FROM Viewer
WHERE gender="male" AND age=(
    SELECT max(age)
    FROM Viewer
    WHERE gender="male")

-- 05 --------------
WITH FILMID(movie_id) AS (
    SELECT movie_id
    FROM Movie
    WHERE name="Tenet"),
    A(viewer_id) AS (
    SELECT viewer_id
    FROM Attended
    WHERE Playedin_id IN (
    SELECT id
    FROM Playedin
    WHERE movie_id=FILMID.movie_id))
SELECT avg(age)
FROM Viewer
WHERE viewer_id IN A

-- 06 --------------
WITH PLAYID(id) AS (
    SELECT id
    FROM Playedin
    WHERE ticket_price=20 AND date.year=2000)
SELECT first_name, last_name
FROM Viewer
WHERE viewer_id IN (
    SELECT viewer_id
    FROM Attended
    WHERE Playedin_id IN PLAYID)
ORDER BY last_name, first_name

-- 07 -------------- OK
SELECT first_name, last_name
FROM Actor
WHERE actor_id IN (
    SELECT actor_id
    FROM Actedin
    WHERE movie_id IN (
        SELECT movie_id
        FROM Movie
        WHERE genre="Comedy"))
ORDER BY last_name, first_name


-- 08 -------------- OK
SELECT SUM(ticket_price)
FROM Playedin AS P JOIN Attended AS A on p.id=A.Playedin_id
WHERE P.cinema_id IN (
    SELECT cinema_id
    From Cinema
    WHERE name="Ghods")

--09 -------------
WITH DATEID(id) AS (
    SELECT id
    FROM Playedin
    WHERE date.year=2010)
SELECT DISTINCT first_name, last_name
FROM Viewer
WHERE viewer_id IN (
    SELECT viewer_id
    FROM Attended
    WHERE Playedin_id IN PLAYID)
ORDER BY last_name, first_name

--10 -------------
WITH DRIVE(movie_id) AS (
    SELECT movie_id
    FROM Movie
    WHERE title="Drive")
SELECT COUNT(*), gender
FROM Viewer
WHERE gender IN {"male", "female"} AND viewer_id IN (
    SELECT DISTINCT viewer_id
    FROM Attended
    WHERE Playedin_id IN (
        SELECT id
        FROM Playedin
        WHERE movie_id = DRIVE))
GROUP BY gender

--11 ------------- !!!!!
SELECT title
FROM Movie
WHERE movie_id IN (
    SELECT movie_id
    FROM Playedin
    WHERE id IN(
        SELECT Playedin_id
        FROM Attended
        WHERE COUNT(viewer_id)=1))
ORDER BY title
--12 -------------

--13 -------------
SELECT title, COUNT(*) AS NUMBER
FROM (Movie AS M NATURAL JOIN Playedin AS P) JOIN Attended on P.id=Playedin_id
GROUP BY M.movie_id
ORDER BY NUMBER
???????

--14 -------------

--15 -------------


