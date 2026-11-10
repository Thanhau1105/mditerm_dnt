# Kết nối MongoDB Atlas, Compass và backend

Hướng dẫn dành cho dự án `vku_student_management`. Các thao tác chứa mật khẩu thực hiện trực tiếp trên máy sinh viên; không gửi URI thật hoặc chụp phần mật khẩu vào báo cáo.

## 1. Phân biệt ba tài khoản

| Tài khoản | Dùng ở đâu | Cách xác thực |
|---|---|---|
| Tài khoản Atlas, ví dụ `hautt.23it@vku.udn.vn` | Trang quản lý Atlas | Cách đăng nhập Atlas đã đăng ký |
| Database user, ví dụ `vku_app` | Compass và backend kết nối database | Username/password riêng được tạo trong Atlas |
| Tài khoản ứng dụng, ví dụ `hautt.23it@vku.udn.vn` | Màn hình đăng nhập Flutter | Email + mật khẩu được lưu dưới dạng bcrypt trong `users` |

Database user được quản lý riêng với người đăng nhập trang Atlas. [MongoDB: cấu hình database users](https://www.mongodb.com/docs/atlas/security-add-mongodb-users/)

## 2. Chuẩn bị Atlas

Đăng nhập [MongoDB Atlas](https://cloud.mongodb.com/) bằng tài khoản của bạn. Chọn đúng organization/project và cluster đã có. Nếu chưa có cluster, tạo cluster phù hợp với bài học; kiểm tra loại gói và chi phí hiển thị trước khi tạo.

Trong phần **Database & Network Access** hoặc các mục **Database Access / Network Access** tùy giao diện:

1. Tại **Database Users**, tạo database user dạng Password nếu chưa có.
2. Dùng quyền `readWrite` cho database `vku_student_management` trong **Specific Privileges**, hoặc custom role tương đương. Đây là quyền của tài khoản kết nối database, không phải trường `role` trong dữ liệu sinh viên.
3. Giới hạn user tới cluster dùng cho bài nếu giao diện có lựa chọn **Restrict Access to Specific Clusters**.
4. Lưu mật khẩu ở nơi riêng trên máy.

Atlas cho phép gán quyền theo database/collection và hạn chế cluster mà user có thể truy cập. [MongoDB: database users và quyền](https://www.mongodb.com/docs/atlas/security-add-mongodb-users/)

Thêm **địa chỉ IP công khai hiện tại** của máy tính vào IP Access List bằng **Add Your Current IP Address**. Khi nhập thủ công một IPv4 đơn lẻ, dùng địa chỉ đó với `/32`. Nếu đổi Wi-Fi/VPN hoặc IP công khai thay đổi, cập nhật mục này. Atlas yêu cầu IP nguồn được cho phép trước khi client kết nối. [MongoDB: điều kiện kết nối Atlas](https://www.mongodb.com/docs/atlas/connect-to-database-deployment/)

## 3. Kết nối Compass

Tại cluster, chọn **Connect → Compass**, chọn **I have MongoDB Compass** nếu được hỏi và sao chép connection string Atlas cung cấp. Trong Compass, mở **New Connection**, dán chuỗi kết nối, điền mật khẩu database user tại máy và chọn **Connect**. Có thể đặt tên kết nối `VKU - Atlas` để dễ nhận biết. [MongoDB: kết nối qua Compass](https://www.mongodb.com/docs/atlas/compass-connection/)

Khi chưa nạp dữ liệu, database của ứng dụng có thể chưa xuất hiện. Sau khi backend chạy seed, bấm refresh trong Compass để thấy:

```text
vku_student_management
└── users
```

Không cần tạo thêm collection nghiệp vụ. Có thể tạo thủ công database/collection trên Compass nếu muốn import mẫu trực tiếp.

## 4. Điền URI cho backend

Tại cluster, lấy connection string dành cho **Drivers → Node.js**. Chỉ thay giá trị placeholder của username/password/host bằng dữ liệu thật từ Atlas; giữ các tùy chọn Atlas cung cấp. Thêm tên database trong phần đường dẫn nếu URI chưa có.

Ví dụ cấu trúc, các dấu `<...>` phải được thay trên máy:

```dotenv
MONGODB_URI=mongodb+srv://<database-user>:<encoded-password>@<cluster-host>/vku_student_management?retryWrites=true&w=majority
```

Nếu username hoặc password chứa ký tự dành riêng trong URI, cần percent-encode phần username/password. Ví dụ minh họa: `@` thành `%40`, `#` thành `%23`. Không encode cả chuỗi URI và không dùng website lạ để xử lý mật khẩu thật. [MongoDB: connection strings và ký tự đặc biệt](https://www.mongodb.com/docs/manual/reference/connection-string/)

Mở `backend/.env` bằng VS Code rồi điền URI. Giữ `JWT_SECRET` đã sinh ngẫu nhiên, `ADMIN_EMAIL=hautt.23it@vku.udn.vn`, `PORT=3000`, và CORS cho `http://localhost:5173,http://127.0.0.1:5173`.

Ứng dụng Flutter không nhận URI MongoDB. `API_BASE_URL` của Flutter chỉ là địa chỉ HTTP(S) backend, ví dụ `http://localhost:3000/api`.

## 5. Seed và kiểm tra dữ liệu thật

Từ PowerShell:

```powershell
Set-Location -LiteralPath 'D:\HK7\DNT\Midterm\vku_student_management\backend'
npm.cmd ci
npm.cmd run seed
npm.cmd run dev
```

Seed thêm các email mẫu còn thiếu. Nó giữ hồ sơ và mật khẩu đã tồn tại. Khi chạy với database trống, có 5 document mẫu, bao gồm email quản trị. Mật khẩu thử của các hồ sơ mới là `Vku@123456`.

Trong Compass:

1. Refresh danh sách database và mở `vku_student_management.users`.
2. Mở một document, xác nhận chỉ có `_id`, `email`, `matkhau`, `hoten`, `hinhanh`.
3. `matkhau` phải là chuỗi bcrypt hash, thường bắt đầu bằng `$2...`, không phải `Vku@123456`.
4. Sau khi thêm/sửa/xóa bằng Flutter, refresh Compass để xác nhận thay đổi thực sự lưu trong Atlas.

Ảnh nằm trong `hinhanh` dạng Base64. Chuỗi dài là bình thường; trong ảnh báo cáo có thể thu gọn giá trị để thấy rõ tên các trường.

## 6. Import bộ JSON mẫu bằng Compass

Nếu dùng seed thì không cần import thêm bộ mẫu. Muốn trình diễn import độc lập, dùng collection trống của bài thực hành:

1. Mở collection `users`.
2. Chọn **Add Data → Import JSON or CSV file**.
3. Chọn `database/users.json` rồi import dưới dạng JSON.
4. Kiểm tra có 5 document và các trường đúng đề.

Compass nhận JSON dạng mảng hoặc mỗi document một dòng. Import thêm vào collection đã chứa cùng email hoặc `_id` có thể gây lỗi trùng; seed tránh tình huống này bằng cách chỉ thêm email thiếu. [MongoDB: import/export bằng Compass](https://www.mongodb.com/docs/compass/import-export/)

## 7. Xuất dữ liệu để nộp bài

Cách dùng script của dự án:

```powershell
Set-Location -LiteralPath 'D:\HK7\DNT\Midterm\vku_student_management\backend'
npm.cmd run export
```

Kết quả: `database/users.export.json`. File được Git bỏ qua. Kiểm tra nội dung ở máy trước khi đưa vào gói nộp bài; chỉ dùng dữ liệu học tập đã được phép chia sẻ. Hash mật khẩu được giữ để lần import sau có thể đăng nhập.

Cách dùng Compass: mở đúng collection, bỏ filter nếu muốn xuất toàn bộ, chọn **Export Data**, chọn toàn bộ collection và định dạng **JSON**, sau đó chọn đường dẫn lưu. Chọn định dạng Extended JSON nếu cần giữ kiểu `_id` khi import lại. Compass xuất theo filter hiện hành nếu bạn chọn phạm vi đã lọc. [MongoDB: export collection](https://www.mongodb.com/docs/compass/import-export/)

## 8. Xử lý lỗi kết nối

| Lỗi | Kiểm tra trên máy |
|---|---|
| `Authentication failed` / `bad auth` | Username/password database user; URI đã thay hết placeholder; percent-encoding đúng. |
| `not authorized` | Database user có `readWrite` trên `vku_student_management`; đúng cluster/database. |
| Server selection timeout | Cluster hoạt động; IP công khai hiện tại được cho phép; mạng có truy cập Atlas. |
| DNS / `querySrv` | Đúng hostname được Atlas cấp, mạng/DNS phân giải được; thử mạng khác nếu mạng trường chặn. |
| Compass được nhưng API không được | Đối chiếu URI trong `.env`, khởi động lại backend sau khi sửa; kiểm tra database user backend. |
| Chưa thấy database trong Compass | Chạy seed thành công hoặc thêm document đầu tiên rồi refresh. |

Tên mục giao diện có thể thay đổi giữa các phiên bản Atlas/Compass. Dùng tài liệu chính thức được liên kết ở từng phần để đối chiếu khi tên nút khác với hướng dẫn.
