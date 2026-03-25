DROP DATABASE IF EXISTS Bokningssystem;
CREATE DATABASE Bokningssystem;
USE Bokningssystem;

-- Kunder
CREATE TABLE kunder (
    kund_id INT AUTO_INCREMENT PRIMARY KEY,
    namn VARCHAR(100) NOT NULL,
    epost VARCHAR(100) NOT NULL UNIQUE,
    telefon VARCHAR(20),
    skapad TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tjanster
CREATE TABLE tjanster (
    tjanst_id INT AUTO_INCREMENT PRIMARY KEY,
    namn VARCHAR(100) NOT NULL,
    langd_minuter INT NOT NULL,
    pris DECIMAL(10,2) NOT NULL,
    aktiv BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (langd_minuter > 0),
    CHECK (pris >= 0)
);

-- Bokningar
CREATE TABLE bokningar (
    bokning_id INT AUTO_INCREMENT PRIMARY KEY,
    kund_id INT NOT NULL,
    tjanst_id INT NOT NULL,
    datum_tid DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Bokad',
    skapad TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_kund FOREIGN KEY (kund_id) REFERENCES kunder(kund_id),
    CONSTRAINT fk_tjanst FOREIGN KEY (tjanst_id) REFERENCES tjanster(tjanst_id),
    CHECK (status IN ('Bokad', 'Avbokad', 'Genomford'))
);

-- Bokningslogg
CREATE TABLE bokningslogg (
    logg_id INT AUTO_INCREMENT PRIMARY KEY,
    bokning_id INT NOT NULL,
    meddelande VARCHAR(255) NOT NULL,
    skapad TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_logg_bokning FOREIGN KEY (bokning_id) REFERENCES bokningar(bokning_id)
);

DELIMITER $$

-- Skapar triggers
CREATE TRIGGER trg_efter_bokning
AFTER INSERT ON bokningar
FOR EACH ROW
BEGIN
    INSERT INTO bokningslogg (bokning_id, meddelande)
    VALUES (
        NEW.bokning_id,
        CONCAT('Ny bokning skapad for kund ', NEW.kund_id, ' och tjanst ', NEW.tjanst_id)
    );
END $$

DELIMITER ;
-- Adderar testdata
INSERT INTO kunder (namn, epost, telefon) VALUES
('Anna Svensson', 'anna@example.com', '0701234567'),
('Erik Johansson', 'erik@example.com', '0707654321'),
('Maria Karlsson', 'maria@example.com', '0731112233'),
('Johan Nilsson', 'johan@example.com', '0701112233'),
('Sara Lind', 'sara@example.com', '0702223344'),
('Oskar Berg', 'oskar@example.com', '0703334455'),
('Elin Holm', 'elin@example.com', '0704445566'),
('David Ek', 'david@example.com', '0705556677'),
('Emma Noren', 'emma@example.com', '0706667788'),
('Lucas Sjoberg', 'lucas@example.com', '0707778899');

-- Adderar testdata
INSERT INTO tjanster (namn, langd_minuter, pris) VALUES
('Klippning', 45, 350.00),
('Fargning', 90, 850.00),
('Skaggtrimning', 30, 250.00);

-- Adderar testdata
INSERT INTO bokningar (kund_id, tjanst_id, datum_tid) VALUES
(1, 1, '2026-03-20 10:00:00'),
(2, 2, '2026-03-20 11:00:00'),
(3, 3, '2026-03-20 12:00:00'),
(4, 1, '2026-03-20 13:00:00'),
(5, 2, '2026-03-20 14:00:00'),
(6, 1, '2026-03-21 09:00:00'),
(7, 3, '2026-03-21 10:00:00'),
(8, 2, '2026-03-21 11:30:00'),
(9, 1, '2026-03-21 13:00:00'),
(10, 3, '2026-03-21 14:30:00'),
(1, 2, '2026-03-22 09:00:00'),
(2, 1, '2026-03-22 10:30:00'),
(3, 3, '2026-03-22 12:00:00'),
(4, 2, '2026-03-22 13:30:00'),
(5, 1, '2026-03-22 15:00:00'),
(6, 3, '2026-03-23 09:30:00'),
(7, 2, '2026-03-23 11:00:00'),
(8, 1, '2026-03-23 12:30:00'),
(9, 3, '2026-03-23 14:00:00'),
(10, 2, '2026-03-23 15:30:00');

-- SELECT, FROM, JOIN, ORDERBY
SELECT 
    b.bokning_id,
    k.namn AS kund,
    t.namn AS tjanst,
    b.datum_tid,
    b.status
FROM bokningar b
JOIN kunder k ON b.kund_id = k.kund_id
JOIN tjanster t ON b.tjanst_id = t.tjanst_id
ORDER BY b.datum_tid;

-- Skapar procedure
DROP PROCEDURE IF EXISTS hamta_bokningar_mellan_datum;

DELIMITER $$

CREATE PROCEDURE hamta_bokningar_mellan_datum (
    IN start_datum DATE,
    IN slut_datum DATE
)
BEGIN
    SELECT 
        b.bokning_id,
        k.namn AS kund,
        t.namn AS tjanst,
        b.datum_tid,
        b.status
    FROM bokningar b
    JOIN kunder k ON b.kund_id = k.kund_id
    JOIN tjanster t ON b.tjanst_id = t.tjanst_id
    WHERE b.datum_tid >= start_datum
      AND b.datum_tid < DATE_ADD(slut_datum, INTERVAL 1 DAY)
    ORDER BY b.datum_tid;
END $$

DELIMITER ;
-- Hämta bokningar mellan specifika datum
CALL Bokningssystem.hamta_bokningar_mellan_datum('2026-03-20', '2026-03-21');

-- Skapar index
CREATE INDEX idx_kund ON bokningar(kund_id);
CREATE INDEX idx_tjanst ON bokningar(tjanst_id);
CREATE INDEX idx_datum ON bokningar(datum_tid);

-- Skapar users och sätter behörigheter
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'admin123';
CREATE USER 'personal_user'@'localhost' IDENTIFIED BY 'personal123';

GRANT ALL PRIVILEGES ON Bokningssystem.* TO 'admin_user'@'localhost';

GRANT SELECT, INSERT ON Bokningssystem.bokningar TO 'personal_user'@'localhost';
GRANT SELECT ON Bokningssystem.kunder TO 'personal_user'@'localhost';
GRANT SELECT ON Bokningssystem.tjanster TO 'personal_user'@'localhost';

FLUSH PRIVILEGES;

-- Fråga mot databasen
SELECT COUNT(*) AS antal_kunder FROM kunder;
SELECT COUNT(*) AS antal_tjanster FROM tjanster;
SELECT COUNT(*) AS antal_bokningar FROM bokningar;
SELECT COUNT(*) AS antal_loggar FROM bokningslogg;
SHOW INDEX FROM bokningar;
SHOW PROCEDURE STATUS WHERE Db = 'Bokningssystem';


INSERT INTO bokningar (kund_id, tjanst_id, datum_tid)
VALUES (1, 1, NOW());
