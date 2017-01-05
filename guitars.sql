
CREATE TABLE guitars (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  musician_id INTEGER,

  FOREIGN KEY(musician_id) REFERENCES musician(id)
);

CREATE TABLE musicians (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  company_id INTEGER,

  FOREIGN KEY(company_id) REFERENCES musician(id)
);

CREATE TABLE companies (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  companies (id, name)
VALUES
  (1, "Gibson"), (2, "Fender"), (3, "Epiphone"), (4, "D'Angelico");

INSERT INTO
  musicians (id, fname, lname, company_id)
VALUES
  (1, "Jimmy", "Page", 1),
  (2, "Eric", "Clapton", 1),
  (3, "Jimi", "Hendrix", 2),
  (4, "John", "Lennon", 3),
  (5, "Kurt", "Rosenwinkel", 4);

INSERT INTO
  guitars (id, name, musician_id)
VALUES
  (1, "EDS-1275", 1),
  (2, "Les Paul SG", 2),
  (3, "Stratocaster", 3),
  (4, "Jaguar", 3),
  (5, "Casino", 4),
  (6, "New Yorker", 5);
