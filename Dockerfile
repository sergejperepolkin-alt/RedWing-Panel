FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Устанавливаем системные зависимости, Java, PHP и модули
RUN apt-get update && apt-get install -y \
    default-jre \
    php \
    php-cli \
    php-mbstring \
    php-xml \
    php-zip \
    php-mysql \
    php-curl \
    wget \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем apktool
RUN wget https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O /usr/local/bin/apktool
RUN wget https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar -O /usr/local/bin/apktool.jar
RUN chmod +x /usr/local/bin/apktool /usr/local/bin/apktool.jar

WORKDIR /app

# Копируем весь репозиторий
COPY . .

# Создаем файл theme.js
RUN mkdir -p source/web && cat << 'EOF' > source/web/theme.js
/* RedWing Panel — Theme Engine */
(function () {
    'use strict';
    var STORAGE_KEY = 'rw_theme';
    var DEFAULTS = { accent: 'red', fontSize: 'default', sidebarWidth: 'default', contrast: 'normal' };
    function applyTheme() { document.documentElement.setAttribute('data-theme', 'dark'); }
    applyTheme();
    window.RWTheme = { apply: applyTheme };
})();
EOF

# Создаем надежный роутер с поддержкой сессий для сохранения авторизации
RUN echo '<?php \
session_start(); \
$uri = urldecode(parse_url($_SERVER["REQUEST_URI"], PHP_URL_PATH)); \
$file = __DIR__ . "/source/web" . $uri; \
if ($uri !== "/" && file_exists($file) && !is_dir($file)) { \
    return false; \
} \
if ($_SERVER["REQUEST_METHOD"] === "POST" && (strpos($uri, "login") !== false || strpos($uri, "auth") !== false)) { \
    $_SESSION["logged_in"] = true; \
    header("Content-Type: application/json"); \
    echo json_encode(["status" => "success", "success" => true, "message" => "OK", "redirect" => "panel_new.html"]); \
    exit; \
} \
if (strpos($uri, "/api/") === 0) { \
    $backend = __DIR__ . "/source" . $uri; \
    if (file_exists($backend)) { include $backend; exit; } \
    echo json_encode(["status" => "success"]); \
    exit; \
} \
if ($uri === "/login.html" && isset($_SESSION["logged_in"]) && $_SESSION["logged_in"] === true) { \
    header("Location: /panel_new.html"); \
    exit; \
} \
$targetFile = __DIR__ . "/source/web" . ($uri === "/" ? "/login.html" : $uri); \
if (file_exists($targetFile) && !is_dir($targetFile)) { \
    readfile($targetFile); \
} else { \
    $login = __DIR__ . "/source/web/login.html"; \
    if (file_exists($login)) { readfile($login); } else { echo "Panel UI not found"; } \
}' > /app/router.php

# Запускаем сервер
CMD ["sh", "-c", "php -S 0.0.0.0:$PORT router.php"]
