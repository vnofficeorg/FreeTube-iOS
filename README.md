# FreeTube iOS 🎬

App xem YouTube không quảng cáo cho iPad Air 1 (iOS 12.5.7)

## Tính năng

- ✅ **Không quảng cáo** — Sử dụng Invidious API
- ✅ **Vuốt lên xem video liên quan** — Cả khi đang xem fullscreen
- ✅ **Tìm kiếm** — Tìm video theo từ khóa
- ✅ **Trending** — Video thịnh hành
- ✅ **Lịch sử xem** — Lưu local trên máy
- ✅ **Đổi instance** — Chuyển server khi bị chặn
- ✅ **Hỗ trợ mọi hướng xoay** — Landscape & Portrait

## Yêu cầu

- iPad Air 1 hoặc thiết bị iOS 12.0+
- Máy tính có **Sideloadly** để cài app

## Cách cài đặt

### 1. Download IPA
- Vào tab **Actions** trên GitHub
- Chọn build mới nhất
- Download artifact **FreeTube-IPA**

### 2. Cài lên iPad
1. Tải [Sideloadly](https://sideloadly.io/) trên máy tính
2. Kết nối iPad qua cáp USB
3. Mở Sideloadly → kéo file `.ipa` vào
4. Nhập Apple ID → nhấn Start
5. Trên iPad: **Cài đặt → Cài đặt chung → Quản lý thiết bị** → Trust Apple ID

### 3. Mở app và xem!

## Cách sử dụng

### Vuốt xem video liên quan
Khi đang xem video (kể cả fullscreen):
1. **Vuốt từ dưới lên** → Panel video liên quan hiện ra
2. **Tap vào video** → Chuyển sang video mới
3. **Vuốt xuống** hoặc **tap ngoài panel** → Đóng panel

### Đổi Instance
Nếu video không load được:
1. Vào tab **Cài đặt**
2. Chọn instance khác
3. Thử lại

## Build từ source

```bash
# Clone repo
git clone https://github.com/YOUR_USERNAME/FreeTube-iOS.git

# Build (cần macOS + Xcode)
xcodebuild -project FreeTube.xcodeproj \
  -scheme FreeTube \
  -sdk iphoneos \
  -configuration Release \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

## Lưu ý

- ⚠️ App cần cài lại mỗi **7 ngày** (do dùng Apple ID miễn phí)
- ⚠️ Dùng AltStore có thể tự động refresh nếu máy tính cùng WiFi
- 📱 Tối ưu cho iPad Air 1 — chọn 720p/480p để mượt nhất

## License
MIT
