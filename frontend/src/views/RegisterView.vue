<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import http from '../api/http'

const router = useRouter()

const userName = ref('')
const phoneNumber = ref('')
const password = ref('')
const message = ref('')
const loading = ref(false)

const register = async () => {
  message.value = ''

  if (!userName.value || !phoneNumber.value || !password.value) {
    message.value = '請完整填寫註冊資料'
    return
  }

  try {
    loading.value = true

    await http.post('/auth/register', {
      userName: userName.value,
      phoneNumber: phoneNumber.value,
      password: password.value,
    })

    message.value = '註冊成功，正在前往登入頁'

    setTimeout(() => {
      router.push('/login')
    }, 800)
  } catch (error) {
    message.value = error.response?.data?.message || '註冊失敗'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <section class="page-card auth-card">
    <h1>註冊帳號</h1>
    <p class="subtitle">使用手機號碼建立圖書借閱系統帳號。</p>

    <div class="form">
      <label>
        使用者名稱
        <input v-model="userName" type="text" placeholder="例如 Jimmy" />
      </label>

      <label>
        手機號碼
        <input v-model="phoneNumber" type="text" placeholder="例如 0912345678" />
      </label>

      <label>
        密碼
        <input v-model="password" type="password" placeholder="至少 8 碼" />
      </label>

      <button :disabled="loading" @click="register">
        {{ loading ? '註冊中...' : '註冊' }}
      </button>
    </div>

    <p v-if="message" class="message">{{ message }}</p>
  </section>
</template>