# 後端開發文件：ESUN Library Borrowing System

## 1. 專案簡介

本專案為線上圖書借閱系統後端，使用 **Spring Boot 3.5.14 + Java 17 + Maven + Supabase PostgreSQL** 實作。系統提供使用者註冊、登入驗證、JWT 授權、書籍查詢、借書與還書功能。

後端採用分層式架構，包含：

```text
Controller Layer  展示層 / REST API
Service Layer     業務邏輯層 / Transaction 控制
Repository Layer  資料存取層 / Stored Procedure 呼叫
Security Layer    JWT 驗證與 Spring Security 設定
Common Layer      共用回應與全域錯誤處理
```

本後端設計重點包含：

- 使用 Spring Boot 建立 RESTful API。
- 使用 Supabase PostgreSQL 作為關聯式資料庫。
- 使用 Stored Function / Stored Procedure 存取資料庫。
- 借書與還書流程使用 Transaction 避免資料錯亂。
- 使用 JWT 驗證登入狀態。
- 使用 BCrypt 儲存密碼雜湊，不保存明碼密碼。
- 使用 `JdbcTemplate` 參數綁定，降低 SQL Injection 風險。

---

## 2. 目前後端完成狀態

| 功能 | 狀態 | 說明 |
|---|---:|---|
| Spring Boot 專案建立 | 完成 | 使用 Maven、Java 17、Spring Boot 3.5.14 |
| Supabase PostgreSQL 連線 | 完成 | 已成功透過 HikariCP 建立 PostgreSQL 連線 |
| DB Schema | 完成 | 已建立使用者、書籍、庫存、借閱紀錄等資料表 |
| Stored Routine | 完成 | 使用 PostgreSQL Function / Procedure 存取資料 |
| 查詢書籍 API | 完成 | `GET /api/books` |
| 使用者註冊 API | 完成 | `POST /api/auth/register` |
| BCrypt 密碼雜湊 | 完成 | 密碼未明碼儲存 |
| 登入 API | 完成 | `POST /api/auth/login` |
| JWT Token | 完成 | 登入成功後回傳 JWT |
| 借書 API | 完成 | `POST /api/borrows/{inventoryId}` |
| 還書 API | 完成 | `POST /api/borrows/{inventoryId}/return` |
| JWT 保護借還書 | 完成 | 未帶 Token 呼叫借書 API 會被拒絕 |
| Transaction | 完成 | 借還書 Service 層使用 `@Transactional` |
| SQL Injection 防護 | 完成 | 使用 `JdbcTemplate` 參數綁定，不拼接 SQL |
| XSS 防護基礎 | 部分完成 | 後端有欄位驗證；完整 XSS 防護需搭配 Vue 前端避免 `v-html` |
| Vue 前端 | 尚未完成 | 下一階段實作 |

---

## 3. 專案技術棧

| 類別 | 技術 |
|---|---|
| Language | Java 17 |
| Framework | Spring Boot 3.5.14 |
| Build Tool | Maven |
| Database | Supabase PostgreSQL |
| DB Access | Spring JDBC / JdbcTemplate |
| Auth | Spring Security + JWT |
| Password Hashing | BCrypt |
| API Style | RESTful API |
| Transaction | Spring `@Transactional` |
| Environment Config | `.env` + `application.yml` |

---

## 4. 專案資料夾結構

```text
backend/
├── DB/
│   ├── 01_schema.sql
│   ├── 02_routines.sql
│   └── 03_seed.sql
│
├── src/main/java/com/esun/library/
│   ├── LibraryApplication.java
│   │
│   ├── common/
│   │   └── GlobalExceptionHandler.java
│   │
│   ├── config/
│   │   └── SecurityConfig.java
│   │
│   ├── controller/
│   │   ├── AuthController.java
│   │   ├── BookController.java
│   │   └── BorrowController.java
│   │
│   ├── dto/
│   │   ├── ApiResponse.java
│   │   ├── BookResponse.java
│   │   ├── LoginRequest.java
│   │   ├── LoginResponse.java
│   │   └── RegisterRequest.java
│   │
│   ├── entity/
│   │   └── AppUser.java
│   │
│   ├── repository/
│   │   ├── BookRepository.java
│   │   ├── BorrowRepository.java
│   │   └── UserRepository.java
│   │
│   ├── security/
│   │   ├── JwtAuthenticationFilter.java
│   │   └── JwtUtil.java
│   │
│   └── service/
│       ├── AuthService.java
│       ├── BookService.java
│       └── BorrowService.java
│
├── src/main/resources/
│   └── application.yml
│
├── .env
├── .env.example
├── pom.xml
├── mvnw
└── mvnw.cmd
```

---

## 5. 各檔案功能說明

### 5.1 啟動主程式

| 檔案 | 說明 |
|---|---|
| `LibraryApplication.java` | Spring Boot 專案進入點 |

---

### 5.2 Controller Layer

| 檔案 | API | 功能 |
|---|---|---|
| `BookController.java` | `GET /api/books` | 查詢所有書籍與庫存狀態 |
| `AuthController.java` | `POST /api/auth/register` | 使用手機號碼註冊 |
| `AuthController.java` | `POST /api/auth/login` | 使用手機號碼與密碼登入 |
| `BorrowController.java` | `POST /api/borrows/{inventoryId}` | 借閱指定庫存書籍 |
| `BorrowController.java` | `POST /api/borrows/{inventoryId}/return` | 歸還指定庫存書籍 |

---

### 5.3 Service Layer

| 檔案 | 功能 |
|---|---|
| `BookService.java` | 處理書籍查詢邏輯 |
| `AuthService.java` | 處理註冊、登入、密碼比對、JWT 產生 |
| `BorrowService.java` | 處理借書、還書邏輯，並使用 `@Transactional` 控制交易 |

`BorrowService.java` 的 `@Transactional` 是借還書功能的重點。借書與還書都會同時異動 `inventory` 與 `borrowing_record`，因此必須確保兩張表的異動同時成功或同時失敗。

---

### 5.4 Repository Layer

| 檔案 | 存取方式 |
|---|---|
| `BookRepository.java` | 呼叫 `SELECT * FROM fn_list_books()` |
| `UserRepository.java` | 呼叫 `fn_find_user_by_phone()`、`sp_register_user()`、`sp_update_last_login()` |
| `BorrowRepository.java` | 呼叫 `sp_borrow_book()`、`sp_return_book()` |

Repository 層使用 `JdbcTemplate` 搭配參數綁定，例如：

```java
jdbcTemplate.update(
    "CALL sp_borrow_book(?, ?)",
    userId,
    inventoryId
);
```

此做法避免直接拼接 SQL 字串，可降低 SQL Injection 風險。

---

### 5.5 Security Layer

| 檔案 | 功能 |
|---|---|
| `SecurityConfig.java` | 設定哪些 API 公開，哪些 API 需要 JWT |
| `JwtUtil.java` | 產生與解析 JWT Token |
| `JwtAuthenticationFilter.java` | 從 `Authorization: Bearer token` 解析登入者身份 |

目前公開 API：

```text
GET  /api/books
POST /api/auth/register
POST /api/auth/login
```

其餘 API 需要 JWT，例如：

```text
POST /api/borrows/{inventoryId}
POST /api/borrows/{inventoryId}/return
```

---

### 5.6 DTO

| 檔案 | 說明 |
|---|---|
| `BookResponse.java` | 書籍列表回傳格式 |
| `RegisterRequest.java` | 註冊請求格式 |
| `LoginRequest.java` | 登入請求格式 |
| `LoginResponse.java` | 登入成功後回傳 JWT |
| `ApiResponse.java` | 一般成功 / 失敗訊息格式 |

---

### 5.7 Common Layer

| 檔案 | 說明 |
|---|---|
| `GlobalExceptionHandler.java` | 統一處理驗證錯誤、業務錯誤、資料庫錯誤與系統錯誤 |

---

## 6. 資料庫設計

目前專案資料庫檔案放置於：

```text
backend/DB/
```

| 檔案 | 說明 |
|---|---|
| `01_schema.sql` | 建立資料表、PK、FK、Index、Constraint |
| `02_routines.sql` | 建立 Stored Function / Stored Procedure |
| `03_seed.sql` | 建立測試資料 |

---

## 7. 資料表

### 7.1 `app_user`

使用者資料表。

| 欄位 | 說明 |
|---|---|
| `user_id` | 使用者 ID |
| `phone_number` | 手機號碼，作為登入帳號 |
| `password_hash` | BCrypt 雜湊後密碼 |
| `user_name` | 使用者名稱 |
| `registration_time` | 註冊時間 |
| `last_login_time` | 最後登入時間 |

---

### 7.2 `book`

書籍主檔。

| 欄位 | 說明 |
|---|---|
| `isbn` | ISBN |
| `name` | 書名 |
| `author` | 作者 |
| `introduction` | 書籍簡介 |

---

### 7.3 `inventory_status`

庫存狀態代碼表。

| 狀態 | 說明 |
|---|---|
| `AVAILABLE` | 在庫 / 可借閱 |
| `BORROWED` | 出借中 |
| `PROCESSING` | 整理中 |
| `LOST` | 遺失 |
| `DAMAGED` | 損毀 |
| `DISCARDED` | 廢棄 |

---

### 7.4 `inventory`

實體庫存資料表。  
同一本書可有多筆庫存，例如同一本 Clean Code 可以有 `inventory_id = 1` 與 `inventory_id = 2`。

| 欄位 | 說明 |
|---|---|
| `inventory_id` | 庫存 ID |
| `isbn` | 對應 `book.isbn` |
| `store_time` | 入庫時間 |
| `status_code` | 庫存狀態 |

---

### 7.5 `borrowing_record`

借閱紀錄表。

| 欄位 | 說明 |
|---|---|
| `record_id` | 借閱紀錄 ID |
| `user_id` | 借閱者 |
| `inventory_id` | 被借閱的實體庫存 |
| `borrowing_time` | 借出時間 |
| `return_time` | 歸還時間，`NULL` 代表尚未歸還 |

---

## 8. Stored Routine

| Routine | 類型 | 功能 |
|---|---|---|
| `fn_list_books()` | Function | 查詢書籍與庫存列表 |
| `fn_find_user_by_phone(phone)` | Function | 依手機號碼查詢使用者 |
| `sp_register_user(phone, passwordHash, userName)` | Procedure | 註冊使用者 |
| `sp_update_last_login(userId)` | Procedure | 更新最後登入時間 |
| `sp_borrow_book(userId, inventoryId)` | Procedure | 借書 |
| `sp_return_book(userId, inventoryId)` | Procedure | 還書 |

---

## 9. API 文件

### 9.1 查詢書籍列表

```http
GET /api/books
```

公開 API，不需登入。

成功回傳範例：

```json
[
  {
    "inventoryId": 1,
    "isbn": "9789865020011",
    "name": "Clean Code",
    "author": "Robert C. Martin",
    "introduction": "A handbook of agile software craftsmanship.",
    "status": "AVAILABLE"
  }
]
```

---

### 9.2 註冊

```http
POST /api/auth/register
Content-Type: application/json
```

Request：

```json
{
  "phoneNumber": "0912345679",
  "password": "password123",
  "userName": "Jimmy"
}
```

Response：

```json
{
  "success": true,
  "message": "註冊成功"
}
```

驗證規則：

| 欄位 | 規則 |
|---|---|
| `phoneNumber` | 不可空白，格式需為台灣手機格式 `09xxxxxxxx` |
| `password` | 不可空白，至少 8 碼 |
| `userName` | 不可空白 |

---

### 9.3 登入

```http
POST /api/auth/login
Content-Type: application/json
```

Request：

```json
{
  "phoneNumber": "0912345679",
  "password": "password123"
}
```

Response：

```json
{
  "token": "eyJhbGciOiJIUzM4NCJ9...",
  "tokenType": "Bearer",
  "userName": "Jimmy"
}
```

---

### 9.4 借書

```http
POST /api/borrows/{inventoryId}
Authorization: Bearer <JWT_TOKEN>
```

範例：

```http
POST /api/borrows/1
Authorization: Bearer eyJhbGciOiJIUzM4NCJ9...
```

成功回傳：

```json
{
  "success": true,
  "message": "借閱成功"
}
```

借書成功後：

```text
inventory.status_code = BORROWED
borrowing_record 新增一筆 return_time = NULL 的借閱紀錄
```

---

### 9.5 還書

```http
POST /api/borrows/{inventoryId}/return
Authorization: Bearer <JWT_TOKEN>
```

範例：

```http
POST /api/borrows/1/return
Authorization: Bearer eyJhbGciOiJIUzM4NCJ9...
```

成功回傳：

```json
{
  "success": true,
  "message": "還書成功"
}
```

還書成功後：

```text
inventory.status_code = AVAILABLE
borrowing_record.return_time 更新為歸還時間
```

---

## 10. 環境變數設定

本專案使用 `.env` 管理敏感資訊。`.env` 不應提交到 GitHub。

### 10.1 `.env`

```properties
DB_URL=jdbc:postgresql://db.<your-project-id>.supabase.co:5432/postgres?sslmode=require
DB_USERNAME=postgres
DB_PASSWORD=your_database_password

JWT_SECRET=your-jwt-secret-at-least-32-characters
JWT_EXPIRATION_MS=86400000
```

---

### 10.2 `application.yml`

```yml
server:
  port: 8080

spring:
  config:
    import: optional:file:.env[.properties]

  application:
    name: esun-library-system

  datasource:
    url: ${DB_URL}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    driver-class-name: org.postgresql.Driver

  jackson:
    time-zone: Asia/Taipei

app:
  jwt:
    secret: ${JWT_SECRET}
    expiration-ms: ${JWT_EXPIRATION_MS}

logging:
  level:
    org.springframework.jdbc.core: INFO
```

---

### 10.3 `.gitignore`

需包含：

```gitignore
.env
target/
```

---

## 11. 如何啟動後端

進入後端資料夾：

```powershell
cd D:\test\esun-library-system\backend
```

啟動：

```powershell
.\mvnw.cmd spring-boot:run
```

成功啟動時，log 會出現類似：

```text
HikariPool-1 - Added connection org.postgresql.jdbc.PgConnection
HikariPool-1 - Start completed.
Tomcat started on port 8080 (http)
Started LibraryApplication
```

本次測試中，後端已成功使用 Java 17.0.18 啟動，HikariCP 成功加入 PostgreSQL connection，Tomcat 也成功於 8080 port 啟動。

---

## 12. 測試紀錄

### 12.1 書籍查詢 API 測試

測試指令：

```powershell
Invoke-RestMethod `
  -Uri "http://localhost:8080/api/books" `
  -Method GET
```

測試結果：

```text
inventoryId  : 1
isbn         : 9789865020011
name         : Clean Code
author       : Robert C. Martin
status       : AVAILABLE
```

結論：

```text
GET /api/books 可成功從 Supabase PostgreSQL 取得書籍與庫存資料。
```

---

### 12.2 註冊 API 測試

測試指令：

```powershell
Invoke-RestMethod `
  -Uri "http://localhost:8080/api/auth/register" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"phoneNumber":"0912345679","password":"password123","userName":"Jimmy"}'
```

測試結果：

```text
success = True
message = 註冊成功
```

Supabase 查詢結果：

```json
[
  {
    "user_id": 2,
    "phone_number": "0912345679",
    "password_hash": "$2a$10$5WU2.EUKMs5qJEhJyAJcNe16MhTS2VQB0SyVKOV5Y19ktsKbB7t8a",
    "user_name": "Jimmy",
    "registration_time": "2026-04-29 21:48:02.586691+00"
  }
]
```

結論：

```text
使用者註冊成功，密碼已經以 BCrypt 方式儲存，未儲存明碼。
```

---

### 12.3 登入 API 測試

測試指令：

```powershell
Invoke-RestMethod `
  -Uri "http://localhost:8080/api/auth/login" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"phoneNumber":"0912345679","password":"password123"}'
```

測試結果：

```text
token = eyJhbGciOiJIUzM4NCJ9...
```

Supabase 查詢結果：

```json
[
  {
    "user_id": 2,
    "phone_number": "0912345679",
    "user_name": "Jimmy",
    "last_login_time": "2026-04-29 22:00:33.111485+00"
  }
]
```

結論：

```text
登入成功後，後端正確回傳 JWT token，並更新 last_login_time。
```

---

### 12.4 借書 API 測試

先登入取得 token：

```powershell
$login = Invoke-RestMethod `
  -Uri "http://localhost:8080/api/auth/login" `
  -Method POST `
  -ContentType "application/json" `
  -Body '{"phoneNumber":"0912345679","password":"password123"}'

$token = $login.token
```

借書：

```powershell
Invoke-RestMethod `
  -Uri "http://localhost:8080/api/borrows/1" `
  -Method POST `
  -Headers @{ Authorization = "Bearer $token" }
```

測試結果：

```text
success = True
message = 借閱成功
```

查詢書籍狀態：

```text
inventoryId  : 1
name         : Clean Code
status       : BORROWED
```

結論：

```text
借書成功後，inventory_id = 1 的 status_code 已由 AVAILABLE 變為 BORROWED。
```

---

### 12.5 還書 API 測試

測試指令：

```powershell
Invoke-RestMethod `
  -Uri "http://localhost:8080/api/borrows/1/return" `
  -Method POST `
  -Headers @{ Authorization = "Bearer $token" }
```

測試結果：

```text
success = True
message = 還書成功
```

Supabase 查詢結果：

```json
[
  {
    "record_id": 2,
    "user_id": 2,
    "inventory_id": 1,
    "borrowing_time": "2026-04-29 22:09:54.467052+00",
    "return_time": "2026-04-29 22:11:37.7624+00"
  },
  {
    "record_id": 1,
    "user_id": 1,
    "inventory_id": 1,
    "borrowing_time": "2026-04-29 20:32:31.206785+00",
    "return_time": "2026-04-29 20:32:56.956421+00"
  }
]
```

查詢庫存狀態：

```json
[
  {
    "inventory_id": 1,
    "isbn": "9789865020011",
    "store_time": "2026-04-29 20:27:05.115645+00",
    "status_code": "AVAILABLE"
  }
]
```

結論：

```text
還書成功後，borrowing_record.return_time 正確更新，inventory.status_code 正確回到 AVAILABLE。
```

---

### 12.6 JWT 保護測試

不帶 JWT 呼叫借書 API：

```powershell
Invoke-RestMethod `
  -Uri "http://localhost:8080/api/borrows/2" `
  -Method POST
```

測試結果：

```text
Invoke-RestMethod : 遠端伺服器傳回一個錯誤: (403) 禁止。
```

結論：

```text
未登入或未帶 JWT Token 時，無法呼叫借書 API，符合登入驗證要求。
```

---

## 13. 安全性設計

### 13.1 密碼安全

使用 Spring Security 的 `BCryptPasswordEncoder` 處理密碼：

```java
String passwordHash = passwordEncoder.encode(request.getPassword());
```

資料庫只儲存：

```text
password_hash
```

不儲存明碼密碼。

---

### 13.2 JWT 身分驗證

登入成功後回傳 JWT。借書與還書 API 不接受前端傳入 `userId`，而是從 JWT 中解析目前登入者身份：

```java
Long userId = (Long) authentication.getPrincipal();
```

此設計可避免使用者偽造他人 `userId` 借還書。

---

### 13.3 SQL Injection 防護

所有資料庫操作透過 `JdbcTemplate` 的參數綁定：

```java
jdbcTemplate.update(
    "CALL sp_return_book(?, ?)",
    userId,
    inventoryId
);
```

不使用字串拼接 SQL。

---

### 13.4 XSS 防護

目前後端已使用 DTO validation 檢查輸入格式。完整 XSS 防護會在 Vue 前端補強，原則如下：

```text
1. 使用 {{ value }} 顯示資料
2. 避免使用 v-html 顯示使用者可控內容
3. 必要時後端限制欄位長度與格式
```

---

## 14. Transaction 設計

借書與還書都會同時異動多張表。

### 借書流程

```text
1. 檢查 inventory 狀態是否 AVAILABLE
2. 將 inventory.status_code 更新為 BORROWED
3. 新增 borrowing_record
```

### 還書流程

```text
1. 檢查 inventory 狀態是否 BORROWED
2. 查詢該使用者尚未歸還的 borrowing_record
3. 將 inventory.status_code 更新為 AVAILABLE
4. 更新 borrowing_record.return_time
```

Service 層使用：

```java
@Transactional
public void borrowBook(Long userId, Long inventoryId) {
    borrowRepository.borrowBook(userId, inventoryId);
}
```

```java
@Transactional
public void returnBook(Long userId, Long inventoryId) {
    borrowRepository.returnBook(userId, inventoryId);
}
```

若任一步驟失敗，交易會 rollback，避免庫存狀態與借閱紀錄不一致。

---

## 15. 已知注意事項

### 15.1 後端核心功能已完成

目前後端已具備可運作的核心功能：

```text
查詢書籍
註冊
登入
JWT
借書
還書
Transaction
Stored Procedure
DB 連線
```

### 15.2 待未完成項目

```text
Vue 前端頁面
README 總文件
API 測試工具截圖或 Postman Collection
正式錯誤碼設計
單元測試 / 整合測試
部署設定
```

### 15.3 PowerShell 中文亂碼

PowerShell 測試時曾出現：

```text
å±æ
é
```

這是 PowerShell 中文顯示編碼問題，不影響 API 功能。實際後端回傳內容為：

```text
借閱成功
還書成功
註冊成功
```

---

## 16. 後端完成度總結

目前後端可以視為：

```text
Backend MVP：完成
Frontend：尚未完成
Full-stack Assignment：進入前端階段
```

後端已滿足大部分核心後端要求，包含 Spring Boot、RESTful API、註冊、登入驗證、借還書、Stored Procedure、Transaction、密碼雜湊、JWT 驗證與三層式架構。接下來只要完成 Vue 前端與最終 README，就可以形成完整的全端作品。
