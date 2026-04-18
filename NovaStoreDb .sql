/* NOVA STORE VERİTABANI PROJESİ
    Bu script; veritabanı oluşturma, tablo yapılarını kurma (DDL),
    örnek veri girişi (DML) ve temel sorgulama işlemlerini içerir.
*/

-- 1. ADIM: Veritabanını oluşturma ve aktif etme
CREATE DATABASE NovaStoreDB;
GO
USE NovaStoreDB;
GO

-- 2. ADIM: Tablo yapılarının (Schema) oluşturulması

-- Ürün kategorilerini tutan tablo
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1), -- Otomatik artan ID
    CategoryName VARCHAR(50) NOT NULL         -- Kategori adı (Boş geçilemez)
);
GO

-- Müşteri bilgilerini tutan tablo
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FullName VARCHAR(50) NOT NULL,
    City VARCHAR(20),
    Email VARCHAR(100) UNIQUE                -- Aynı e-posta adresi ikinci kez girilemez
);
GO

-- Ürün bilgilerini ve kategorilere olan bağlılığını tutan tablo
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2),                      -- Ondalıklı fiyat bilgisi
    Stock INT DEFAULT 0,                      -- Stok belirtilmezse varsayılan 0
    CategoryID INT,                           -- Foreign Key sütunu
    CONSTRAINT FK_CategoryProduct FOREIGN KEY (CategoryID) 
    REFERENCES Categories(CategoryID)         -- Categories tablosu ile ilişkilendirme
);
GO

-- Genel sipariş bilgilerini tutan tablo
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,                           -- Hangi müşteri sipariş verdi?
    OrderDate DATETIME DEFAULT GETDATE(),     -- Sipariş tarihi otomatik alınır
    TotalAmount DECIMAL(10,2),
    CONSTRAINT FK_CustomerOrder FOREIGN KEY (CustomerID) 
    REFERENCES Customers(CustomerID)          -- Customers tablosu ile ilişkilendirme
);
GO

-- Siparişlerin içindeki ürün detaylarını tutan ara tablo (Many-to-Many çözümü)
CREATE TABLE OrderDetails (
    DetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT,                              -- Hangi siparişe ait?
    ProductID INT,                            -- Hangi ürün satıldı?
    Quantity INT,                             -- Kaç adet satıldı?
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderID) 
    REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductID) 
    REFERENCES Products(ProductID)
);
GO

-- 3. ADIM: Test verilerinin (Dummy Data) eklenmesi

-- Kategoriler ekleniyor
INSERT INTO Categories (CategoryName) VALUES 
('Elektronik'), ('Giyim'), ('Kitap'), ('Kozmetik'), ('Ev ve Yasam');

-- Ürünler ekleniyor (CategoryID üzerinden kategorilere bağlanıyor)
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES 
('Akilli Telefon', 45000.00, 50, 1),
('Laptop', 35000.00, 20, 1),
('T-Shirt', 450.00, 200, 2),
('Kot Pantolon', 1200.00, 100, 2),
('Nutuk', 250.00, 500, 3),
('Sefiller', 300.00, 150, 3),
('Parfum', 2500.00, 7, 4),
('Nemlendirici Krem', 600.00, 80, 4),
('Kahve Makinesi', 4500.00, 15, 5),
('Nevresim Takimi', 1800.00, 30, 5),
('Bluetooth Kulaklik', 3200.00, 60, 1),
('Siir Kitabi', 120.00, 18, 3);

-- Müşteriler ekleniyor
INSERT INTO Customers (FullName, City, Email) VALUES 
('Ahmet Yilmaz', 'Ankara', 'ahmet@mail.com'),
('Beyza Sorgu', 'Karabuk', 'beyza@mail.com'),
('Can Demir', 'Istanbul', 'can@mail.com'),
('Deniz Kaya', 'Izmir', 'deniz@mail.com'),
('Elif Sahin', 'Ankara', 'elif@mail.com'),
('Furkan Kurt', 'Bursa', 'furkan@mail.com');

-- Siparişler ekleniyor (CustomerID üzerinden müşterilere bağlanıyor)
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES 
(1, '2026-04-10', 45450.00),
(2, '2026-04-11', 250.00),
(3, '2026-04-12', 36200.00),
(4, '2026-04-13', 2500.00),
(5, '2026-04-14', 1800.00),
(1, '2026-04-15', 3200.00),
(6, '2026-04-15', 4500.00),
(2, '2026-04-16', 720.00);

-- Sipariş detayları ekleniyor (Hangi siparişte hangi ürünler var?)
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES 
(1, 1, 1), (1, 3, 1),
(2, 5, 1),
(3, 2, 1), (3, 4, 1),
(4, 7, 1),
(5, 10, 1),
(6, 11, 1),
(7, 9, 1),
(8, 3, 1), (8, 12, 2);
GO

-- 4. ADIM: Kontrol Sorguları (Verileri Listeleme)
SELECT * FROM Categories;
SELECT * FROM Products;
SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM OrderDetails;


--Soru1: Stok miktarı 20'den az olan ürünlerin adını ve stok miktarını, stok miktarına göre "AZALAN" sırada listeleyin.

USE NovaStoreDB;
GO

SELECT ProductName, Stock
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;

--Soru2 :Hangi müşteri, hangi tarihte sipariş vermiş? Sonuçta Müşteri Adı, Şehir, Sipariş Tarihi ve Toplam Tutar gözüksün.
USE NovaStoreDB;
GO

SELECT 
    C.FullName, 
    C.City, 
    O.OrderDate, 
    O.TotalAmount
FROM Customers AS C
INNER JOIN Orders AS O ON C.CustomerID = O.CustomerID;

--Soru3: "Ahmet Yılmaz" (veya verinizdeki bir müşteri) isimli müşterinin aldığı ürünlerin isimlerini, fiyatlarını ve kategorilerini listeleyin.
USE NovaStoreDB;
GO

SELECT 
    C.FullName,
    P.ProductName,
    P.Price ,
    Cat.CategoryName
FROM Customers AS C
INNER JOIN Orders AS O ON C.CustomerID = O.CustomerID
INNER JOIN OrderDetails AS OD ON O.OrderID = OD.OrderID
INNER JOIN Products AS P ON OD.ProductID = P.ProductID
INNER JOIN Categories AS Cat ON P.CategoryID = Cat.CategoryID
WHERE C.FullName = 'Ahmet Yilmaz';
--Soru: Hangi kategoride toplam kaç adet ürünümüz var? (Örn: Elektronik - 5 ürün).
USE NovaStoreDB;
GO

SELECT 
    C.CategoryName AS Kategori, 
    COUNT(P.ProductID) AS TotalProduct
FROM Categories AS C
LEFT JOIN Products AS P ON C.CategoryID = P.CategoryID
GROUP BY C.CategoryName;
--Soru: Her müşterinin şirkete kazandırdığı toplam ciro nedir? En çok harcama yapan müşteriden en aza doğru sıralayın.
USE NovaStoreDB;
GO

SELECT 
    C.FullName AS MusteriAd, 
    SUM(O.TotalAmount) AS ToplamCiro
FROM Customers AS C
INNER JOIN Orders AS O ON C.CustomerID = O.CustomerID
GROUP BY C.FullName
ORDER BY ToplamCiro DESC;
--Soru: Bugünün tarihine göre, siparişlerin üzerinden kaç gün geçtiğini hesaplayan bir sorgu yazın.
USE NovaStoreDB;
GO

SELECT 
    OrderID,
    OrderDate AS SiparisTarihi,
    GETDATE() AS BugununTarihi,
    DATEDIFF(DAY, OrderDate, GETDATE()) AS GecenGunSayisi
FROM Orders;


--Sürekli uzun JOIN sorguları yazmamak için; Müşteri Adı, Sipariş Tarihi, Ürün Adı ve Adet bilgilerini tek bir tablodaymış gibi getiren vw_SiparisOzet isminde bir VIEW oluşturun.

USE NovaStoreDB;
GO

CREATE VIEW vw_SiparisOzet AS
SELECT 
    C.FullName ,
    O.OrderDate ,
    P.ProductName,
    OD.Quantity 
FROM Customers AS C
INNER JOIN Orders AS O ON C.CustomerID = O.CustomerID
INNER JOIN OrderDetails AS OD ON O.OrderID = OD.OrderID
INNER JOIN Products AS P ON OD.ProductID = P.ProductID;
GO
SELECT * FROM vw_SiparisOzet;

--Projenizi tamamladıktan sonra NovaStoreDB veri tabanının C:\Yedek\ klasörüne yedeğini alan T-SQL komutunu yazın.
BACKUP DATABASE NovaStoreDB 
TO DISK = 'C:\Yedek\NovaStoreDB.bak'
WITH FORMAT, 
     MEDIANAME = 'SQLServerBackups', 
     NAME = 'Full Backup of NovaStoreDB';
GO