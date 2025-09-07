# databaseStudentProject
Database PostgreSQL
# HỆ THỐNG QUẢN LÝ ĐỒ ÁN MÔN HỌC  
**Database Schema for Graduation/Project Management System (PostgreSQL)**

---

## 📋 Giới thiệu

Hệ thống quản lý đồ án môn học được thiết kế phục vụ cho các trường đại học, đặc biệt là khoa CNTT, giúp quản lý toàn diện quá trình thực hiện đồ án từ khi sinh viên đăng ký cho tới lúc bảo vệ, đánh giá, báo cáo và tổng kết.  
Schema này được xây dựng theo hướng **chuẩn hóa, linh hoạt và dễ mở rộng**, đáp ứng được đầy đủ các nghiệp vụ thực tế tại các trường đại học Việt Nam.

---

## 🗂️ Cấu trúc và các nhóm bảng chính

### 1. **Quản lý tổ chức**
- **khoa**: Lưu thông tin các khoa (ví dụ: CNTT, Điện tử...)
- **bo_mon**: Thông tin các bộ môn thuộc khoa.
- **chuyen_nganh**: Các chuyên ngành đào tạo.
- **lop**: Danh sách lớp theo từng chuyên ngành.

### 2. **Quản lý người dùng & phân quyền**
- **nguoi_dung**: Dữ liệu chung cho tất cả người dùng (username, email, avatar...)
- **vai_tro**: Định nghĩa các vai trò trong hệ thống (Admin, Giảng viên, Sinh viên, Giáo vụ, v.v.)
- **phan_quyen_nguoi_dung**: Mapping N-N giữa người dùng và vai trò.

### 3. **Quản lý sinh viên & giảng viên**
- **giang_vien**: Thông tin chi tiết về giảng viên (liên kết tới nguoi_dung)
- **sinh_vien**: Thông tin chi tiết sinh viên (liên kết tới nguoi_dung)

### 4. **Quy trình đồ án**
- **loai_do_an**: Phân loại các loại đồ án (Môn học, Tốt nghiệp, Thực tập...)
- **dot_lam_do_an**: Quản lý từng đợt đồ án (theo năm học, học kỳ, bộ môn/khoa)
- **dot_lam_do_an_lop**: Danh sách lớp tham gia từng đợt
- **phan_cong_giang_vien**: Phân công giảng viên hướng dẫn theo từng đợt
- **sinh_vien_dot_do_an**: Danh sách sinh viên tham gia đợt làm đồ án

### 5. **Quản lý đề tài & đăng ký**
- **de_tai_de_xuat**: Danh sách đề tài do giảng viên đề xuất
- **dang_ky_de_tai**: Thông tin sinh viên đăng ký đề tài (đề xuất hoặc tự đề xuất)

### 6. **Đồ án chính thức & quá trình thực hiện**
- **do_an**: Thông tin đồ án đã được phê duyệt và chính thức thực hiện
- **quy_trinh_huong_dan**: Quy trình hướng dẫn theo tuần (cho từng đợt)
- **bao_cao_hang_tuan**: Báo cáo tiến độ hàng tuần của sinh viên
- **nhan_xet_huong_dan**: Đánh giá, nhận xét của giảng viên hướng dẫn

### 7. **Quản lý phản biện & bảo vệ**
- **phan_cong_phan_bien**, **ket_qua_phan_bien**: Phân công và kết quả phản biện
- **hoi_dong_bao_ve**, **thanh_vien_hoi_dong**: Tạo và quản lý hội đồng bảo vệ
- **phan_cong_hoi_dong**, **ket_qua_bao_ve**: Phân công bảo vệ và kết quả chấm điểm hội đồng

### 8. **Theo dõi lịch sử, trạng thái**
- **lich_su_trang_thai**: Ghi lại lịch sử thay đổi trạng thái các đối tượng quan trọng (đồ án, đăng ký, bảo vệ...)

---

## 🏛️ Mối liên hệ giữa các bảng

- **Quan hệ cha-con** giữa tổ chức (khoa > bộ môn > chuyên ngành > lớp).
- **Sinh viên, giảng viên** đều là `nguoi_dung` (thông tin cá nhân dùng chung).
- **Đồ án** gắn với `đợt làm đồ án`, `sinh viên`, `giảng viên hướng dẫn`, `đăng ký đề tài`.
- **Đăng ký đề tài** liên kết chặt chẽ với sinh viên, giảng viên, đợt, đề tài đề xuất (hoặc đề tài tự đề xuất).
- **Quản lý vai trò** qua bảng trung gian `phan_quyen_nguoi_dung`.
- **Mỗi giai đoạn nghiệp vụ** đều có bảng lưu chi tiết trạng thái, điểm số, nhận xét, file đính kèm.

---

## ⚡ Các tính năng nâng cao nổi bật

- **Trigger** tự động cập nhật trường `updated_at` khi chỉnh sửa bản ghi.
- **Stored Function** phục vụ các nghiệp vụ thống kê:  
  - Thống kê đồ án theo đợt  
  - Lấy danh sách đề tài chưa chọn  
  - Tính tiến độ báo cáo sinh viên  
  - Lấy danh sách sinh viên chưa có giảng viên hướng dẫn
- **Views** tổng hợp giúp truy vấn thông tin đầy đủ nhanh chóng (thông tin đồ án, đăng ký, báo cáo, hội đồng...)
- **Chỉ mục (Index)** tối ưu cho các truy vấn tìm kiếm, lọc dữ liệu lớn.

---

## 🔄 Quy trình nghiệp vụ chính

1. **Quản trị viên tạo đợt làm đồ án, cấu hình lớp tham gia**
2. **Giảng viên đề xuất đề tài, hệ thống ghi nhận**
3. **Sinh viên đăng ký đề tài (chọn hoặc tự đề xuất)**
4. **Giảng viên và trưởng bộ môn duyệt đăng ký**
5. **Sinh viên chính thức thực hiện đồ án**
6. **Báo cáo tiến độ, nhận xét, chấm điểm hàng tuần**
7. **Phân công phản biện, tổ chức bảo vệ, chấm điểm**
8. **Lưu trữ lịch sử, tổng kết kết quả, báo cáo thống kê**

---

## 📝 Một số lưu ý triển khai

- **Bảo mật mật khẩu**: Lưu ý hash password ở ứng dụng, không lưu plaintext trong database.
- **Xử lý file**: Nếu lưu nhiều file báo cáo lớn, nên lưu đường dẫn và sử dụng storage ngoài (VD: Amazon S3, Google Drive).
- **Chạy lệnh tạo schema**:  
  Đảm bảo quyền user PostgreSQL đủ để tạo trigger/function/view.

---

## 💡 Liên hệ & mở rộng

- Schema này có thể mở rộng dễ dàng theo yêu cầu từng trường, từng khoa.
- Nếu cần hướng dẫn xây dựng API, truy vấn thực tế, thiết kế ERD hoặc giao diện quản trị, hãy liên hệ đội ngũ phát triển.

---

## © Hệ thống quản lý đồ án môn học - Khoa CNTT - ĐHSP Kỹ thuật Hưng Yên
