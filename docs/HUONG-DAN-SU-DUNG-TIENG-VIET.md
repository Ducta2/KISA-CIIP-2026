# HƯỚNG DẪN SỬ DỤNG KISA-CIIP-2026 (TIẾNG VIỆT)

**Phiên bản tài liệu:** 1.0 · **Ngày:** 23/10/2026  
**Dự án:** https://github.com/Ducta2/KISA-CIIP-2026  
**Nguồn gốc:** https://github.com/rebugui/KISA-CIIP-2026

> Đây là công cụ kiểm tra cấu hình bảo mật theo hướng dẫn KISA của Hàn Quốc. Kết quả không tự động chứng minh tuân thủ tiêu chuẩn hoặc pháp luật Việt Nam. Chỉ sử dụng trên hệ thống được ủy quyền. **Bản Việt hóa hiện chưa hoàn tất toàn bộ script.**

## 1. Phạm vi

| Nhóm | Hệ thống | ID |
|---|---|---|
| Máy chủ Unix | RedHat, Debian, AIX, HP-UX, Solaris | U-01…U-67 |
| Máy chủ Windows | Windows Server 2019+ | W-01…W-64 |
| Web server | Apache, Nginx, Tomcat, IIS | WEB-01…WEB-26 |
| Cơ sở dữ liệu | MySQL, PostgreSQL, Oracle, MSSQL | D-01…D-26 |
| Máy trạm | Windows PC | P-01…P-18 |

Theo tài liệu upstream có **625 script**. Con số là tổng số script trên các nền tảng, không phải 625 tiêu chí khác nhau.

## 2. Yêu cầu trước khi chạy

- Có quyền quản trị phù hợp và được phép kiểm tra.
- Sao lưu cấu hình hoặc snapshot khi đánh giá máy chủ quan trọng; ưu tiên staging.
- Có Bash trên Linux/Unix; PowerShell trên Windows.
- Dành thư mục riêng để lưu kết quả; hạn chế truy cập vì báo cáo có thể chứa cấu hình hệ thống.
- Kiểm tra lại mọi script trước khi chạy, đặc biệt các script kết nối DBMS; không mặc định rằng toàn bộ script đều chỉ đọc.
- Không cung cấp mật khẩu DBMS bằng command-line argument, file công khai hoặc log.

## 3. Tải mã nguồn

```bash
git clone https://github.com/Ducta2/KISA-CIIP-2026.git
cd KISA-CIIP-2026
git checkout feature/vietnamese-localization
```

Branch `master` giữ nguyên mã nguồn gốc. Branch Việt hóa hiện đang được rà soát trên pull request.

## 4. Kiểm tra máy chủ Linux/Unix

### RedHat

```bash
chmod +x lib/*.sh 01.Unix서버/RedHat/*_check.sh
cd 01.Unix서버/RedHat
sudo bash U01_check.sh
```

Để chạy toàn bộ nhóm:

```bash
sudo bash 01.Unix서버_RedHat_run_all.sh
```

### Debian

```bash
cd 01.Unix서버/Debian
sudo bash U01_check.sh
sudo bash 01.Unix서버_Debian_run_all.sh
```

### Các nền tảng Unix khác

Thực thi script `U01_check.sh` hoặc script `*_run_all.sh` tương ứng trong:
- `01.Unix서버/AIX/`
- `01.Unix서버/HP-UX/`
- `01.Unix서버/Solaris/`

**Lưu ý:** Một số câu lệnh Bash/GNU có thể không tương thích hoàn toàn với Unix truyền thống. Kiểm chứng từng nền tảng trước khi triển khai.

## 5. Windows Server

Mở PowerShell với quyền quản trị, chuyển đến thư mục chứa source:

```powershell
Set-Location ".\02.Windows서버"
Get-Content .\W01_check.ps1 -TotalCount 40
powershell -NoProfile -File .\W01_check.ps1
```

Chạy toàn bộ:

```powershell
powershell -NoProfile -File ".\02.Windows서버_run_all.ps1"
```

Nếu chính sách thực thi chặn script, trước hết xác minh chữ ký, nguồn gốc và quyền thực thi. Không vô hiệu hóa chính sách bảo mật trên máy production chỉ để chạy script.

## 6. Kiểm tra web server

Ví dụ Apache:

```bash
cd 03.웹서버/Apache
bash 03.웹서버_Apache_run_all.sh
```

Các thư mục khác: `03.웹서버/Nginx`, `03.웹서버/Tomcat`, `03.웹서버/IIS`. IIS chạy với PowerShell.

## 7. Kiểm tra cơ sở dữ liệu

Ví dụ MySQL:

```bash
cd 08.DBMS/mysql
bash D01_check.sh
```

Chương trình có thể hỏi máy chủ, cổng, tài khoản và mật khẩu. Nên dùng tài khoản kiểm tra có quyền tối thiểu, không sử dụng root/DBA nếu không cần thiết. Nhóm DBMS tương ứng nằm tại `08.DBMS/mysql`, `postgresql`, `Oracle`, `MSSQL`.

## 8. Windows PC

```powershell
Set-Location ".\07.PC"
powershell -NoProfile -File .\P01_check.ps1
powershell -NoProfile -File ".\07.PC_run_all.ps1"
```

## 9. Cách đọc kết quả

Trong báo cáo JSON, giữ nguyên:
- `GOOD`: Đạt.
- `VULNERABLE`: Không đạt / có điểm yếu theo tiêu chí.
- `MANUAL`: Cần kiểm tra thủ công.
- `N/A`: Không áp dụng.

Ví dụ cấu trúc (minh họa, không phải kết quả kiểm tra thật):

```json
{
  "item_id": "U-01",
  "item_name": "Hạn chế đăng nhập từ xa bằng tài khoản root",
  "inspection": {"summary": "Đã kiểm tra cấu hình SSH", "status": "Đạt"},
  "final_result": "GOOD",
  "command": "grep -i PermitRootLogin /etc/ssh/sshd_config",
  "command_result": "PermitRootLogin no",
  "guideline": {
    "purpose": "Giảm nguy cơ chiếm quyền root từ xa",
    "security_threat": "Đăng nhập trực tiếp bằng root có thể tăng rủi ro",
    "judgment_criteria_good": "Chặn truy cập trực tiếp bằng root",
    "judgment_criteria_bad": "Cho phép truy cập trực tiếp bằng root",
    "remediation": "Kiểm tra cấu hình SSH và vô hiệu hóa root login trực tiếp"
  },
  "timestamp": "2026-10-23T10:00:00+07:00",
  "hostname": "example"
}
```

Báo cáo có thể nằm trong `results/YYYYMMDD/` dưới từng thư mục nền tảng. Các khóa JSON giữ nguyên tiếng Anh để tương thích với hệ thống xử lý dữ liệu.

## 10. Tích hợp hệ thống quản lý đánh giá

Đề xuất quy trình: **Script → JSON → bộ tiếp nhận dữ liệu → bảng kết quả → báo cáo**. Khi tích hợp n8n/SOC:
1. Lấy dữ liệu từ tệp JSON đã tạo thay vì cho workflow tự chạy lệnh root.
2. Lưu `asset_id`, `platform`, `item_id`, `final_result`, `timestamp`, `evidence`.
3. Dùng `item_id` và `final_result` làm giá trị cố định để thống kê và so sánh lịch sử.
4. Không gửi mật khẩu, token hoặc nội dung cấu hình nhạy cảm lên LLM/dịch vụ ngoài.
5. Yêu cầu kiểm tra thủ công trước khi tự động thay đổi cấu hình hệ thống.

## 11. Kiểm thử trước khi vận hành

### Bash
```bash
find . -type f -name '*.sh' -print0 | xargs -0 -n1 bash -n
```

Lệnh này kiểm tra **cú pháp**, không khẳng định script chạy đúng nghiệp vụ.

### JSON
```bash
find . -type f -path '*/results/*' -name '*.json' -print0 | xargs -0 -r -n1 jq empty
```

### Kiểm thử chức năng
- Chạy script gốc và script đã Việt hóa trên môi trường có cấu hình giống nhau.
- So sánh `item_id`, `final_result`, câu lệnh thực thi và bằng chứng.
- Kiểm tra dấu tiếng Việt trong terminal, JSON, TXT và báo cáo.
- Kiểm tra trường hợp dịch vụ không tồn tại, không đủ quyền và timeout.

## 12. Sự cố thường gặp

| Triệu chứng | Cách xử lý |
|---|---|
| Permission denied | Kiểm tra quyền tệp, quyền user và đường dẫn |
| Không tìm thấy thư viện | Chạy script từ đúng repo, kiểm tra cấu trúc `lib/` |
| Thiếu quyền root | Chỉ nâng quyền trên hệ thống được phép kiểm tra |
| JSON không hợp lệ | Dùng `jq empty`, xem ký tự escape và stdout |
| Chữ Việt lỗi font | Sử dụng terminal UTF-8 và font Unicode |
| N/A hoặc MANUAL | Đọc lý do trong kết quả, không tự quy đổi thành GOOD |
| Script bị chặn bởi Windows | Xác thực mã nguồn, chính sách execution và chữ ký trước khi cho phép chạy |

## 13. Giới hạn và giấy phép

- Giữ lại ghi nhận tác giả, thông tin bản quyền và tuân thủ **AGPL-3.0**.
- Không tự ý gắn nhãn là bộ công cụ tuân thủ TCVN, ISO 27001, Nghị định hoặc thông tư Việt Nam nếu chưa lập mapping và thẩm định độc lập.
- Nội dung chuyển ngữ không thay thế việc rà soát kỹ thuật của chuyên gia.
