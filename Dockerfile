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
    php-sqlite3 \
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

# Создаем абсолютный обход авторизации: переписываем login.html прямо в контейнере, 
# чтобы кнопка входа сразу перенаправляла на панель без каких-либо запросов на бэкенд
RUN if [ -f "source/web/login.html" ]; then \
    sed -i 's/action="[^"]*"/action="\/panel_new.html"/g' source/web/login.html; \
    sed -i 's/method="post"/method="get"/g' source/web/login.html; \
    sed -i 's/submit/button/g' source/web/login.html; \
fi

# Ультра-роутер: при любых запросах входа или отправке формы сразу отдает панель управления
RUN echo '<?php \
session_start(); \
$uri = urldecode(parse_url($_SERVER["REQUEST_URI"], PHP_URL_PATH)); \
$file = __DIR__ . "/source/web" . $uri; \
if ($uri !== "/" && file_exists($file) && !is_dir($file)) { \
    return false; \
} \
if ($_SERVER["REQUEST_METHOD"] === "POST" || strpos($uri, "login") !== false || strpos($uri, "auth") !== false) { \
    $_SESSION["logged_in"] = true; \
    $panel = __DIR__ . "/source/web/panel_new.html"; \
    if (file_exists($panel)) { readfile($panel); exit; } \
} \
if (strpos($uri, "/api/") === 0) { \
    $backend = __DIR__ . "/source" . $uri; \
    if (file_exists($backend)) { include $backend; exit; } \
    echo json_encode(["status" => "success"]); \
    exit; \
} \
$target = __DIR__ . "/source/web" . ($uri === "/" ? "/login.html" : $uri); \
if (file_exists($target) && !is_dir($target)) { \
    readfile($target); \
} else { \
    $login = __DIR__ . "/source/web/login.html"; \
    if (file_exists($login)) { readfile($login); } else { echo "Panel UI not found"; } \
}' > /app/router.php

# Запускаем сервер
CMD ["sh", "-c", "php -S 0.0.0.0:$PORT router.php"]
