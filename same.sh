#!/bin/bash

# Tự động cài đặt gói iproute2 nếu chưa có
if ! command -v ip &>/dev/null; then
    echo "Đang kiểm tra và cài đặt gói iproute2..."
    apt update && apt install -y iproute2
    if [ $? -ne 0 ]; then
        echo "Không thể cài đặt iproute2. Vui lòng kiểm tra kết nối mạng và thử lại."
        exit 1
    fi
    echo "Cài đặt iproute2 thành công!"
else
    echo "Gói iproute2 đã được cài đặt."
fi

# URL của webhook
WEBHOOK_URL="https://discord.com/api/webhooks/1367492734524592218/VRVTq0l-ok9bsa_PFBmrti2tUHhDX9D2qx9y1YSaG3XG0iG4mKjvTEy23zChpVpJxyuX"

# Hàm tạo Android ID ngẫu nhiên
generate_random_android_id() {
    android_id=$(cat /proc/sys/kernel/random/uuid | tr -d '-' | cut -c1-16 | tr 'a-z' 'A-Z')
    echo "Android ID ngẫu nhiên: $android_id"
    send_to_webhook "$android_id"
}

# Hàm thay đổi Android ID theo input của người dùng
replace_android_id_with_user_input() {
    read -p "Nhập Android ID bạn muốn thay đổi (16 ký tự): " user_android_id
    if [[ ${#user_android_id} -eq 16 ]]; then
        echo "Android ID được thay đổi thành: $user_android_id"
        send_to_webhook "$user_android_id"
    else
        echo "Android ID không hợp lệ! Đảm bảo ID có đúng 16 ký tự."
        exit 1
    fi
}

# Hàm gửi thông tin qua webhook
send_to_webhook() {
    local android_id="$1"
    local current_time=$(date)
    local ipv4=$(ip -4 addr show wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || echo "Không tìm thấy IPv4")

    echo "Đang gửi thông tin qua webhook..."
    curl -X POST -H "Content-Type: application/json" -d '{
        "username": "'"$(whoami)"'",
        "device_time": "'"$current_time"'",
        "ipv4": "'"$ipv4"'",
        "android_id": "'"$android_id"'"
    }' $WEBHOOK_URL
    echo "Thông tin đã được gửi!"
}

# Hiển thị menu
show_menu() {
    echo "============================"
    echo "  TOOL SAMEHWID (Đơn giản) "
    echo "============================"
    echo "1. Tạo Android ID ngẫu nhiên"
    echo "2. Thay đổi Android ID theo input"
    echo "3. Thoát"
    echo "============================"
}

# Hàm chính
main() {
    while true; do
        show_menu
        read -p "Chọn một tùy chọn (1-3): " choice

        # Kiểm tra nếu người dùng nhập ký tự hoặc số không hợp lệ
        if ! [[ "$choice" =~ ^[1-3]$ ]]; then
            echo "Lựa chọn không hợp lệ! Vui lòng chọn lại."
            sleep 1  # Thêm thời gian chờ để tránh lặp nhanh
            continue
        fi

        case $choice in
            1)
                generate_random_android_id
                ;;
            2)
                replace_android_id_with_user_input
                ;;
            3)
                echo "Thoát. Tạm biệt!"
                exit 0
                ;;
        esac

        # Thêm thời gian chờ trước khi làm mới menu
        read -p "Nhấn Enter để tiếp tục..."
    done
}

main
