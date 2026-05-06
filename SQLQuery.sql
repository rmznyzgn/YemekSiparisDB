/* =====================================================
   VTYS PROJE - ONLINE YEMEK SİPARİŞ SİSTEMİ
   ASKIDA YEMEK MODÜLLÜ - FULL VERSION
===================================================== */

CREATE DATABASE YemekSiparisDB;
GO
USE YemekSiparisDB;
GO

/* =====================================================
   1. TABLOLAR
===================================================== */

-- Müşteriler
CREATE TABLE Musteriler (
    MusteriID INT PRIMARY KEY IDENTITY,
    Ad NVARCHAR(50) NOT NULL,
    Soyad NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Telefon NVARCHAR(15) UNIQUE,
    IsVerified BIT DEFAULT 0,
    IsActive BIT DEFAULT 1
);

-- Restoranlar
CREATE TABLE Restoranlar (
    RestoranID INT PRIMARY KEY IDENTITY,
    RestoranAdi NVARCHAR(100) NOT NULL,
    Puan DECIMAL(2,1) CHECK (Puan BETWEEN 1 AND 5),
    ToplamCiro DECIMAL(10,2) DEFAULT 0,
    IsActive BIT DEFAULT 1
);

-- Ürünler
CREATE TABLE Urunler (
    UrunID INT PRIMARY KEY IDENTITY,
    RestoranID INT,
    UrunAdi NVARCHAR(100),
    Fiyat DECIMAL(10,2) CHECK (Fiyat > 0),
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (RestoranID) REFERENCES Restoranlar(RestoranID)
);

-- Siparişler
CREATE TABLE Siparisler (
    SiparisID INT PRIMARY KEY IDENTITY,
    MusteriID INT,
    RestoranID INT,
    SiparisTarihi DATETIME DEFAULT GETDATE(),
    ToplamTutar DECIMAL(10,2) CHECK (ToplamTutar > 0),
    Durum NVARCHAR(50),
    IsAskida BIT DEFAULT 0,
    FOREIGN KEY (MusteriID) REFERENCES Musteriler(MusteriID),
    FOREIGN KEY (RestoranID) REFERENCES Restoranlar(RestoranID)
);

-- Sipariş Detay
CREATE TABLE SiparisDetay (
    DetayID INT PRIMARY KEY IDENTITY,
    SiparisID INT,
    UrunID INT,
    Adet INT CHECK (Adet > 0),
    Fiyat DECIMAL(10,2),
    FOREIGN KEY (SiparisID) REFERENCES Siparisler(SiparisID),
    FOREIGN KEY (UrunID) REFERENCES Urunler(UrunID)
);

-- Askıda Yemek Havuzu
CREATE TABLE AskidaYemekHavuzu (
    HavuzID INT PRIMARY KEY IDENTITY,
    ToplamBakiye DECIMAL(10,2) DEFAULT 0
);

INSERT INTO AskidaYemekHavuzu (ToplamBakiye) VALUES (0);

-- Bağışlar
CREATE TABLE Bagislar (
    BagisID INT PRIMARY KEY IDENTITY,
    MusteriID INT,
    Tutar DECIMAL(10,2) CHECK (Tutar > 0),
    GizliMi BIT DEFAULT 1,
    BagisTarihi DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (MusteriID) REFERENCES Musteriler(MusteriID)
);

-- Askı Kullanım
CREATE TABLE AskidaKullanim (
    KullanimID INT PRIMARY KEY IDENTITY,
    MusteriID INT,
    SiparisID INT,
    KullanilanTutar DECIMAL(10,2),
    FOREIGN KEY (MusteriID) REFERENCES Musteriler(MusteriID),
    FOREIGN KEY (SiparisID) REFERENCES Siparisler(SiparisID)
);

/* =====================================================
   2. INDEX
===================================================== */

CREATE INDEX idx_Email ON Musteriler(Email);
CREATE INDEX idx_RestoranAdi ON Restoranlar(RestoranAdi);

/* =====================================================
   3. TRIGGER
===================================================== */

-- Bağış yapılınca havuza ekle
CREATE TRIGGER trg_BagisEkle
ON Bagislar
AFTER INSERT
AS
BEGIN
    UPDATE AskidaYemekHavuzu
    SET ToplamBakiye = ToplamBakiye + 
    (SELECT SUM(Tutar) FROM inserted);
END;

-- Askıdan kullanımda düş
CREATE TRIGGER trg_AskidaDus
ON AskidaKullanim
AFTER INSERT
AS
BEGIN
    UPDATE AskidaYemekHavuzu
    SET ToplamBakiye = ToplamBakiye - 
    (SELECT SUM(KullanilanTutar) FROM inserted);
END;

-- Sipariş teslim edilince ciro artır (HATALAR DÜZELTİLDİ)
CREATE TRIGGER trg_CiroArtir
ON Siparisler
AFTER UPDATE
AS
BEGIN
    UPDATE R
    SET ToplamCiro = ToplamCiro + I.ToplamTutar
    FROM Restoranlar R
    JOIN inserted I ON R.RestoranID = I.RestoranID
    JOIN deleted D ON I.SiparisID = D.SiparisID
    WHERE I.Durum = 'Teslim Edildi'
    AND D.Durum <> 'Teslim Edildi';
END;

/* =====================================================
   4. VIEW
===================================================== */

-- Aktif ürünler
CREATE VIEW vw_AktifUrunler AS
SELECT U.UrunAdi, R.RestoranAdi, U.Fiyat
FROM Urunler U
JOIN Restoranlar R ON U.RestoranID = R.RestoranID
WHERE U.IsActive = 1;

-- Askıda yemek durumu
CREATE VIEW vw_AskidaDurum AS
SELECT ToplamBakiye FROM AskidaYemekHavuzu;

/* =====================================================
   5. TEST VERİLERİ
===================================================== */

-- 20 müşteri
INSERT INTO Musteriler (Ad, Soyad, Email, Telefon, IsVerified)
VALUES
('Ali','Kaya','ali1@mail.com','5300000001',1),
('Ayşe','Demir','ayse2@mail.com','5300000002',1),
('Mehmet','Yılmaz','mehmet3@mail.com','5300000003',0),
('Fatma','Çelik','fatma4@mail.com','5300000004',1),
('Ahmet','Şahin','ahmet5@mail.com','5300000005',0),
('Zeynep','Koç','zeynep6@mail.com','5300000006',1),
('Hasan','Arslan','hasan7@mail.com','5300000007',0),
('Elif','Doğan','elif8@mail.com','5300000008',1),
('Murat','Kurt','murat9@mail.com','5300000009',0),
('Emine','Aydın','emine10@mail.com','5300000010',1),
('Hüseyin','Öztürk','huseyin11@mail.com','5300000011',0),
('Hatice','Yıldız','hatice12@mail.com','5300000012',1),
('İbrahim','Aksoy','ibrahim13@mail.com','5300000013',0),
('Seda','Polat','seda14@mail.com','5300000014',1),
('Burak','Güneş','burak15@mail.com','5300000015',0),
('Derya','Tekin','derya16@mail.com','5300000016',1),
('Onur','Kara','onur17@mail.com','5300000017',0),
('Cem','Erdoğan','cem18@mail.com','5300000018',1),
('Selin','Kaplan','selin19@mail.com','5300000019',0),
('Okan','Eren','okan20@mail.com','5300000020',1);

-- 5 restoran
INSERT INTO Restoranlar (RestoranAdi, Puan)
VALUES 
('Burger House',4.5),
('Pizza Time',4.2),
('Kebapçı Ali',4.7),
('Tavuk Dünyası',4.3),
('Sushi Bar',4.6);

-- 50 ürün
DECLARE @i INT = 1;
WHILE @i <= 50
BEGIN
    INSERT INTO Urunler (RestoranID, UrunAdi, Fiyat)
    VALUES (((@i - 1) % 5) + 1, 'Urun_' + CAST(@i AS NVARCHAR), (RAND()*200)+20);
    SET @i += 1;
END;

-- 100 sipariş
DECLARE @i INT = 1;

WHILE @i <= 100
BEGIN
    INSERT INTO Siparisler (MusteriID, RestoranID, ToplamTutar, Durum, IsAskida)
    VALUES (
        (SELECT TOP 1 MusteriID FROM Musteriler ORDER BY NEWID()),
        (SELECT TOP 1 RestoranID FROM Restoranlar ORDER BY NEWID()),
        (RAND()*300)+50,
        'Hazırlanıyor',
        0
    );

    SET @i = @i + 1;
END;

-- Sipariş detay
DECLARE @i INT = 1;
DECLARE @urunID INT;

WHILE @i <= 100
BEGIN
    SELECT TOP 1 @urunID = UrunID FROM Urunler ORDER BY NEWID();

    INSERT INTO SiparisDetay (SiparisID, UrunID, Adet, Fiyat)
    VALUES (
        @i,
        @urunID,
        (ABS(CHECKSUM(NEWID())) % 3) + 1,
        (RAND()*200)+20
    );

    SET @i = @i + 1;
END;

-- Bağışlar
INSERT INTO Bagislar (MusteriID, Tutar, GizliMi)
VALUES (1,200,1),(2,150,0),(3,300,1);

-- Askı kullanım
INSERT INTO AskidaKullanim (MusteriID, SiparisID, KullanilanTutar)
VALUES (1,1,100);

/* =====================================================
   6. SORGULAR
===================================================== */

-- JOIN (Sipariş fişi)
SELECT M.Ad, R.RestoranAdi, U.UrunAdi, SD.Adet
FROM Siparisler S
JOIN Musteriler M ON S.MusteriID = M.MusteriID
JOIN SiparisDetay SD ON S.SiparisID = SD.SiparisID
JOIN Urunler U ON SD.UrunID = U.UrunID
JOIN Restoranlar R ON S.RestoranID = R.RestoranID;

-- GROUP BY
SELECT R.RestoranAdi, COUNT(*) AS SiparisSayisi, AVG(S.ToplamTutar) AS Ortalama
FROM Siparisler S
JOIN Restoranlar R ON S.RestoranID = R.RestoranID
GROUP BY R.RestoranAdi
HAVING COUNT(*) > 5;

-- SUBQUERY
SELECT * FROM Musteriler
WHERE MusteriID NOT IN (SELECT MusteriID FROM Bagislar);