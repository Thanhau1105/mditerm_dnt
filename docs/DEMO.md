# Kịch bản video demo và câu hỏi bảo vệ

Sinh viên: **Trần Thành Hậu**. Đề tài: **Xây dựng ứng dụng Quản lý Sinh viên VKU bằng Flutter và MongoDB**.

## Chuẩn bị trước khi quay

1. Điền URI trong `.env`, chạy backend và Flutter Web theo README.
2. Seed bộ dữ liệu học tập nếu cần; đăng nhập thử trước để chắc thông tin đúng.
3. Mở Compass tại `vku_student_management.users`, thu gọn phần kết nối để không lộ mật khẩu/URI.
4. Bật Pixel 9 hoặc điện thoại Android, chạy app với API URL đúng cho thiết bị.
5. Chuẩn bị một ảnh PNG/JPEG/WebP dưới 2 MiB trên máy tính và trên Android.
6. Đóng `.env`, trình quản lý mật khẩu và các thông báo riêng tư trước khi chia sẻ màn hình.
7. Dùng dữ liệu mẫu được phép chia sẻ. Chuẩn bị một email thử chưa tồn tại, ví dụ `demo.video@vku.udn.vn`.

Nếu quay toàn màn hình bằng OBS hoặc công cụ có sẵn, kiểm tra khung hình và âm thanh ngắn trước. Không cần ghi cảnh cài thư viện dài; tập trung vào chức năng, dữ liệu thật và khả năng chạy đa nền tảng.

## Kịch bản khoảng 6–8 phút

| Thời lượng gợi ý | Thao tác | Nội dung giải thích |
|---|---|---|
| 0:00–0:30 | Giới thiệu tên, đề tài và công nghệ | “Em là Trần Thành Hậu. Ứng dụng dùng Flutter Web/Android, backend Node.js và MongoDB Atlas.” |
| 0:30–1:00 | Mở source và terminal backend | Chỉ ra frontend/backend/database; backend đã kết nối MongoDB, bí mật ở `.env`. |
| 1:00–1:40 | Mở Login, thử sai rồi đăng nhập đúng | Validation, nút hiện/ẩn mật khẩu và xác thực ở server. |
| 1:40–2:20 | Dashboard, tìm kiếm theo tên/email, đổi sort | Tổng số document, dữ liệu lấy từ database, bố cục bảng trên Web. |
| 2:20–3:20 | Thêm sinh viên có ảnh, lưu | Preview, thông báo thành công, dòng mới và tổng số cập nhật. |
| 3:20–4:00 | Refresh Compass, mở document vừa thêm | Chỉ có bốn trường nghiệp vụ + `_id`; `matkhau` là hash, `hinhanh` là Base64. |
| 4:00–4:45 | Sửa tên/ảnh, để trống mật khẩu | Lưu thật và giữ mật khẩu cũ; đối chiếu Compass sau refresh. |
| 4:45–5:15 | Mở xóa, nhấn Hủy, rồi xóa xác nhận | Hủy giữ dữ liệu; xác nhận xóa ở UI và Compass. |
| 5:15–6:20 | Chuyển Android, đăng nhập và chọn ảnh | Giao diện card/FAB, chọn ảnh thư viện, lưu và tải lại. |
| 6:20–7:00 | Đăng xuất; giới thiệu JSON và README | File JSON import được, các lệnh chạy và source GitHub. |
| 7:00–7:30 | Kết thúc | Nêu chức năng hoàn thành và giới hạn theo đề bài. |

Nếu thời lượng cho phép, thêm một lần đăng nhập tài khoản thường để cho thấy chỉ xem hồ sơ và backend chặn quyền quản trị. Không thao tác xóa tài khoản quản trị đang dùng.

## Chứng minh dữ liệu tồn tại thật

Thực hiện ít nhất một chuỗi liền mạch: thêm trong Web → refresh Compass thấy document → mở Android thấy cùng dữ liệu. Đổi tên hoặc ảnh rồi refresh để chứng minh lưu bền vững. Khi cần đăng nhập lại sau refresh Web, giải thích phiên được giữ trong bộ nhớ.

Việc mở Compass thành công chỉ chứng minh Compass kết nối. Để chứng minh ứng dụng kết nối đúng database, cần thấy thao tác Flutter thay đổi document tương ứng.

## Khi demo gặp lỗi

- Nếu backend tắt, mở terminal chạy lại và dùng Retry/tải lại danh sách.
- Nếu Atlas timeout, kiểm tra mạng/IP Access List trước khi quay lại; không mở toàn bộ `.env` trên video.
- Nếu Android không gọi được API, đối chiếu `10.0.2.2` cho emulator hoặc IPv4 LAN cho điện thoại thật.
- Nếu email bị trùng, dùng email học tập mới hoặc sửa hồ sơ đã có; không xóa dữ liệu không liên quan.
- Nếu picker bị hủy, form giữ nguyên và chọn ảnh lại.

## Câu hỏi giảng viên có thể hỏi

**1. Tại sao cần backend thay vì Flutter nối MongoDB trực tiếp?**  
Backend giữ URI/secret, kiểm tra dữ liệu và quyền tập trung. Flutter chỉ gọi HTTP và không chứa thông tin kết nối database.

**2. Compass có phải MongoDB Server không?**  
Compass là ứng dụng quản lý và kết nối. Trong dự án này, dữ liệu được MongoDB Atlas lưu trên cloud.

**3. Database có đúng bốn trường không? `_id` từ đâu?**  
Bốn trường nghiệp vụ là `email`, `matkhau`, `hoten`, `hinhanh`. `_id` là trường hệ thống MongoDB. Schema tắt timestamps và version key.

**4. Tại sao không lưu mật khẩu rõ?**  
Ứng dụng hash bằng bcrypt trước khi lưu. Khi login dùng `bcrypt.compare`, không giải mã hash. API hồ sơ không trả hash ra frontend.

**5. Không có `role` thì xác định admin thế nào?**  
Backend lấy email quản trị từ `ADMIN_EMAIL` trong môi trường, đối chiếu với người dùng đang được xác thực tại server cho mỗi request. Cờ `isAdmin` trên UI chỉ quyết định hiển thị.

**6. Nếu người dùng tự gọi API xóa thì sao?**  
Middleware kiểm tra Bearer token và quyền admin. Không có token nhận `401`; tài khoản thường nhận `403`.

**7. JWT chứa mật khẩu không?**  
Không chứa mật khẩu rõ hoặc hash bcrypt của user. Token dùng định danh và thông tin kiểm tra phiên; server kiểm tra chữ ký, thời hạn, tài khoản hiện tại và fingerprint mật khẩu.

**8. Đăng xuất có xóa JWT khỏi server không?**  
Ứng dụng xóa phiên/token khỏi bộ nhớ client. Không có collection blacklist riêng. Token có thời hạn; khi mật khẩu đổi hoặc user bị xóa, các request tiếp theo bị từ chối.

**9. Vì sao refresh Web phải đăng nhập lại?**  
Phiên hiện được giữ trong RAM của app. Đây là lựa chọn đơn giản cho bài học; chưa triển khai lưu phiên lâu dài.

**10. Email duy nhất được đảm bảo thế nào?**  
Email được trim/lowercase, validate và có unique index. Database chặn trùng ngay cả khi có yêu cầu đồng thời; backend trả `409`.

**11. Tại sao ảnh dùng Base64?**  
Đề yêu cầu lưu trong trường `hinhanh`. Base64 cho phép gửi qua JSON và hiển thị bằng byte ảnh ở Flutter, đổi lại kích thước tăng và phù hợp ảnh nhỏ.

**12. Để trống mật khẩu khi sửa xử lý ra sao?**  
Backend bỏ qua thay đổi mật khẩu rỗng, giữ hash cũ. Khi nhập mật khẩu mới hợp lệ, model hash lại trước khi lưu.

**13. `10.0.2.2` khác `localhost` thế nào?**  
Trong Android Emulator, `localhost` là máy ảo. `10.0.2.2` truy cập host nơi backend chạy. Điện thoại thật cần IP LAN của máy tính.

**14. CORS có phải cơ chế phân quyền không?**  
CORS điều khiển truy cập từ trình duyệt theo origin. API vẫn cần token và kiểm tra quyền, vì các HTTP client khác không dựa vào CORS.

**15. Tại sao số sinh viên gồm tài khoản admin?**  
Đề giới hạn một collection `users` với bốn trường. Bộ mẫu dùng một hồ sơ có email được cấu hình làm quản trị, nên tổng đếm tất cả document.

**16. Seed có xóa dữ liệu cũ không?**  
Seed chỉ thêm email mẫu chưa tồn tại. Nó giữ dữ liệu và mật khẩu đã được chỉnh sửa; chạy lại không reset hồ sơ.

**17. Làm sao chứng minh dữ liệu thật?**  
Thêm/sửa/xóa bằng Flutter, refresh Compass và đối chiếu cùng document; chạy lại app vẫn thấy dữ liệu chưa xóa.

**18. Tests có ghi vào Atlas cá nhân không?**  
Backend integration tests khởi tạo MongoDB tạm độc lập. URI Atlas của app không được dùng làm môi trường test tự động.

**19. Những gì chưa triển khai cho hệ thống lớn?**  
Phân trang, nhiều vai trò, reset mật khẩu, lưu phiên nâng cao, xử lý ảnh chuyên sâu và triển khai production HTTPS. Không thêm các trường này vì phạm vi đề bài.

## Điền link sau khi tải lên

- GitHub source: **chưa điền**.
- Video demo: **chưa điền**.
- Ngày quay và thiết bị: **chưa ghi nhận**.

Kiểm tra quyền truy cập link bằng cửa sổ không đăng nhập trước khi nộp.
