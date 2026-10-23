# Hướng dẫn tiếng Việt — KISA CIIP 2026

> Bản dịch cộng đồng đang triển khai. Tài liệu gốc và phương pháp kiểm tra thuộc dự án KISA-CIIP-2026. Bản dịch không đồng nghĩa với chứng nhận tuân thủ quy định pháp luật Việt Nam.

## Tổng quan
Bộ script đánh giá cấu hình bảo mật dựa trên hướng dẫn kỹ thuật KISA (Hàn Quốc) năm 2026, gồm các nhóm:
- Unix/Linux: Debian, RedHat, AIX, HP-UX, Solaris (U-01 đến U-67).
- Windows Server 2019 trở lên (W-01 đến W-64).
- Web server: Apache, Nginx, Tomcat, IIS (WEB-01 đến WEB-26).
- Hệ quản trị cơ sở dữ liệu: MySQL, PostgreSQL, Oracle, MSSQL (D-01 đến D-26).
- Máy trạm Windows (P-01 đến P-18).

Theo README gốc, dự án có 625 script kiểm tra.

## Sử dụng
Chỉ chạy trên hệ thống mà bạn sở hữu hoặc được ủy quyền kiểm tra. Nên thử nghiệm trên môi trường staging trước.

```bash
git clone https://github.com/Ducta2/KISA-CIIP-2026.git
cd KISA-CIIP-2026
git checkout feature/vietnamese-localization
chmod +x lib/*.sh 01.Unix서버/RedHat/*_check.sh
cd 01.Unix서버/RedHat
sudo bash U01_check.sh
```

## Trạng thái đánh giá
- `GOOD`: Đạt tiêu chí kiểm tra.
- `VULNERABLE`: Không đạt; cần xem bằng chứng và lên kế hoạch xử lý.
- `MANUAL`: Cần kiểm tra thủ công.
- `N/A`: Không áp dụng.

Các mã máy đọc (`GOOD`, `VULNERABLE`, `MANUAL`, `N/A`), ID hạng mục và tên khóa JSON phải được giữ nguyên để tránh làm hỏng tích hợp.

## Kết quả
Script có thể xuất JSON/TXT, thường lưu trong thư mục `results/YYYYMMDD/`. Cần bảo vệ kết quả vì có thể chứa cấu hình và thông tin tài sản.

## Nguyên tắc Việt hóa
1. Dịch nhãn hạng mục, mô tả, tiêu chí đạt/không đạt, khuyến nghị khắc phục, cảnh báo và chú thích.
2. Không dịch cú pháp lệnh, đường dẫn, tham số, biến điều khiển, mã đánh giá hay khóa JSON.
3. Chạy `bash -n` và kiểm thử trên môi trường phù hợp sau mỗi nhóm thay đổi.
4. So sánh kết quả với bản gốc trên cùng cấu hình để phát hiện thay đổi hành vi.

## Tiến độ
- [x] Khởi tạo nhánh Việt hóa.
- [x] Việt hóa bước đầu RedHat `U01_check.sh`.
- [ ] Kiểm thử chức năng và rà soát câu chữ của U-01.
- [ ] Việt hóa các thư viện dùng chung.
- [ ] Việt hóa những script còn lại theo từng nền tảng.
- [ ] Regression test toàn bộ.

## Giấy phép
Dự án gốc công bố sử dụng AGPL-3.0. Bảo lưu thông tin bản quyền và tuân thủ các nghĩa vụ giấy phép khi sửa đổi, phân phối hoặc cung cấp dịch vụ qua mạng.
