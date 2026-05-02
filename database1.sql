USE YemekSiparisDB;
GO

-- TABLOLAR (BUGÜN SADECE TEMEL KISIM)
CREATE TABLE Musteriler (
    MusteriID INT PRIMARY KEY IDENTITY,
    Ad NVARCHAR(50) NOT NULL,
    Soyad NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Telefon NVARCHAR(15) UNIQUE NOT NULL,
    IsActive BIT DEFAULT 1
);

CREATE TABLE Restoranlar (
    RestoranID INT PRIMARY KEY IDENTITY,
    RestoranAdi NVARCHAR(100) NOT NULL,
    Puan DECIMAL(2,1) CHECK (Puan BETWEEN 1 AND 5),
    ToplamCiro DECIMAL(10,2) DEFAULT 0,
    IsActive BIT DEFAULT 1
);
--2.3 Ürünler (Menü)
CREATE TABLE Urunler (
    UrunID INT PRIMARY KEY IDENTITY,
    RestoranID INT,
    UrunAdi NVARCHAR(100),
    Fiyat DECIMAL(10,2) CHECK (Fiyat > 0),
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (RestoranID) REFERENCES Restoranlar(RestoranID)
);
--2.4 Siparişler
CREATE TABLE Siparisler (
    SiparisID INT PRIMARY KEY IDENTITY,
    MusteriID INT,
    RestoranID INT,
    SiparisTarihi DATETIME DEFAULT GETDATE(),
    ToplamTutar DECIMAL(10,2) CHECK (ToplamTutar > 0),
    Durum NVARCHAR(50),
    FOREIGN KEY (MusteriID) REFERENCES Musteriler(MusteriID),
    FOREIGN KEY (RestoranID) REFERENCES Restoranlar(RestoranID)
);
--2.5 Sipariş Detay
CREATE TABLE SiparisDetay (
    DetayID INT PRIMARY KEY IDENTITY,
    SiparisID INT,
    UrunID INT,
    Adet INT CHECK (Adet > 0),
    FOREIGN KEY (SiparisID) REFERENCES Siparisler(SiparisID),
    FOREIGN KEY (UrunID) REFERENCES Urunler(UrunID)
);