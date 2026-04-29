<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import http from '../api/http'

const router = useRouter()

const phoneNumber = ref('')
const password = ref('')
const message = ref('')
const loading = ref(false)

const login = async () => {
  message.value = ''

  if (!phoneNumber.value || !password.value) {
    message.value = '請輸入手機號碼與密碼'
    return
  }

  try {
    loading.value = true

    const response = await http.post('/auth/login', {
      phoneNumber: phoneNumber.value,
      password: password.value,
    })

    localStorage.setItem('token', response.data.token)
    localStorage.setItem('userName', response.data.userName)

    message.value = '登入成功'

    window.dispatchEvent(new Event('auth-changed'))

    setTimeout(() => {
      router.push('/books')
    }, 500)
  } catch (error) {
    message.value = error.response?.data?.message || '登入失敗'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <section class="page-card auth-card">
    <h1>登入</h1>
    <p class="subtitle">登入後即可進行借書與還書操作。</p>

    <div class="form">
      <label>
        手機號碼
        <input v-model="phoneNumber" type="text" placeholder="例如 0912345679" />
      </label>

      <label>
        密碼
        <input v-model="password" type="password" placeholder="請輸入密碼" />
      </label>

      <button :disabled="loading" @click="login">
        {{ loading ? '登入中...' : '登入' }}
      </button>
    </div>

    <p v-if="message" class="message">{{ message }}</p>
  </section>
</template>