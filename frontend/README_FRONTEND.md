# 前端操作手冊與功能說明：ESUN Library Borrowing System

## 1. 文件目的

本文件說明 **ESUN Library Borrowing System 前端系統** 的使用方式、功能範圍、程式碼位置、與後端 API 串接方式，並整理目前前端已滿足的實作需求。

本前端使用 **Vue 3 + Vite + Vue Router + Axios** 實作，主要負責提供使用者操作介面，讓使用者能夠完成：

- 查看書籍列表
- 註冊帳號
- 登入帳號
- 儲存 JWT Token
- 借閱書籍
- 歸還書籍
- 登出帳號
- 根據登入狀態限制借還書操作

---

## 2. 前端目前完成狀態

| 功能項目 | 狀態 | 說明 |
|---|---:|---|
| Vue 3 前端專案建立 | 完成 | 使用 Vite 建立前端專案 |
| Vue Router | 完成 | 已建立 `/books`、`/login`、`/register` 頁面路由 |
| Axios API 串接 | 完成 | 使用共用 `http.js` 呼叫 Spring Boot 後端 |
| 書籍列表顯示 | 完成 | 成功呼叫 `GET /api/books` 並顯示資料 |
| 註冊頁面 | 完成 | 成功呼叫 `POST /api/auth/register` |
| 登入頁面 | 完成 | 成功呼叫 `POST /api/auth/login` |
| JWT 儲存 | 完成 | 登入後將 token 存入 `localStorage` |
| 自動帶入 Authorization Header | 完成 | Axios interceptor 自動帶入 `Bearer token` |
| 借閱書籍 | 完成 | 登入後可呼叫 `POST /api/borrows/{inventoryId}` |
| 歸還書籍 | 完成 | 登入後可呼叫 `POST /api/borrows/{inventoryId}/return` |
| 登出功能 | 完成 | 清除 `localStorage` 中的 token 與 userName |
| 未登入限制 | 完成 | 未登入時點擊借閱 / 還書會導向登入頁 |
| 狀態即時更新 | 完成 | 借書 / 還書後自動重新載入書籍列表 |
| CORS 串接 | 完成 | 後端已允許 Vue 前端跨來源呼叫 API |
| XSS 基礎防護 | 完成 | 前端使用 Vue 插值語法 `{{ }}` 顯示資料，避免直接使用 `v-html` |

---

## 3. 前端技術棧

| 類別 | 技術 |
|---|---|
| Framework | Vue 3 |
| Build Tool | Vite |
| Router | Vue Router |
| HTTP Client | Axios |
| State Storage | localStorage |
| Styling | CSS |
| Formatting | Prettier |
| Linting | ESLint |
| API Server | Spring Boot Backend |
| Backend URL | `http://localhost:8080/api` |

---

## 4. 前端專案結構

```text
frontend/
├── public/
│   └── favicon.ico
│
├── src/
│   ├── api/
│   │   └── http.js
│   │
│   ├── router/
│   │   └── index.js
│   │
│   ├── views/
│   │   ├── BookListView.vue
│   │   ├── LoginView.vue
│   │   └── RegisterView.vue
│   │
│   ├── App.vue
│   ├── main.js
│   └── style.css
│
├── .env
├── .env.example
├── .gitignore
├── package.json
├── package-lock.json
├── vite.config.js
└── README.md
```

---

## 5. 重要前端檔案說明

### 5.1 `src/main.js`

前端程式進入點，負責建立 Vue App，掛載 Router，並載入全域 CSS。

```js
import './style.css'

import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

createApp(App).use(router).mount('#app')
```

功能：

- 掛載 `App.vue`
- 使用 Vue Router
- 載入全域樣式

---

### 5.2 `src/App.vue`

整個前端系統的主版面，包含：

- 導覽列
- 書籍列表連結
- 登入連結
- 註冊連結
- 登入後顯示使用者名稱
- 登出按鈕
- `<RouterView />` 顯示目前路由頁面

目前邏輯：

```text
如果 localStorage 裡沒有 token：
顯示「登入」、「註冊」

如果 localStorage 裡有 token：
顯示「您好，使用者名稱」、「登出」
```

主要功能：

- 管理導覽列登入狀態
- 監聽 `auth-changed` 事件
- 登入 / 登出後同步畫面狀態
- 透過 `<RouterView />` 顯示不同頁面

---

### 5.3 `src/router/index.js`

前端路由設定檔。

目前路由：

| Path | Component | 功能 |
|---|---|---|
| `/` | redirect to `/books` | 預設導向書籍列表 |
| `/books` | `BookListView.vue` | 書籍列表頁 |
| `/login` | `LoginView.vue` | 登入頁 |
| `/register` | `RegisterView.vue` | 註冊頁 |

---

### 5.4 `src/api/http.js`

Axios 共用設定檔。

功能：

- 設定後端 API Base URL
- 統一處理 HTTP request
- 自動從 `localStorage` 讀取 JWT token
- 自動加上 `Authorization: Bearer <token>`

範例：

```js
const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 10000,
})

http.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')

  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }

  return config
})
```

這個設計讓前端在呼叫借書、還書 API 時，不需要每次手動加 token。

---

### 5.5 `src/views/BookListView.vue`

書籍列表頁，也是目前前端最核心的頁面。

功能包含：

- 讀取書籍列表
- 顯示書名、作者、ISBN、庫存編號、簡介、狀態
- 顯示 `AVAILABLE` / `BORROWED` 狀態標籤
- 登入後可借書
- 登入後可還書
- 未登入時點擊借閱 / 還書會導向登入頁
- 借還書成功後自動重新載入書籍資料

主要 API：

| 操作 | API |
|---|---|
| 載入書籍 | `GET /api/books` |
| 借閱書籍 | `POST /api/borrows/{inventoryId}` |
| 歸還書籍 | `POST /api/borrows/{inventoryId}/return` |

借書流程：

```text
使用者點擊「借閱」
→ 檢查 localStorage 是否有 token
→ 若沒有 token，導向 /login
→ 若有 token，呼叫 POST /api/borrows/{inventoryId}
→ 後端驗證 JWT
→ 借書成功
→ 重新載入書籍列表
```

還書流程：

```text
使用者點擊「還書」
→ 檢查 localStorage 是否有 token
→ 呼叫 POST /api/borrows/{inventoryId}/return
→ 後端驗證 JWT
→ 還書成功
→ 重新載入書籍列表
```

---

### 5.6 `src/views/RegisterView.vue`

註冊頁面。

使用者輸入：

- 使用者名稱
- 手機號碼
- 密碼

送出後呼叫：

```http
POST /api/auth/register
```

Request Body：

```json
{
  "userName": "Test User",
  "phoneNumber": "0912345680",
  "password": "password123"
}
```

成功後：

```text
顯示「註冊成功，正在前往登入頁」
約 0.8 秒後自動導向 /login
```

錯誤處理：

- 欄位未填：顯示「請完整填寫註冊資料」
- 手機格式錯誤：顯示後端回傳錯誤
- 手機已註冊：顯示後端回傳錯誤
- 其他錯誤：顯示「註冊失敗」

---

### 5.7 `src/views/LoginView.vue`

登入頁面。

使用者輸入：

- 手機號碼
- 密碼

送出後呼叫：

```http
POST /api/auth/login
```

Request Body：

```json
{
  "phoneNumber": "0912345679",
  "password": "password123"
}
```

成功後後端回傳：

```json
{
  "token": "eyJhbGciOiJIUzM4NCJ9...",
  "tokenType": "Bearer",
  "userName": "Jimmy"
}
```

前端會儲存：

```js
localStorage.setItem('token', response.data.token)
localStorage.setItem('userName', response.data.userName)
```

並觸發：

```js
window.dispatchEvent(new Event('auth-changed'))
```

讓 `App.vue` 的 Navbar 即時更新登入狀態。

成功後：

```text
顯示「登入成功」
約 0.5 秒後導向 /books
```

---

## 6. 前端環境變數設定

### 6.1 `.env`

位置：

```text
frontend/.env
```

內容：

```properties
VITE_API_BASE_URL=http://localhost:8080/api
```

用途：

```text
讓 Axios 知道後端 API 的基礎網址。
```

---

### 6.2 `.env.example`

位置：

```text
frontend/.env.example
```

內容：

```properties
VITE_API_BASE_URL=http://localhost:8080/api
```

此檔案可以提交到 GitHub，讓其他開發者知道要建立哪些環境變數。

---

## 7. 前端啟動方式

### 7.1 安裝套件

```powershell
cd D:\test\esun-library-system\frontend
npm install
```

### 7.2 啟動開發伺服器

```powershell
npm run dev
```

成功後會看到：

```text
Local: http://localhost:5173/
```

瀏覽器開啟：

```text
http://localhost:5173
```

### 7.3 同時啟動後端

```powershell
cd D:\test\esun-library-system\backend
.\mvnw.cmd spring-boot:run
```

後端網址：

```text
http://localhost:8080
```

---

## 8. 使用者操作手冊

### 8.1 開啟系統

1. 確認後端已啟動於 `http://localhost:8080`。
2. 確認前端已啟動於 `http://localhost:5173`。
3. 使用瀏覽器開啟 `http://localhost:5173`。
4. 系統會自動導向 `/books` 並顯示書籍列表。

---

### 8.2 查看書籍列表

進入：

```text
http://localhost:5173/books
```

使用者可以看到每一本館藏的資訊：

- 書名
- 作者
- ISBN
- 庫存編號
- 書籍簡介
- 狀態

狀態包含：

| 狀態 | 意義 |
|---|---|
| `AVAILABLE` | 可借閱 |
| `BORROWED` | 已借出 |

使用者也可以點擊「重新整理」按鈕，重新取得最新館藏狀態。

---

### 8.3 註冊帳號

進入：

```text
http://localhost:5173/register
```

操作步驟：

1. 輸入使用者名稱。
2. 輸入手機號碼。
3. 輸入密碼。
4. 點擊「註冊」。

範例：

```text
使用者名稱：Test User
手機號碼：0912345680
密碼：password123
```

成功後：

```text
畫面顯示「註冊成功，正在前往登入頁」
自動跳轉到 /login
```

---

### 8.4 登入帳號

進入：

```text
http://localhost:5173/login
```

操作步驟：

1. 輸入手機號碼。
2. 輸入密碼。
3. 點擊「登入」。

成功後：

```text
1. 後端回傳 JWT Token
2. 前端將 token 存入 localStorage
3. 前端將 userName 存入 localStorage
4. Navbar 顯示「您好，使用者名稱」
5. 系統跳轉回 /books
```

---

### 8.5 借閱書籍

前提：

```text
使用者必須先登入。
```

操作步驟：

1. 前往 `/books`。
2. 找到狀態為 `AVAILABLE` 的書籍。
3. 點擊「借閱」。
4. 系統呼叫後端借書 API。
5. 借閱成功後，書籍狀態改為 `BORROWED`。

前端呼叫 API：

```http
POST /api/borrows/{inventoryId}
Authorization: Bearer <JWT_TOKEN>
```

成功後畫面顯示：

```text
借閱成功
```

並重新載入書籍列表。

---

### 8.6 歸還書籍

前提：

```text
使用者必須先登入。
```

操作步驟：

1. 前往 `/books`。
2. 找到狀態為 `BORROWED` 的書籍。
3. 點擊「還書」。
4. 系統呼叫後端還書 API。
5. 還書成功後，書籍狀態改回 `AVAILABLE`。

前端呼叫 API：

```http
POST /api/borrows/{inventoryId}/return
Authorization: Bearer <JWT_TOKEN>
```

成功後畫面顯示：

```text
還書成功
```

並重新載入書籍列表。

---

### 8.7 未登入時借書 / 還書

若使用者尚未登入，點擊「借閱」或「還書」時：

```text
1. 前端顯示提示訊息
2. 自動導向 /login
```

同時，後端也有 Spring Security + JWT 保護，即使使用者跳過前端直接呼叫 API，也會被拒絕。

---

### 8.8 登出帳號

登入後，右上角會顯示：

```text
您好，使用者名稱
登出
```

點擊「登出」後：

```text
1. 清除 localStorage.token
2. 清除 localStorage.userName
3. Navbar 回到未登入狀態
4. 導向 /login
```

---

## 9. 前端與後端 API 對應表

| 前端功能 | HTTP Method | API Endpoint | 是否需要 JWT |
|---|---|---|---|
| 書籍列表 | GET | `/api/books` | 否 |
| 註冊 | POST | `/api/auth/register` | 否 |
| 登入 | POST | `/api/auth/login` | 否 |
| 借閱 | POST | `/api/borrows/{inventoryId}` | 是 |
| 還書 | POST | `/api/borrows/{inventoryId}/return` | 是 |

---

## 10. JWT 與登入狀態設計

### 10.1 JWT 儲存位置

登入成功後，前端將 JWT 儲存在：

```text
localStorage.token
```

將使用者名稱儲存在：

```text
localStorage.userName
```

---

### 10.2 自動帶入 Token

所有透過 `http.js` 發出的請求都會經過 Axios interceptor。

如果 localStorage 中有 token，會自動加上：

```http
Authorization: Bearer <token>
```

因此借書與還書 API 可以自動完成身份驗證。

---

### 10.3 登入狀態同步

登入成功後，`LoginView.vue` 會執行：

```js
window.dispatchEvent(new Event('auth-changed'))
```

`App.vue` 會監聽此事件，並重新讀取 localStorage：

```js
window.addEventListener('auth-changed', syncAuthState)
```

因此登入後 Navbar 可以即時顯示使用者名稱。

---

## 11. CORS 問題與解法

### 11.1 問題原因

前端執行於：

```text
http://localhost:5173
```

後端執行於：

```text
http://localhost:8080
```

雖然都是 localhost，但 port 不同，對瀏覽器來說就是不同來源，因此會觸發 CORS 限制。

原本錯誤訊息為：

```text
Access-Control-Allow-Origin Missing Header
```

---

### 11.2 解決方式

後端 `SecurityConfig.java` 中加入：

```java
.cors(Customizer.withDefaults())
```

並新增 `CorsConfigurationSource`，允許：

```text
http://localhost:5173
http://127.0.0.1:5173
```

這樣 Vue 前端就可以正常呼叫 Spring Boot API。

---

## 12. 前端測試紀錄

### 12.1 書籍列表測試

測試網址：

```text
http://localhost:5173/books
```

測試結果：

```text
成功顯示 6 筆書籍 / 庫存資料。
```

---

### 12.2 註冊頁測試

測試網址：

```text
http://localhost:5173/register
```

測試資料：

```text
使用者名稱：Test User
手機號碼：0912345680
密碼：password123
```

預期結果：

```text
註冊成功後跳轉到 /login。
```

---

### 12.3 登入頁測試

測試網址：

```text
http://localhost:5173/login
```

測試資料：

```text
手機號碼：0912345679
密碼：password123
```

預期結果：

```text
登入成功後取得 JWT，並跳轉到 /books。
```

---

### 12.4 借閱測試

測試步驟：

```text
1. 登入系統
2. 前往 /books
3. 點擊 AVAILABLE 書籍的「借閱」
4. 等待畫面重新整理
```

預期結果：

```text
該書籍狀態由 AVAILABLE 變成 BORROWED。
```

---

### 12.5 還書測試

測試步驟：

```text
1. 登入系統
2. 找到 BORROWED 書籍
3. 點擊「還書」
4. 等待畫面重新整理
```

預期結果：

```text
該書籍狀態由 BORROWED 變回 AVAILABLE。
```

---

### 12.6 未登入借閱測試

測試步驟：

```text
1. 登出系統
2. 前往 /books
3. 點擊「借閱」
```

預期結果：

```text
系統提示請先登入，並導向 /login。
```

---

## 13. 前端已滿足的實作要求

| 要求 | 是否滿足 | 說明 |
|---|---:|---|
| 使用 Vue.js | 已滿足 | 使用 Vue 3 + Vite |
| 前後端分離 | 已滿足 | Vue 前端透過 Axios 呼叫 Spring Boot API |
| REST API 串接 | 已滿足 | 串接書籍、註冊、登入、借還書 API |
| 使用者註冊功能 | 已滿足 | `RegisterView.vue` |
| 使用者登入功能 | 已滿足 | `LoginView.vue` |
| 登入驗證 | 已滿足 | JWT 儲存於 localStorage 並自動帶入 |
| 書籍查詢 | 已滿足 | `BookListView.vue` 顯示書籍列表 |
| 借書功能 | 已滿足 | 前端呼叫 `POST /api/borrows/{inventoryId}` |
| 還書功能 | 已滿足 | 前端呼叫 `POST /api/borrows/{inventoryId}/return` |
| 未登入限制 | 已滿足 | 前端導向登入頁，後端也有 JWT 保護 |
| XSS 基礎防護 | 已滿足 | 使用 Vue 插值語法，不使用 `v-html` |
| 操作提示 | 已滿足 | 成功 / 失敗訊息顯示於頁面 |
| 狀態更新 | 已滿足 | 借還書後重新載入書籍列表 |

---

## 14. 安全性說明

### 14.1 XSS 防護

前端顯示書籍資料時使用：

```vue
{{ book.name }}
{{ book.author }}
{{ book.introduction }}
```

Vue 的插值語法會自動進行 HTML escaping。

本專案沒有使用：

```vue
v-html
```

因此可降低 XSS 風險。

---

### 14.2 Token 使用

JWT token 儲存於 `localStorage`，並透過 Axios interceptor 自動帶入 API request。

正式商業產品若安全要求更高，可考慮使用 HttpOnly Cookie。

---

### 14.3 未登入限制

前端會先檢查：

```js
!!localStorage.getItem('token')
```

如果沒有 token，會導向登入頁。

真正的安全保護仍由後端 Spring Security 負責。即使使用者繞過前端，直接呼叫借還書 API，後端仍會要求 JWT。

---

## 15. 目前限制與可改進項目

### 15.1 目前限制

| 項目 | 說明 |
|---|---|
| 還書按鈕顯示邏輯 | 目前只要書籍狀態為 `BORROWED` 就顯示還書按鈕 |
| 我的借閱紀錄 | 尚未建立「我的借閱」頁面 |
| Token 過期提示 | 已有基本處理，但尚未做完整刷新機制 |
| 權限角色 | 目前沒有管理員 / 一般使用者角色 |
| 前端表單驗證 | 有基本空值檢查，細部格式主要由後端驗證 |
| UI 細節 | 可再加入 loading skeleton、toast、modal 等效果 |

---

### 15.2 建議未來優化

| 優化項目 | 說明 |
|---|---|
| 我的借閱紀錄頁 | 顯示目前登入者借過哪些書 |
| 只允許本人還書 | 前端與後端都可進一步限制 |
| 搜尋 / 篩選書籍 | 可依書名、作者、狀態搜尋 |
| 分頁功能 | 書籍多時可加入 pagination |
| Toast 通知 | 操作成功 / 失敗以 Toast 顯示 |
| TypeScript | 未來可導入型別定義，提高維護性 |
| Pinia | 若狀態變複雜，可使用 Pinia 管理登入狀態 |
| E2E Testing | 可使用 Playwright 或 Cypress 測完整流程 |

---

## 16. 前端完成度總結

目前前端可視為：

```text
Frontend MVP：完成
Full-stack Core Flow：完成
Final Polish：待做
```

已完成的完整使用流程：

```text
使用者開啟系統
→ 查看書籍
→ 註冊
→ 登入
→ JWT 儲存
→ 借閱書籍
→ 書籍狀態更新為 BORROWED
→ 歸還書籍
→ 書籍狀態更新為 AVAILABLE
→ 登出
```

此流程已成功串接：

```text
Vue Frontend
→ Axios
→ Spring Boot REST API
→ JWT Authentication
→ Stored Procedure
→ Supabase PostgreSQL
```

因此，本前端已滿足本次全端圖書借閱系統的核心操作需求。
