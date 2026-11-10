# Checklist nộp bài

Sinh viên: **Trần Thành Hậu**. Các ô đã đánh dấu có bằng chứng trong `VALIDATION.md` hoặc source/build tương ứng. Các ô còn trống cần kiểm tra thủ công, tài khoản hoặc tệp nộp cuối.

## Chạy và kiểm tra chức năng

- [x] Backend dùng URI Atlas trong `.env`, khởi động thành công.
- [ ] Compass mở đúng `vku_student_management.users`.
- [x] Database chỉ có `email`, `matkhau`, `hoten`, `hinhanh` và `_id` hệ thống.
- [x] `matkhau` là bcrypt hash; không có `role`, `__v` hoặc timestamps.
- [x] Có ít nhất 5 hồ sơ học tập, email duy nhất.
- [ ] Login đúng/sai hoạt động trên Web.
- [x] Đăng xuất quay về Login (Android).
- [x] Tài khoản thường không gọi được API quản trị.
- [ ] Thêm sinh viên và ảnh, Compass thấy document mới.
- [ ] Sửa tên/email/ảnh, Compass thấy thay đổi.
- [x] Để trống mật khẩu khi sửa giữ mật khẩu cũ.
- [ ] Đổi mật khẩu mới, đăng nhập lại thành công.
- [x] Hủy xóa giữ dữ liệu; xác nhận xóa mất dữ liệu thật (Android + Atlas).
- [ ] Tìm họ tên và email, đổi chiều sắp xếp.
- [x] Dashboard hiển thị tổng số phù hợp toàn collection (Android).
- [ ] Loading, danh sách rỗng và mất kết nối có thông báo.
- [ ] Web rộng/hẹp không bị overflow.
- [x] Android chạy được, hiển thị danh sách/card.
- [ ] Android chọn ảnh, preview, lưu và hiển thị lại sau tải dữ liệu.

## Kiểm tra mã nguồn và bản build

- [x] `npm.cmd test` trong backend hoàn tất: 14/14 đạt.
- [x] `flutter analyze` không có lỗi cần sửa.
- [x] `flutter test` hoàn tất: 17/17 đạt.
- [x] `flutter build web` hoàn tất.
- [x] Build/run Android đã kiểm chứng trên Pixel 9 Emulator, Android 16 API 36; integration test thật đạt.
- [ ] Ghi phiên bản SDK, Chrome, Android và thời điểm demo vào báo cáo.

## JSON database

- [x] Có `database/users.json` để import học tập.
- [x] Chạy `npm.cmd run export` sau kiểm thử Atlas: 5 hồ sơ trong `database/users.export.json`.
- [ ] Bản xuất chỉ chứa dữ liệu học tập được phép chia sẻ.
- [x] Mật khẩu trong JSON là hash, không là văn bản rõ.
- [ ] Import thử trên database/collection học tập riêng thành công.
- [ ] Đăng nhập thử sau import thành công.
- [ ] Đưa file JSON đã chọn vào gói nộp; không chỉ nộp ảnh database.

## Báo cáo, ảnh và video

- [x] Báo cáo ghi đúng tên Trần Thành Hậu và đề tài.
- [ ] Bổ sung ảnh theo bảng trong `BAO_CAO.md`.
- [ ] Mỗi ảnh có chú thích thao tác và kết quả thật.
- [x] Điền kết quả thực tế vào ma trận kiểm thử; phân biệt kiểm tra tự động với các mục thủ công còn thiếu.
- [ ] Video có Web, Android và đối chiếu dữ liệu trong Compass.
- [ ] Video không lộ `.env`, URI có mật khẩu, JWT secret hoặc thông tin riêng.
- [ ] Link video có quyền xem phù hợp; thử mở bằng cửa sổ không đăng nhập.
- [ ] Nếu môn yêu cầu PDF/DOCX, xuất bản báo cáo có ảnh sang định dạng yêu cầu và xem lại bố cục.

## GitHub và gói source

- [x] Đã push source lên https://github.com/Thanhau1105/mditerm_dnt, nhánh `main`.
- [x] `README.md` có lệnh chạy, tài khoản thử và cấu hình API URL.
- [x] `.env` được Git bỏ qua; chưa có commit chứa bí mật.
- [x] `node_modules`, `.dart_tool`, `build`, private exports, Android local settings và signing keys được Git bỏ qua.
- [x] `package-lock.json` và `pubspec.lock` đi cùng source.
- [x] Có giấy phép font Roboto trong assets.
- [x] Link GitHub đã điền trong báo cáo: https://github.com/Thanhau1105/mditerm_dnt; cần chép link vào nơi nộp bài của môn học.
- [ ] Thử clone/tải source sang thư mục sạch, cấu hình `.env` riêng và chạy theo README.

## Thông tin nộp cuối

| Mục | Điền giá trị thật |
|---|---|
| GitHub | https://github.com/Thanhau1105/mditerm_dnt |
| Video | |
| File báo cáo hiện tại | `docs/BAO_CAO.md`, có 4 ảnh Android thật |
| File JSON database | `database/users.export.json` |
| APK hoặc bản Web nếu môn yêu cầu | `frontend/build/app/outputs/flutter-apk/app-debug.apk`; Web tại http://localhost:5173 |
| Ngày hoàn tất | |
