// 統一負責呼叫後端 API，也會自動帶 JWT
import axios from 'axios'

const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 240000,
})

http.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')

  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }

  return config
})

http.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.code === 'ECONNABORTED') {
      error.userMessage = '後端服務喚醒時間較久，請稍後再試或重新整理頁面。'
    }

    return Promise.reject(error)
  },
)

export default http