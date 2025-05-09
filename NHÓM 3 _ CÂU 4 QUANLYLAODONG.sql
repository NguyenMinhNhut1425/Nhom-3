--4.	Tự suy nghĩ ra mỗi thành viên 2 câu hỏi truy vấn (không trùng nhau) 
--và giải đáp bằng lệnh SQL (Xem ví dụ minh họa các câu hỏi trong bài tập 1)

--Câu 1 (Kết nối nhiều bảng): Liệt kê nhân viên, tên phòng ban và tổng số ngày công >= 3 mà nhân viên đó đã làm ở tất cả các công trình.
SELECT NV.HOTEN, PB.TENPB, SUM(PC.SLNGAYCONG) AS TongNgayCong
FROM NHANVIEN NV
JOIN PHONGBAN PB ON NV.MAPB = PB.MAPB
JOIN PHANCONG PC ON NV.MANV = PC.MANV
GROUP BY NV.HOTEN, PB.TENPB
Having SUM(PC.SLNGAYCONG) >= 3

--Câu 2 (Kết nối nhiều bảng): Liệt kê các nhân viên tham gia các công trình tại 'TP.HCM' 
--và có số lượng ngày công từ 15 ngày trở lên, thông tin gồm MANV, HOTEN, PHAI, TENCT, DIADIEM, SLNGAYCONG, 
--kết quả sắp xếp theo họ tên nhân viên.
SELECT NV.MANV, NV.HOTEN, NV.PHAI, CT.TENCT, CT.DIADIEM, PC.SLNGAYCONG
FROM NHANVIEN NV
JOIN PHANCONG PC ON NV.MANV = PC.MANV
JOIN CONGTRINH CT ON PC.MACT = CT.MACT
WHERE CT.DIADIEM = 'TP.HCM'
  AND PC.SLNGAYCONG >= 15
ORDER BY NV.HOTEN

 
--Câu 3 (UPDATE): Lùi ngày hoàn thành (NGAYHT) của công trình 'CT03' xuống 1 tháng.
UPDATE CONGTRINH
SET NGAYHT = DATEADD(MONTH, -1, NGAYHT)
WHERE MACT = 'CT03'

--Câu 4 (UPDATE): Cộng thêm 10 ngày công cho những nhân viên tham gia các công trình ở TP.HCM mà có tổng số ngày công ở đó lớn hơn 100
UPDATE PHANCONG
SET SLNGAYCONG = SLNGAYCONG + 10
WHERE MANV IN (
    SELECT PC.MANV
    FROM PHANCONG PC
    JOIN CONGTRINH CT ON PC.MACT = CT.MACT
    WHERE CT.DIADIEM = 'TP.HCM'
    GROUP BY PC.MANV
    HAVING SUM(PC.SLNGAYCONG) > 100)

--Câu 5 (DELETE):: Xóa phân công của nhân viên có mã “NV01” khỏi công trình có mã “CT02”
DELETE FROM PHANCONG
WHERE MANV = 'NV01' AND MACT = 'CT02'

--Câu 6 (DELETE): Xóa nhân viên có mã 'NV05' khỏi bảng nhân viên
DELETE FROM NHANVIEN
WHERE MANV = 'NV05'

 
--Câu 7 (GROUP BY): Tính tổng số ngày công của từng nhân viên, thông tin gồm MANV, TONG_NGAYCONG.
SELECT MANV, SUM(SLNGAYCONG) AS TONG_NGAYCONG
FROM PHANCONG
GROUP BY MANV

--Câu 8 (GROUP BY): Liệt kê các phòng ban có số lượng nhân viên từ 3 người, thông tin gồm TENPB, SOLUONGNHANVIEN .
SELECT PB.TENPB, COUNT(NV.MANV) AS SOLUONGNHANVIEN
FROM PHONGBAN PB
JOIN NHANVIEN NV ON PB.MAPB = NV.MAPB
GROUP BY PB.TENPB
HAVING COUNT(NV.MANV) >= 3

--Câu 9 (SUBQUERY): Tìm các nhân viên tham gia công trình “CT01” nhưng không tham gia công trình "CT02", thông tin gồm MANV, HOTEN.
SELECT NV.MANV, NV.HOTEN
FROM NHANVIEN NV
JOIN PHANCONG PC ON PC.MANV = NV.MANV
WHERE PC.MACT = 'CT01' 
AND NV.MANV NOT IN (
    SELECT PC1.MANV
    FROM PHANCONG PC1
    WHERE PC1.MACT = 'CT02')

 
--Câu 10 (SUBQUERY):: Tìm các nhân viên có tổng số ngày công lớn hơn tất cả các nhân viên trong phòng "Phòng Kỹ Thuật", Thông tin gồm MANV, HOTEN, TONGNGAYCONG.
SELECT NV.MANV, NV.HOTEN, SUM(PC.SLNGAYCONG) AS TONGNGAYCONG
FROM NHANVIEN NV
JOIN PHANCONG PC ON NV.MANV = PC.MANV
GROUP BY NV.MANV, NV.HOTEN
HAVING SUM(PC.SLNGAYCONG) > ALL (
    SELECT SUM(PC1.SLNGAYCONG)
    FROM NHANVIEN NV1
    JOIN PHANCONG PC1 ON NV1.MANV = PC1.MANV
    JOIN PHONGBAN PB ON NV1.MAPB = PB.MAPB
    WHERE PB.TENPB = N'Phòng Kỹ Thuật'
    GROUP BY NV1.MANV)

--Câu 11 (Tùy ý): Liệt kê họ tên nhân viên và độ tuổi hiện tại
SELECT HOTEN, DATEDIFF(YEAR, NGSINH, GETDATE()) AS Tuoi
FROM NHANVIEN

--Câu 12 (Tùy ý): Liệt kê các công trình được hoàn thành trong thứ 2 hoặc thứ 3, thông tin gồm MACT, TENCT, NGAYHT, NGAYTRONGTUAN
SELECT MACT, TENCT, NGAYHT, DATENAME(WEEKDAY, NGAYHT) AS NGAYTRONGTUAN
FROM CONGTRINH
WHERE DATENAME(WEEKDAY,NGAYHT) IN ('MONDAY','TUESDAY')

----TRUY VẤN THÊM

--Câu 1: Liệt kê các công trình có ít nhất 2 nhân viên tham gia, gồm
--MACT, TENCT, Số lượng nhân viên tham gia.
SELECT 
   CT.MACT, 
   CT.TENCT, 
   COUNT(PC.MANV) AS SoLuongNhanVien
FROM
   CONGTRINH CT
JOIN 
   PHANCONG PC ON CT.MACT = PC.MACT
GROUP BY 
   CT.MACT, CT.TENCT
HAVING
   COUNT(PC.MANV) >= 2

--Câu 2: Liệt kê các nhân viên có làm việc ở nhiều hơn 1 công trình, gồm
--MANV, HOTEN, Số lượng công trình đã tham gia.
SELECT 
   NV.MANV, 
   NV.HOTEN, 
   COUNT(DISTINCT PC.MACT) AS SoLuongCongTrinh
FROM
   NHANVIEN NV
JOIN 
   PHANCONG PC ON NV.MANV = PC.MANV
GROUP BY 
   NV.MANV, NV.HOTEN
HAVING
   COUNT(DISTINCT PC.MACT) > 1

--Câu 3: Liệt kê nhân viên làm nhiều công trình nhất
SELECT TOP 1 NV.MANV, NV.HOTEN, COUNT(DISTINCT PC.MACT) AS SOLUONG_CONGTRINH
FROM NHANVIEN NV
JOIN PHANCONG PC ON NV.MANV = PC.MANV
GROUP BY NV.MANV, NV.HOTEN
ORDER BY SOLUONG_CONGTRINH DESC


--Câu 4: Liệt kê các công trình mà có ít nhất một nhân viên ở “Phòng Kế Toán” tham gia
SELECT DISTINCT CT.MACT, CT.TENCT
FROM CONGTRINH CT
WHERE EXISTS (
    SELECT 1
    FROM PHANCONG PC
    JOIN NHANVIEN NV ON PC.MANV = NV.MANV
    WHERE PC.MACT = CT.MACT AND NV.MAPB = 'PB01')

--Câu 5: liệt kê các công trình và tên nhân viên tham gia công trình đó.
SELECT CT.TENCT, NV.HOTEN
FROM CONGTRINH CT
JOIN PHANCONG PC ON CT.MACT = PC.MACT 
JOIN NHANVIEN NV ON PC.MANV = NV.MANV 
ORDER BY CT.TENCT


--Câu 6: Câu truy vấn cập nhật (UPDATE) Cập nhật địa điểm công trình thành 'Đà Nẵng' cho tất cả các 
--công trình có ngày hoàn thành (NGAYHT) trước ngày '2025-06-01'.
UPDATE CONGTRINH
SET DIADIEM = 'Đà Nẵng'
WHERE NGAYHT < '2025-06-01'

--Câu 7:  Cập nhật lại tên phòng ban 'Phòng Kỹ thuật' thành ‘Phòng Kỹ Thuật Công Nghệ’
UPDATE PHONGBAN
 SET TENPB = 'Phòng Kỹ Thuật Công Nghệ'
 WHERE TENPB = 'Phòng Kỹ thuật'

 --Câu 8:   Liệt kê tên nhân viên, tên công trình mà họ được phân công và số lượng ngày công đã làm.
SELECT NV.HOTEN, CT.TENCT, PC.SLNGAYCONG
FROM NHANVIEN NV
JOIN PHANCONG PC ON NV.MANV = PC.MANV
JOIN CONGTRINH CT ON PC.MACT = CT.MACT

--Câu 9: liệt kê các phòng ban với tổng số ngày công của nhân viên trong mỗi phòng ban, 
--nhưng chỉ lấy các phòng ban có tổng số ngày công lớn hơn 200
SELECT PB.TENPB, SUM(PC.SLNGAYCONG) AS TongNgayCong
FROM PHONGBAN PB
JOIN NHANVIEN NV ON PB.MAPB = NV.MAPB
JOIN PHANCONG PC ON NV.MANV = PC.MANV
GROUP BY PB.TENPB
HAVING SUM(PC.SLNGAYCONG) > 200

--Câu 10:   liệt kê tên phòng ban và số lượng nhân viên trong từng công trình
SELECT CT.TENCT, PB.TENPB, COUNT(DISTINCT NV.MANV) AS SoLuongNhanVien
FROM CONGTRINH CT
JOIN PHANCONG PC ON CT.MACT = PC.MACT
JOIN NHANVIEN NV ON PC.MANV = NV.MANV
JOIN PHONGBAN PB ON NV.MAPB = PB.MAPB
GROUP BY CT.TENCT, PB.TENPB
ORDER BY CT.TENCT


