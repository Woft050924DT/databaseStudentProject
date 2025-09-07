-- ================================
-- HỆ THỐNG QUẢN LÝ ĐỒ ÁN MÔN HỌC
-- PostgreSQL Database Schema
-- ================================

-- Bảng Khoa (Faculty)
CREATE TABLE khoa (
    id SERIAL PRIMARY KEY,
    ma_khoa VARCHAR(10) NOT NULL UNIQUE,
    ten_khoa VARCHAR(255) NOT NULL,
    truong_khoa_id INTEGER,
    dia_chi TEXT,
    dien_thoai VARCHAR(15),
    email VARCHAR(100),
    trang_thai BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Bộ môn (Department)
CREATE TABLE bo_mon (
    id SERIAL PRIMARY KEY,
    ma_bo_mon VARCHAR(10) NOT NULL UNIQUE,
    ten_bo_mon VARCHAR(255) NOT NULL,
    khoa_id INTEGER NOT NULL REFERENCES khoa(id),
    truong_bo_mon_id INTEGER,
    mo_ta TEXT,
    trang_thai BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Chuyên ngành (Major)
CREATE TABLE chuyen_nganh (
    id SERIAL PRIMARY KEY,
    ma_chuyen_nganh VARCHAR(10) NOT NULL UNIQUE,
    ten_chuyen_nganh VARCHAR(255) NOT NULL,
    bo_mon_id INTEGER NOT NULL REFERENCES bo_mon(id),
    mo_ta TEXT,
    trang_thai BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Lớp (Class)
CREATE TABLE lop (
    id SERIAL PRIMARY KEY,
    ma_lop VARCHAR(20) NOT NULL UNIQUE,
    ten_lop VARCHAR(255) NOT NULL,
    chuyen_nganh_id INTEGER NOT NULL REFERENCES chuyen_nganh(id),
    khoa_hoc VARCHAR(10), -- VD: K19, K20
    so_luong_sv INTEGER DEFAULT 0,
    co_van_id INTEGER,
    trang_thai BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Vai trò người dùng (User Roles)
CREATE TABLE vai_tro (
    id SERIAL PRIMARY KEY,
    ma_vai_tro VARCHAR(20) NOT NULL UNIQUE,
    ten_vai_tro VARCHAR(100) NOT NULL,
    mo_ta TEXT,
    trang_thai BOOLEAN DEFAULT TRUE
);

-- Bảng Người dùng (Users)
CREATE TABLE nguoi_dung (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE,
    ho_ten VARCHAR(255) NOT NULL,
    gioi_tinh VARCHAR(10) CHECK (gioi_tinh IN ('Nam', 'Nữ', 'Khác')),
    ngay_sinh DATE,
    dien_thoai VARCHAR(15),
    dia_chi TEXT,
    avatar VARCHAR(255),
    trang_thai BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng phân quyền người dùng (User Role Assignments)
CREATE TABLE phan_quyen_nguoi_dung (
    id SERIAL PRIMARY KEY,
    nguoi_dung_id INTEGER NOT NULL REFERENCES nguoi_dung(id),
    vai_tro_id INTEGER NOT NULL REFERENCES vai_tro(id),
    trang_thai BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(nguoi_dung_id, vai_tro_id)
);

-- Bảng Giảng viên (Teachers)
CREATE TABLE giang_vien (
    id SERIAL PRIMARY KEY,
    nguoi_dung_id INTEGER NOT NULL REFERENCES nguoi_dung(id),
    ma_giang_vien VARCHAR(20) NOT NULL UNIQUE,
    bo_mon_id INTEGER NOT NULL REFERENCES bo_mon(id),
    hoc_vi VARCHAR(50), -- Thạc sĩ, Tiến sĩ
    hoc_ham VARCHAR(50), -- Giáo sư, Phó Giáo sư
    chuyen_mon TEXT,
    nam_kinh_nghiem INTEGER DEFAULT 0,
    trang_thai BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Sinh viên (Students)
CREATE TABLE sinh_vien (
    id SERIAL PRIMARY KEY,
    nguoi_dung_id INTEGER NOT NULL REFERENCES nguoi_dung(id),
    ma_sinh_vien VARCHAR(20) NOT NULL UNIQUE,
    lop_id INTEGER NOT NULL REFERENCES lop(id),
    nam_nhap_hoc INTEGER,
    diem_tong_ket DECIMAL(3,2),
    so_tin_chi_dat INTEGER DEFAULT 0,
    tinh_trang VARCHAR(50) DEFAULT 'Đang học', -- Đang học, Tạm nghỉ, Thôi học
    cv_file VARCHAR(255), -- File CV đính kèm
    trang_thai BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Loại đồ án (Project Types)
CREATE TABLE loai_do_an (
    id SERIAL PRIMARY KEY,
    ma_loai VARCHAR(20) NOT NULL UNIQUE,
    ten_loai VARCHAR(100) NOT NULL,
    mo_ta TEXT,
    co_phan_bien BOOLEAN DEFAULT TRUE, -- Có phản biện hay không
    co_hoi_dong BOOLEAN DEFAULT TRUE, -- Có hội đồng hay không
    so_phan_bien INTEGER DEFAULT 1,
    trang_thai BOOLEAN DEFAULT TRUE
);

-- Bảng Đợt làm đồ án (Project Batches/Rounds)
CREATE TABLE dot_lam_do_an (
    id SERIAL PRIMARY KEY,
    ma_dot VARCHAR(20) NOT NULL UNIQUE,
    ten_dot VARCHAR(255) NOT NULL,
    loai_do_an_id INTEGER NOT NULL REFERENCES loai_do_an(id),
    bo_mon_id INTEGER REFERENCES bo_mon(id),
    khoa_id INTEGER REFERENCES khoa(id),
    nam_hoc VARCHAR(20), -- VD: 2023-2024
    hoc_ky INTEGER CHECK (hoc_ky IN (1, 2, 3)), -- 1: HK1, 2: HK2, 3: Hè
    ngay_bat_dau DATE,
    ngay_ket_thuc DATE,
    han_ra_de_tai DATE,
    han_dang_ky DATE,
    han_nop_bao_cao DATE,
    quy_trinh_huong_dan TEXT, -- JSON hoặc XML chứa các bước hướng dẫn
    ghi_chu TEXT,
    trang_thai VARCHAR(50) DEFAULT 'Chuẩn bị', -- Chuẩn bị, Đang diễn ra, Kết thúc
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Lớp tham gia đợt làm đồ án
CREATE TABLE dot_lam_do_an_lop (
    id SERIAL PRIMARY KEY,
    dot_lam_do_an_id INTEGER NOT NULL REFERENCES dot_lam_do_an(id),
    lop_id INTEGER NOT NULL REFERENCES lop(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(dot_lam_do_an_id, lop_id)
);

-- Bảng Phân công giảng viên theo đợt
CREATE TABLE phan_cong_giang_vien (
    id SERIAL PRIMARY KEY,
    dot_lam_do_an_id INTEGER NOT NULL REFERENCES dot_lam_do_an(id),
    giang_vien_id INTEGER NOT NULL REFERENCES giang_vien(id),
    so_luong_huong_dan INTEGER DEFAULT 0, -- Số lượng được phép hướng dẫn
    so_luong_da_nhan INTEGER DEFAULT 0, -- Số lượng đã nhận
    ghi_chu TEXT,
    trang_thai BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(dot_lam_do_an_id, giang_vien_id)
);

-- Bảng Sinh viên tham gia đợt làm đồ án
CREATE TABLE sinh_vien_dot_do_an (
    id SERIAL PRIMARY KEY,
    dot_lam_do_an_id INTEGER NOT NULL REFERENCES dot_lam_do_an(id),
    sinh_vien_id INTEGER NOT NULL REFERENCES sinh_vien(id),
    dieu_kien_du BOOLEAN DEFAULT TRUE, -- Đủ điều kiện hay không
    ghi_chu TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(dot_lam_do_an_id, sinh_vien_id)
);

-- Bảng Đề tài do giảng viên đề xuất (Proposed Topics)
CREATE TABLE de_tai_de_xuat (
    id SERIAL PRIMARY KEY,
    ma_de_tai VARCHAR(50) NOT NULL,
    ten_de_tai VARCHAR(500) NOT NULL,
    giang_vien_id INTEGER NOT NULL REFERENCES giang_vien(id),
    dot_lam_do_an_id INTEGER NOT NULL REFERENCES dot_lam_do_an(id),
    mo_ta_de_tai TEXT,
    muc_tieu TEXT,
    yeu_cau_sinh_vien TEXT,
    cong_nghe_su_dung TEXT,
    tai_lieu_tham_khao TEXT,
    da_duoc_chon BOOLEAN DEFAULT FALSE,
    trang_thai BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(ma_de_tai, dot_lam_do_an_id)
);

-- Bảng Đăng ký đề tài (Topic Registrations)
CREATE TABLE dang_ky_de_tai (
    id SERIAL PRIMARY KEY,
    sinh_vien_id INTEGER NOT NULL REFERENCES sinh_vien(id),
    dot_lam_do_an_id INTEGER NOT NULL REFERENCES dot_lam_do_an(id),
    giang_vien_id INTEGER NOT NULL REFERENCES giang_vien(id),
    de_tai_de_xuat_id INTEGER REFERENCES de_tai_de_xuat(id), -- NULL nếu là đề tài tự đề xuất
    ten_de_tai_tu_de_xuat VARCHAR(500), -- Đề tài do sinh viên tự đề xuất
    mo_ta_de_tai_tu_de_xuat TEXT, -- Mô tả đề tài tự đề xuất
    ly_do_chon TEXT,
    trang_thai_giang_vien VARCHAR(50) DEFAULT 'Chờ phê duyệt', -- Chờ phê duyệt, Chấp nhận, Từ chối
    trang_thai_truong_bo_mon VARCHAR(50) DEFAULT 'Chờ phê duyệt', -- Chờ phê duyệt, Chấp nhận, Từ chối
    ly_do_tu_choi_gv TEXT,
    ly_do_tu_choi_tbm TEXT,
    ngay_dang_ky TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ngay_phe_duyet_gv TIMESTAMP,
    ngay_phe_duyet_tbm TIMESTAMP,
    UNIQUE(sinh_vien_id, dot_lam_do_an_id)
);

-- Bảng Đồ án chính thức (Official Projects)
CREATE TABLE do_an (
    id SERIAL PRIMARY KEY,
    ma_do_an VARCHAR(50) NOT NULL UNIQUE,
    ten_de_tai VARCHAR(500) NOT NULL,
    sinh_vien_id INTEGER NOT NULL REFERENCES sinh_vien(id),
    giang_vien_huong_dan_id INTEGER NOT NULL REFERENCES giang_vien(id),
    dot_lam_do_an_id INTEGER NOT NULL REFERENCES dot_lam_do_an(id),
    dang_ky_de_tai_id INTEGER NOT NULL REFERENCES dang_ky_de_tai(id),
    mo_ta_de_tai TEXT,
    muc_tieu TEXT,
    yeu_cau TEXT,
    cong_nghe_su_dung TEXT,
    ngay_bat_dau DATE,
    ngay_ket_thuc DATE,
    file_de_cuong VARCHAR(255),
    file_bao_cao_cuoi_khoa VARCHAR(255),
    diem_huong_dan DECIMAL(3,2),
    diem_phan_bien DECIMAL(3,2),
    diem_hoi_dong DECIMAL(3,2),
    diem_tong_ket DECIMAL(3,2),
    xep_loai VARCHAR(20), -- Xuất sắc, Giỏi, Khá, Trung bình, Yếu
    duoc_bao_ve BOOLEAN DEFAULT FALSE,
    trang_thai VARCHAR(50) DEFAULT 'Đang thực hiện', -- Đang thực hiện, Hoàn thành, Tạm dừng
    ghi_chu TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Quy trình hướng dẫn theo tuần (Weekly Guidance Process)
CREATE TABLE quy_trinh_huong_dan (
    id SERIAL PRIMARY KEY,
    dot_lam_do_an_id INTEGER NOT NULL REFERENCES dot_lam_do_an(id),
    tuan_thu INTEGER NOT NULL,
    ten_giai_doan VARCHAR(255) NOT NULL,
    mo_ta_cong_viec TEXT,
    ket_qua_mong_doi TEXT,
    trang_thai BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Báo cáo hàng tuần của sinh viên (Student Weekly Reports)
CREATE TABLE bao_cao_hang_tuan (
    id SERIAL PRIMARY KEY,
    do_an_id INTEGER NOT NULL REFERENCES do_an(id),
    tuan_thu INTEGER NOT NULL,
    ngay_bao_cao DATE DEFAULT CURRENT_DATE,
    noi_dung_thuc_hien TEXT,
    ket_qua_dat_duoc TEXT,
    kho_khan_gap_phai TEXT,
    ke_hoach_tuan_toi TEXT,
    file_dinh_kem VARCHAR(255),
    trang_thai_sinh_vien VARCHAR(50) DEFAULT 'Đã nộp',
    trang_thai_giang_vien VARCHAR(50) DEFAULT 'Chờ phản hồi', -- Chờ phản hồi, Đã phản hồi
    nhan_xet_giang_vien TEXT,
    diem_tuan DECIMAL(3,2),
    ngay_phan_hoi TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(do_an_id, tuan_thu)
);

-- Bảng Nhận xét hướng dẫn (Guidance Comments)
CREATE TABLE nhan_xet_huong_dan (
    id SERIAL PRIMARY KEY,
    do_an_id INTEGER NOT NULL REFERENCES do_an(id),
    giang_vien_id INTEGER NOT NULL REFERENCES giang_vien(id),
    noi_dung_nhan_xet TEXT,
    danh_gia_thai_do TEXT,
    danh_gia_nang_luc TEXT,
    danh_gia_ket_qua TEXT,
    diem_huong_dan DECIMAL(3,2),
    cho_phep_bao_ve BOOLEAN DEFAULT FALSE,
    ly_do_khong_cho_bao_ve TEXT,
    ngay_nhan_xet DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(do_an_id, giang_vien_id)
);

-- Bảng Phân công phản biện (Review Assignments)
CREATE TABLE phan_cong_phan_bien (
    id SERIAL PRIMARY KEY,
    do_an_id INTEGER NOT NULL REFERENCES do_an(id),
    giang_vien_phan_bien_id INTEGER NOT NULL REFERENCES giang_vien(id),
    thu_tu INTEGER DEFAULT 1, -- Phản biện 1, 2, ...
    ngay_phan_cong DATE DEFAULT CURRENT_DATE,
    han_phan_bien DATE,
    trang_thai VARCHAR(50) DEFAULT 'Chờ phản biện', -- Chờ phản biện, Đã phản biện
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(do_an_id, giang_vien_phan_bien_id)
);

-- Bảng Kết quả phản biện (Review Results)
CREATE TABLE ket_qua_phan_bien (
    id SERIAL PRIMARY KEY,
    phan_cong_phan_bien_id INTEGER NOT NULL REFERENCES phan_cong_phan_bien(id),
    noi_dung_phan_bien TEXT,
    danh_gia_de_tai TEXT,
    danh_gia_ket_qua TEXT,
    gop_y_sua_chua TEXT,
    diem_phan_bien DECIMAL(3,2),
    cho_phep_bao_ve BOOLEAN DEFAULT FALSE,
    ly_do_khong_cho_bao_ve TEXT,
    ngay_phan_bien DATE DEFAULT CURRENT_DATE,
    file_phan_bien VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(phan_cong_phan_bien_id)
);

-- Bảng Hội đồng bảo vệ (Defense Councils)
CREATE TABLE hoi_dong_bao_ve (
    id SERIAL PRIMARY KEY,
    ma_hoi_dong VARCHAR(50) NOT NULL UNIQUE,
    ten_hoi_dong VARCHAR(255) NOT NULL,
    dot_lam_do_an_id INTEGER NOT NULL REFERENCES dot_lam_do_an(id),
    chu_tich_id INTEGER NOT NULL REFERENCES giang_vien(id),
    thu_ky_id INTEGER REFERENCES giang_vien(id),
    ngay_bao_ve DATE,
    gio_bat_dau TIME,
    gio_ket_thuc TIME,
    dia_diem VARCHAR(255),
    trang_thai VARCHAR(50) DEFAULT 'Chuẩn bị', -- Chuẩn bị, Đang diễn ra, Hoàn thành
    ghi_chu TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng Thành viên hội đồng (Council Members)
CREATE TABLE thanh_vien_hoi_dong (
    id SERIAL PRIMARY KEY,
    hoi_dong_bao_ve_id INTEGER NOT NULL REFERENCES hoi_dong_bao_ve(id),
    giang_vien_id INTEGER NOT NULL REFERENCES giang_vien(id),
    vai_tro VARCHAR(50) NOT NULL, -- Chủ tịch, Thư ký, Thành viên, Phản biện
    thu_tu INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(hoi_dong_bao_ve_id, giang_vien_id)
);

-- Bảng Phân công đồ án vào hội đồng (Project Council Assignments)
CREATE TABLE phan_cong_hoi_dong (
    id SERIAL PRIMARY KEY,
    hoi_dong_bao_ve_id INTEGER NOT NULL REFERENCES hoi_dong_bao_ve(id),
    do_an_id INTEGER NOT NULL REFERENCES do_an(id),
    thu_tu_bao_ve INTEGER,
    gio_bao_ve TIME,
    trang_thai VARCHAR(50) DEFAULT 'Chờ bảo vệ', -- Chờ bảo vệ, Đang bảo vệ, Hoàn thành
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(hoi_dong_bao_ve_id, do_an_id)
);

-- Bảng Kết quả bảo vệ (Defense Results)
CREATE TABLE ket_qua_bao_ve (
    id SERIAL PRIMARY KEY,
    phan_cong_hoi_dong_id INTEGER NOT NULL REFERENCES phan_cong_hoi_dong(id),
    giang_vien_id INTEGER NOT NULL REFERENCES giang_vien(id),
    diem_bao_ve DECIMAL(3,2),
    nhan_xet TEXT,
    gop_y TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(phan_cong_hoi_dong_id, giang_vien_id)
);

-- Bảng Lịch sử thay đổi trạng thái (Status Change History)
CREATE TABLE lich_su_trang_thai (
    id SERIAL PRIMARY KEY,
    bang_lien_quan VARCHAR(50) NOT NULL, -- Tên bảng: do_an, dang_ky_de_tai, etc.
    id_ban_ghi INTEGER NOT NULL, -- ID của bản ghi trong bảng liên quan
    trang_thai_cu VARCHAR(100),
    trang_thai_moi VARCHAR(100),
    nguoi_thay_doi_id INTEGER REFERENCES nguoi_dung(id),
    ly_do_thay_doi TEXT,
    ngay_thay_doi TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================
-- FOREIGN KEY CONSTRAINTS
-- ================================

-- Thêm foreign key cho trưởng khoa
ALTER TABLE khoa ADD CONSTRAINT fk_khoa_truong_khoa 
    FOREIGN KEY (truong_khoa_id) REFERENCES giang_vien(id);

-- Thêm foreign key cho trưởng bộ môn
ALTER TABLE bo_mon ADD CONSTRAINT fk_bo_mon_truong_bo_mon 
    FOREIGN KEY (truong_bo_mon_id) REFERENCES giang_vien(id);

-- Thêm foreign key cho cố vấn học tập
ALTER TABLE lop ADD CONSTRAINT fk_lop_co_van 
    FOREIGN KEY (co_van_id) REFERENCES giang_vien(id);

-- ================================
-- INDEXES FOR BETTER PERFORMANCE
-- ================================

-- Indexes cho các trường tìm kiếm thường xuyên
CREATE INDEX idx_nguoi_dung_username ON nguoi_dung(username);
CREATE INDEX idx_nguoi_dung_email ON nguoi_dung(email);
CREATE INDEX idx_giang_vien_ma ON giang_vien(ma_giang_vien);
CREATE INDEX idx_sinh_vien_ma ON sinh_vien(ma_sinh_vien);
CREATE INDEX idx_do_an_ma ON do_an(ma_do_an);
CREATE INDEX idx_do_an_trang_thai ON do_an(trang_thai);
CREATE INDEX idx_dot_lam_do_an_trang_thai ON dot_lam_do_an(trang_thai);
CREATE INDEX idx_dang_ky_de_tai_trang_thai ON dang_ky_de_tai(trang_thai_giang_vien, trang_thai_truong_bo_mon);
CREATE INDEX idx_bao_cao_hang_tuan_do_an ON bao_cao_hang_tuan(do_an_id);
CREATE INDEX idx_bao_cao_hang_tuan_tuan ON bao_cao_hang_tuan(tuan_thu);

-- ================================
-- INSERT INITIAL DATA
-- ================================

-- Thêm dữ liệu vai trò
INSERT INTO vai_tro (ma_vai_tro, ten_vai_tro, mo_ta) VALUES
('ADMIN', 'Quản trị hệ thống', 'Toàn quyền quản lý hệ thống'),
('GIAO_VU', 'Giáo vụ khoa', 'Quản lý dữ liệu khoa, sinh viên'),
('TRUONG_KHOA', 'Trưởng khoa', 'Lãnh đạo khoa'),
('TRUONG_BO_MON', 'Trưởng bộ môn', 'Lãnh đạo bộ môn'),
('GIANG_VIEN', 'Giảng viên', 'Hướng dẫn đồ án'),
('SINH_VIEN', 'Sinh viên', 'Thực hiện đồ án');

-- Thêm dữ liệu loại đồ án
INSERT INTO loai_do_an (ma_loai, ten_loai, mo_ta, co_phan_bien, co_hoi_dong, so_phan_bien) VALUES
('DA_MON_HOC', 'Đồ án môn học', 'Đồ án cuối khóa của một môn học cụ thể', TRUE, FALSE, 1),
('DA_TOT_NGHIEP', 'Đồ án tốt nghiệp', 'Đồ án tốt nghiệp cho sinh viên năm cuối', TRUE, TRUE, 2),
('DA_THUC_TAP', 'Đồ án thực tập', 'Đồ án sau thời gian thực tập tại doanh nghiệp', TRUE, FALSE, 1);

-- ================================
-- TRIGGERS FOR AUTO UPDATE
-- ================================

-- Trigger để tự động cập nhật updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Áp dụng trigger cho các bảng cần thiết
CREATE TRIGGER update_khoa_updated_at BEFORE UPDATE ON khoa 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    
CREATE TRIGGER update_bo_mon_updated_at BEFORE UPDATE ON bo_mon 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    
CREATE TRIGGER update_nguoi_dung_updated_at BEFORE UPDATE ON nguoi_dung 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    
CREATE TRIGGER update_giang_vien_updated_at BEFORE UPDATE ON giang_vien 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    
CREATE TRIGGER update_sinh_vien_updated_at BEFORE UPDATE ON sinh_vien 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    
CREATE TRIGGER update_dot_lam_do_an_updated_at BEFORE UPDATE ON dot_lam_do_an 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    
CREATE TRIGGER update_do_an_updated_at BEFORE UPDATE ON do_an 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ================================
-- STORED PROCEDURES / FUNCTIONS
-- ================================

-- Function để lấy thống kê đồ án theo đợt
CREATE OR REPLACE FUNCTION get_thong_ke_do_an_theo_dot(p_dot_id INTEGER)
RETURNS TABLE(
    tong_sinh_vien INTEGER,
    da_dang_ky INTEGER,
    cho_phe_duyet INTEGER,
    dang_thuc_hien INTEGER,
    hoan_thanh INTEGER,
    tong_giang_vien INTEGER,
    tong_de_tai INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM sinh_vien_dot_do_an WHERE dot_lam_do_an_id = p_dot_id)::INTEGER as tong_sinh_vien,
        (SELECT COUNT(*) FROM dang_ky_de_tai WHERE dot_lam_do_an_id = p_dot_id)::INTEGER as da_dang_ky,
        (SELECT COUNT(*) FROM dang_ky_de_tai WHERE dot_lam_do_an_id = p_dot_id 
         AND trang_thai_giang_vien = 'Chờ phê duyệt')::INTEGER as cho_phe_duyet,
        (SELECT COUNT(*) FROM do_an WHERE dot_lam_do_an_id = p_dot_id 
         AND trang_thai = 'Đang thực hiện')::INTEGER as dang_thuc_hien,
        (SELECT COUNT(*) FROM do_an WHERE dot_lam_do_an_id = p_dot_id 
         AND trang_thai = 'Hoàn thành')::INTEGER as hoan_thanh,
        (SELECT COUNT(*) FROM phan_cong_giang_vien WHERE dot_lam_do_an_id = p_dot_id)::INTEGER as tong_giang_vien,
        (SELECT COUNT(*) FROM de_tai_de_xuat WHERE dot_lam_do_an_id = p_dot_id)::INTEGER as tong_de_tai;
END;
$$ LANGUAGE plpgsql;

-- Function để cập nhật số lượng đã nhận của giảng viên
CREATE OR REPLACE FUNCTION cap_nhat_so_luong_da_nhan()
RETURNS TRIGGER AS $
BEGIN
    -- Cập nhật khi có đăng ký mới được chấp nhận
    IF TG_OP = 'UPDATE' AND OLD.trang_thai_giang_vien != 'Chấp nhận' 
       AND NEW.trang_thai_giang_vien = 'Chấp nhận' THEN
        UPDATE phan_cong_giang_vien 
        SET so_luong_da_nhan = so_luong_da_nhan + 1
        WHERE giang_vien_id = NEW.giang_vien_id 
          AND dot_lam_do_an_id = NEW.dot_lam_do_an_id;
    
    -- Cập nhật khi đăng ký bị từ chối hoặc hủy
    ELSIF TG_OP = 'UPDATE' AND OLD.trang_thai_giang_vien = 'Chấp nhận' 
          AND NEW.trang_thai_giang_vien != 'Chấp nhận' THEN
        UPDATE phan_cong_giang_vien 
        SET so_luong_da_nhan = GREATEST(so_luong_da_nhan - 1, 0)
        WHERE giang_vien_id = OLD.giang_vien_id 
          AND dot_lam_do_an_id = OLD.dot_lam_do_an_id;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$ LANGUAGE plpgsql;

-- Trigger cho function trên
CREATE TRIGGER trigger_cap_nhat_so_luong_da_nhan
    AFTER UPDATE ON dang_ky_de_tai
    FOR EACH ROW EXECUTE FUNCTION cap_nhat_so_luong_da_nhan();

-- ================================
-- VIEWS FOR COMMON QUERIES
-- ================================

-- View thông tin đầy đủ về đồ án
CREATE VIEW v_thong_tin_do_an AS
SELECT 
    da.id,
    da.ma_do_an,
    da.ten_de_tai,
    sv.ma_sinh_vien,
    nd_sv.ho_ten as ten_sinh_vien,
    nd_sv.email as email_sinh_vien,
    l.ten_lop,
    gv.ma_giang_vien,
    nd_gv.ho_ten as ten_giang_vien,
    nd_gv.email as email_giang_vien,
    bm.ten_bo_mon,
    dlda.ten_dot,
    dlda.nam_hoc,
    dlda.hoc_ky,
    lda.ten_loai as loai_do_an,
    da.ngay_bat_dau,
    da.ngay_ket_thuc,
    da.diem_huong_dan,
    da.diem_phan_bien,
    da.diem_hoi_dong,
    da.diem_tong_ket,
    da.xep_loai,
    da.trang_thai,
    da.duoc_bao_ve,
    da.created_at,
    da.updated_at
FROM do_an da
JOIN sinh_vien sv ON da.sinh_vien_id = sv.id
JOIN nguoi_dung nd_sv ON sv.nguoi_dung_id = nd_sv.id
JOIN lop l ON sv.lop_id = l.id
JOIN giang_vien gv ON da.giang_vien_huong_dan_id = gv.id
JOIN nguoi_dung nd_gv ON gv.nguoi_dung_id = nd_gv.id
JOIN bo_mon bm ON gv.bo_mon_id = bm.id
JOIN dot_lam_do_an dlda ON da.dot_lam_do_an_id = dlda.id
JOIN loai_do_an lda ON dlda.loai_do_an_id = lda.id;

-- View thông tin đăng ký đề tài
CREATE VIEW v_dang_ky_de_tai AS
SELECT 
    dkdt.id,
    sv.ma_sinh_vien,
    nd_sv.ho_ten as ten_sinh_vien,
    nd_sv.email as email_sinh_vien,
    l.ten_lop,
    gv.ma_giang_vien,
    nd_gv.ho_ten as ten_giang_vien,
    nd_gv.email as email_giang_vien,
    dlda.ten_dot,
    COALESCE(dtdx.ten_de_tai, dkdt.ten_de_tai_tu_de_xuat) as ten_de_tai,
    COALESCE(dtdx.mo_ta_de_tai, dkdt.mo_ta_de_tai_tu_de_xuat) as mo_ta_de_tai,
    dkdt.trang_thai_giang_vien,
    dkdt.trang_thai_truong_bo_mon,
    dkdt.ly_do_tu_choi_gv,
    dkdt.ly_do_tu_choi_tbm,
    dkdt.ngay_dang_ky,
    dkdt.ngay_phe_duyet_gv,
    dkdt.ngay_phe_duyet_tbm
FROM dang_ky_de_tai dkdt
JOIN sinh_vien sv ON dkdt.sinh_vien_id = sv.id
JOIN nguoi_dung nd_sv ON sv.nguoi_dung_id = nd_sv.id
JOIN lop l ON sv.lop_id = l.id
JOIN giang_vien gv ON dkdt.giang_vien_id = gv.id
JOIN nguoi_dung nd_gv ON gv.nguoi_dung_id = nd_gv.id
JOIN dot_lam_do_an dlda ON dkdt.dot_lam_do_an_id = dlda.id
LEFT JOIN de_tai_de_xuat dtdx ON dkdt.de_tai_de_xuat_id = dtdx.id;

-- View báo cáo hàng tuần
CREATE VIEW v_bao_cao_hang_tuan AS
SELECT 
    bcht.id,
    da.ma_do_an,
    da.ten_de_tai,
    sv.ma_sinh_vien,
    nd_sv.ho_ten as ten_sinh_vien,
    gv.ma_giang_vien,
    nd_gv.ho_ten as ten_giang_vien,
    bcht.tuan_thu,
    bcht.ngay_bao_cao,
    bcht.noi_dung_thuc_hien,
    bcht.ket_qua_dat_duoc,
    bcht.kho_khan_gap_phai,
    bcht.ke_hoach_tuan_toi,
    bcht.trang_thai_sinh_vien,
    bcht.trang_thai_giang_vien,
    bcht.nhan_xet_giang_vien,
    bcht.diem_tuan,
    bcht.ngay_phan_hoi
FROM bao_cao_hang_tuan bcht
JOIN do_an da ON bcht.do_an_id = da.id
JOIN sinh_vien sv ON da.sinh_vien_id = sv.id
JOIN nguoi_dung nd_sv ON sv.nguoi_dung_id = nd_sv.id
JOIN giang_vien gv ON da.giang_vien_huong_dan_id = gv.id
JOIN nguoi_dung nd_gv ON gv.nguoi_dung_id = nd_gv.id;

-- View thông tin hội đồng bảo vệ
CREATE VIEW v_hoi_dong_bao_ve AS
SELECT 
    hdbv.id,
    hdbv.ma_hoi_dong,
    hdbv.ten_hoi_dong,
    dlda.ten_dot,
    nd_ct.ho_ten as chu_tich,
    nd_tk.ho_ten as thu_ky,
    hdbv.ngay_bao_ve,
    hdbv.gio_bat_dau,
    hdbv.gio_ket_thuc,
    hdbv.dia_diem,
    hdbv.trang_thai,
    COUNT(pchd.do_an_id) as so_luong_do_an
FROM hoi_dong_bao_ve hdbv
JOIN dot_lam_do_an dlda ON hdbv.dot_lam_do_an_id = dlda.id
JOIN giang_vien gv_ct ON hdbv.chu_tich_id = gv_ct.id
JOIN nguoi_dung nd_ct ON gv_ct.nguoi_dung_id = nd_ct.id
LEFT JOIN giang_vien gv_tk ON hdbv.thu_ky_id = gv_tk.id
LEFT JOIN nguoi_dung nd_tk ON gv_tk.nguoi_dung_id = nd_tk.id
LEFT JOIN phan_cong_hoi_dong pchd ON hdbv.id = pchd.hoi_dong_bao_ve_id
GROUP BY hdbv.id, dlda.ten_dot, nd_ct.ho_ten, nd_tk.ho_ten;

-- ================================
-- ADDITIONAL USEFUL FUNCTIONS
-- ================================

-- Function để lấy danh sách đề tài còn trống
CREATE OR REPLACE FUNCTION get_de_tai_con_trong(p_dot_id INTEGER)
RETURNS TABLE(
    de_tai_id INTEGER,
    ma_de_tai VARCHAR(50),
    ten_de_tai VARCHAR(500),
    ten_giang_vien VARCHAR(255),
    ma_giang_vien VARCHAR(20),
    mo_ta_de_tai TEXT
) AS $
BEGIN
    RETURN QUERY
    SELECT 
        dtdx.id,
        dtdx.ma_de_tai,
        dtdx.ten_de_tai,
        nd.ho_ten,
        gv.ma_giang_vien,
        dtdx.mo_ta_de_tai
    FROM de_tai_de_xuat dtdx
    JOIN giang_vien gv ON dtdx.giang_vien_id = gv.id
    JOIN nguoi_dung nd ON gv.nguoi_dung_id = nd.id
    WHERE dtdx.dot_lam_do_an_id = p_dot_id
      AND dtdx.da_duoc_chon = FALSE
      AND dtdx.trang_thai = TRUE;
END;
$ LANGUAGE plpgsql;

-- Function để tính tiến độ báo cáo của sinh viên
CREATE OR REPLACE FUNCTION get_tien_do_bao_cao(p_do_an_id INTEGER)
RETURNS TABLE(
    tong_tuan INTEGER,
    da_bao_cao INTEGER,
    ty_le_hoan_thanh DECIMAL(5,2),
    diem_trung_binh DECIMAL(3,2)
) AS $
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM quy_trinh_huong_dan qthd 
         JOIN do_an da ON qthd.dot_lam_do_an_id = da.dot_lam_do_an_id
         WHERE da.id = p_do_an_id AND qthd.trang_thai = TRUE)::INTEGER as tong_tuan,
        (SELECT COUNT(*) FROM bao_cao_hang_tuan 
         WHERE do_an_id = p_do_an_id)::INTEGER as da_bao_cao,
        CASE 
            WHEN (SELECT COUNT(*) FROM quy_trinh_huong_dan qthd 
                  JOIN do_an da ON qthd.dot_lam_do_an_id = da.dot_lam_do_an_id
                  WHERE da.id = p_do_an_id AND qthd.trang_thai = TRUE) = 0 THEN 0.00
            ELSE 
                (SELECT COUNT(*) FROM bao_cao_hang_tuan WHERE do_an_id = p_do_an_id)::DECIMAL * 100.0 / 
                (SELECT COUNT(*) FROM quy_trinh_huong_dan qthd 
                 JOIN do_an da ON qthd.dot_lam_do_an_id = da.dot_lam_do_an_id
                 WHERE da.id = p_do_an_id AND qthd.trang_thai = TRUE)::DECIMAL
        END as ty_le_hoan_thanh,
        (SELECT AVG(diem_tuan) FROM bao_cao_hang_tuan 
         WHERE do_an_id = p_do_an_id AND diem_tuan IS NOT NULL) as diem_trung_binh;
END;
$ LANGUAGE plpgsql;

-- Function để lấy danh sách sinh viên chưa có giảng viên hướng dẫn
CREATE OR REPLACE FUNCTION get_sinh_vien_chua_co_giang_vien(p_dot_id INTEGER)
RETURNS TABLE(
    sinh_vien_id INTEGER,
    ma_sinh_vien VARCHAR(20),
    ho_ten VARCHAR(255),
    ten_lop VARCHAR(255),
    email VARCHAR(100),
    dien_thoai VARCHAR(15)
) AS $
BEGIN
    RETURN QUERY
    SELECT 
        sv.id,
        sv.ma_sinh_vien,
        nd.ho_ten,
        l.ten_lop,
        nd.email,
        nd.dien_thoai
    FROM sinh_vien_dot_do_an svdda
    JOIN sinh_vien sv ON svdda.sinh_vien_id = sv.id
    JOIN nguoi_dung nd ON sv.nguoi_dung_id = nd.id
    JOIN lop l ON sv.lop_id = l.id
    WHERE svdda.dot_lam_do_an_id = p_dot_id
      AND svdda.dieu_kien_du = TRUE
      AND NOT EXISTS (
          SELECT 1 FROM dang_ky_de_tai dkdt 
          WHERE dkdt.sinh_vien_id = sv.id 
            AND dkdt.dot_lam_do_an_id = p_dot_id
            AND dkdt.trang_thai_giang_vien = 'Chấp nhận'
            AND dkdt.trang_thai_truong_bo_mon = 'Chấp nhận'
      );
END;
$ LANGUAGE plpgsql;

-- ================================
-- SAMPLE DATA (Optional)
-- ================================

-- Tạo dữ liệu mẫu cho khoa CNTT
INSERT INTO khoa (ma_khoa, ten_khoa, dia_chi, dien_thoai, email) VALUES
('CNTT', 'Khoa Công nghệ thông tin', 'Trường Đại học Sư phạm Kỹ thuật Hưng Yên', '0123456789', 'cntt@utehy.edu.vn');

-- Tạo dữ liệu mẫu cho bộ môn
INSERT INTO bo_mon (ma_bo_mon, ten_bo_mon, khoa_id, mo_ta) VALUES
('CNPM', 'Bộ môn Công nghệ phần mềm', 1, 'Bộ môn chuyên về phát triển phần mềm'),
('HTTT', 'Bộ môn Hệ thống thông tin', 1, 'Bộ môn chuyên về hệ thống thông tin'),
('MMT', 'Bộ môn Mạng máy tính', 1, 'Bộ môn chuyên về mạng và bảo mật');

-- Tạo dữ liệu mẫu cho chuyên ngành
INSERT INTO chuyen_nganh (ma_chuyen_nganh, ten_chuyen_nganh, bo_mon_id, mo_ta) VALUES
('CNPM', 'Công nghệ phần mềm', 1, 'Chuyên ngành phát triển phần mềm'),
('HTTT', 'Hệ thống thông tin', 2, 'Chuyên ngành quản lý hệ thống thông tin'),
('ATTT', 'An toàn thông tin', 3, 'Chuyên ngành bảo mật thông tin');

-- Tạo dữ liệu mẫu cho lớp
INSERT INTO lop (ma_lop, ten_lop, chuyen_nganh_id, khoa_hoc, so_luong_sv) VALUES
('CNPM-K20A', 'Công nghệ phần mềm K20A', 1, 'K20', 35),
('CNPM-K20B', 'Công nghệ phần mềm K20B', 1, 'K20', 40),
('HTTT-K20', 'Hệ thống thông tin K20', 2, 'K20', 30),
('ATTT-K20', 'An toàn thông tin K20', 3, 'K20', 25);

-- ================================
-- COMMENTS FOR DOCUMENTATION
-- ================================

COMMENT ON DATABASE postgres IS 'Hệ thống quản lý đồ án môn học - Khoa CNTT';

COMMENT ON TABLE khoa IS 'Bảng lưu thông tin các khoa trong trường';
COMMENT ON TABLE bo_mon IS 'Bảng lưu thông tin các bộ môn thuộc khoa';
COMMENT ON TABLE chuyen_nganh IS 'Bảng lưu thông tin chuyên ngành đào tạo';
COMMENT ON TABLE lop IS 'Bảng lưu thông tin các lớp học';
COMMENT ON TABLE vai_tro IS 'Bảng định nghĩa các vai trò trong hệ thống';
COMMENT ON TABLE nguoi_dung IS 'Bảng lưu thông tin cơ bản của tất cả người dùng';
COMMENT ON TABLE phan_quyen_nguoi_dung IS 'Bảng phân quyền vai trò cho người dùng';
COMMENT ON TABLE giang_vien IS 'Bảng lưu thông tin chi tiết giảng viên';
COMMENT ON TABLE sinh_vien IS 'Bảng lưu thông tin chi tiết sinh viên';
COMMENT ON TABLE loai_do_an IS 'Bảng định nghĩa các loại đồ án (môn học, tốt nghiệp)';
COMMENT ON TABLE dot_lam_do_an IS 'Bảng quản lý các đợt làm đồ án';
COMMENT ON TABLE de_tai_de_xuat IS 'Bảng lưu các đề tài do giảng viên đề xuất';
COMMENT ON TABLE dang_ky_de_tai IS 'Bảng lưu thông tin đăng ký đề tài của sinh viên';
COMMENT ON TABLE do_an IS 'Bảng lưu thông tin chính thức các đồ án';
COMMENT ON TABLE quy_trinh_huong_dan IS 'Bảng định nghĩa quy trình hướng dẫn theo tuần';
COMMENT ON TABLE bao_cao_hang_tuan IS 'Bảng lưu báo cáo hàng tuần của sinh viên';
COMMENT ON TABLE nhan_xet_huong_dan IS 'Bảng lưu nhận xét của giảng viên hướng dẫn';
COMMENT ON TABLE phan_cong_phan_bien IS 'Bảng phân công giảng viên phản biện';
COMMENT ON TABLE ket_qua_phan_bien IS 'Bảng lưu kết quả phản biện';
COMMENT ON TABLE hoi_dong_bao_ve IS 'Bảng quản lý hội đồng bảo vệ đồ án';
COMMENT ON TABLE thanh_vien_hoi_dong IS 'Bảng lưu thành viên của hội đồng bảo vệ';
COMMENT ON TABLE phan_cong_hoi_dong IS 'Bảng phân công đồ án vào hội đồng bảo vệ';
COMMENT ON TABLE ket_qua_bao_ve IS 'Bảng lưu kết quả bảo vệ của từng thành viên hội đồng';
COMMENT ON TABLE lich_su_trang_thai IS 'Bảng lưu lịch sử thay đổi trạng thái';

-- ================================
-- END OF SCHEMA
-- ================================